#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

PORT="${PORT:-8791}"
BASE_URL="${BASE_URL:-http://127.0.0.1:${PORT}}"
DB_NAME="${DB_NAME:-ar-assistant-db}"
PERSIST_DIR="${PERSIST_DIR:-.wrangler/pilot-smoke}"
CSV_FILE="${CSV_FILE:-sample/invoices.sample.csv}"
LOG_DIR="${LOG_DIR:-logs}"
RUN_TS="$(date +%Y%m%d-%H%M%S)"
RUN_LOG="${RUN_LOG:-${LOG_DIR}/pilot-smoke-${RUN_TS}.log}"

mkdir -p "$LOG_DIR"

echo "[pilot-smoke] starting"
echo "[pilot-smoke] root=$ROOT_DIR"
echo "[pilot-smoke] base_url=$BASE_URL"
echo "[pilot-smoke] persist_dir=$PERSIST_DIR"

rm -rf "$PERSIST_DIR"
mkdir -p "$PERSIST_DIR"

exec > >(tee -a "$RUN_LOG") 2>&1

DEV_PID=""
cleanup() {
  if [[ -n "$DEV_PID" ]] && kill -0 "$DEV_PID" 2>/dev/null; then
    echo "[pilot-smoke] stopping wrangler dev pid=$DEV_PID"
    kill "$DEV_PID" >/dev/null 2>&1 || true
    wait "$DEV_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[pilot-smoke] missing command: $1" >&2
    exit 1
  fi
}

require_cmd curl
require_cmd node
require_cmd npx
require_cmd sed

if [[ ! -f "$CSV_FILE" ]]; then
  echo "[pilot-smoke] CSV file not found: $CSV_FILE" >&2
  exit 1
fi

# Ensure a clean local schema in isolated storage.
printf 'y\n' | npx wrangler d1 migrations apply "$DB_NAME" --local --persist-to "$PERSIST_DIR"

WRANGLER_LOG="$LOG_DIR/pilot-smoke-wrangler-${RUN_TS}.log"

echo "[pilot-smoke] starting wrangler dev"
npx wrangler dev --local --port "$PORT" --persist-to "$PERSIST_DIR" >"$WRANGLER_LOG" 2>&1 &
DEV_PID=$!

for _ in $(seq 1 60); do
  if curl -fsS "$BASE_URL/" >/dev/null 2>&1; then
    echo "[pilot-smoke] server ready"
    break
  fi
  sleep 0.5
done

if ! curl -fsS "$BASE_URL/" >/dev/null 2>&1; then
  echo "[pilot-smoke] worker failed to boot; see $WRANGLER_LOG" >&2
  exit 1
fi

post_expect_status() {
  local path="$1"
  local expect_status_csv="$2"
  local extra_arg="${3:-}"
  local headers body status
  headers="$(mktemp)"
  body="$(mktemp)"
  if [[ -n "$extra_arg" ]]; then
    curl -sS -X POST -D "$headers" -o "$body" $extra_arg "$BASE_URL$path"
  else
    curl -sS -X POST -D "$headers" -o "$body" "$BASE_URL$path"
  fi
  status="$(awk 'NR==1{print $2}' "$headers")"
  local matched="false"
  local expect
  IFS=',' read -r -a expect <<<"$expect_status_csv"
  for code in "${expect[@]}"; do
    if [[ "$status" == "$code" ]]; then
      matched="true"
      break
    fi
  done
  if [[ "$matched" != "true" ]]; then
    echo "[pilot-smoke] unexpected status for POST $path: got=$status expect_one_of=$expect_status_csv" >&2
    echo "[pilot-smoke] response preview:" >&2
    sed -n '1,40p' "$body" >&2
    rm -f "$headers" "$body"
    exit 1
  fi
  echo "[pilot-smoke] POST $path -> $status"
  rm -f "$headers" "$body"
}

echo "[pilot-smoke] step=init-defaults"
post_expect_status "/init-defaults" "200,303"

echo "[pilot-smoke] step=import-csv"
post_expect_status "/import/csv" "200" "-F file=@${CSV_FILE};type=text/csv"

echo "[pilot-smoke] step=cadence-run"
cadence_body="$(mktemp)"
curl -sS -X POST "$BASE_URL/cadence/run" -o "$cadence_body"
if ! rg -q "Cadence run complete" "$cadence_body"; then
  echo "[pilot-smoke] cadence run did not complete as expected" >&2
  sed -n '1,80p' "$cadence_body" >&2
  rm -f "$cadence_body"
  exit 1
fi
if ! rg -q "Drafts created: <code>2</code>" "$cadence_body"; then
  echo "[pilot-smoke] unexpected created draft count in cadence output" >&2
  rg -n "Drafts created|Skipped" "$cadence_body" >&2 || true
  rm -f "$cadence_body"
  exit 1
fi
rm -f "$cadence_body"
echo "[pilot-smoke] cadence created 2 drafts"

queue_pending="$(mktemp)"
curl -sS "$BASE_URL/queue?status=pending" -o "$queue_pending"
DRAFT_ID="$(sed -n 's#.*action="/queue/\([a-z0-9-]*\)/approve".*#\1#p' "$queue_pending" | head -n1)"
if [[ -z "$DRAFT_ID" ]]; then
  echo "[pilot-smoke] failed to extract draft id from pending queue" >&2
  sed -n '1,120p' "$queue_pending" >&2
  rm -f "$queue_pending"
  exit 1
fi
if rg -q "send (resend)" "$queue_pending"; then
  echo "[pilot-smoke] expected resend send button to be absent when not configured" >&2
  rm -f "$queue_pending"
  exit 1
fi
rm -f "$queue_pending"

echo "[pilot-smoke] selected draft_id=$DRAFT_ID"

echo "[pilot-smoke] step=mark-sent-blocked-before-approve"
post_expect_status "/queue/${DRAFT_ID}/mark-sent" "303"

DRAFT_STATUS_SQL="SELECT status FROM drafts WHERE id='${DRAFT_ID}' LIMIT 1;"
draft_status_json="$(npx wrangler d1 execute "$DB_NAME" --local --persist-to "$PERSIST_DIR" --command "$DRAFT_STATUS_SQL" --json)"
draft_status="$(node -e 'const data=JSON.parse(process.argv[1]); console.log((data[0].results[0]||{}).status || "");' "$draft_status_json")"
if [[ "$draft_status" != "pending" ]]; then
  echo "[pilot-smoke] expected pending draft to stay pending before approval, got=$draft_status" >&2
  exit 1
fi
echo "[pilot-smoke] pre-approval guard ok (status stays pending)"

echo "[pilot-smoke] step=approve"
post_expect_status "/queue/${DRAFT_ID}/approve" "303"

echo "[pilot-smoke] step=mark-sent"
post_expect_status "/queue/${DRAFT_ID}/mark-sent" "303"

STATUS_SQL="SELECT COALESCE(SUM(CASE WHEN status='pending' THEN 1 ELSE 0 END),0) AS pending, COALESCE(SUM(CASE WHEN status='approved' THEN 1 ELSE 0 END),0) AS approved, COALESCE(SUM(CASE WHEN status='sent' THEN 1 ELSE 0 END),0) AS sent FROM drafts;"
EVENT_SQL="SELECT type, COUNT(*) AS c FROM events GROUP BY type ORDER BY type;"

status_json="$(npx wrangler d1 execute "$DB_NAME" --local --persist-to "$PERSIST_DIR" --command "$STATUS_SQL" --json)"
events_json="$(npx wrangler d1 execute "$DB_NAME" --local --persist-to "$PERSIST_DIR" --command "$EVENT_SQL" --json)"

pending_count="$(node -e 'const data=JSON.parse(process.argv[1]); console.log(data[0].results[0].pending);' "$status_json")"
approved_count="$(node -e 'const data=JSON.parse(process.argv[1]); console.log(data[0].results[0].approved);' "$status_json")"
sent_count="$(node -e 'const data=JSON.parse(process.argv[1]); console.log(data[0].results[0].sent);' "$status_json")"

if [[ "$pending_count" != "1" || "$approved_count" != "0" || "$sent_count" != "1" ]]; then
  echo "[pilot-smoke] unexpected draft status distribution: pending=$pending_count approved=$approved_count sent=$sent_count" >&2
  exit 1
fi

echo "[pilot-smoke] status distribution ok: pending=$pending_count approved=$approved_count sent=$sent_count"
echo "[pilot-smoke] event summary: $events_json"
echo "[pilot-smoke] PASS"
echo "[pilot-smoke] run log: $RUN_LOG"
echo "[pilot-smoke] wrangler log: $WRANGLER_LOG"
