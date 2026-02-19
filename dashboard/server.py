#!/usr/bin/env python3
"""Local dashboard server for Auto Company (macOS + Linux)."""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import time
from datetime import datetime, timezone
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Any
from urllib.parse import parse_qs, urlparse


REPO_ROOT = Path(__file__).resolve().parents[1]
DASHBOARD_DIR = Path(__file__).resolve().parent

LOG_FILE = REPO_ROOT / "logs" / "auto-loop.log"
STATE_FILE = REPO_ROOT / ".auto-loop-state"
CONSENSUS_FILE = REPO_ROOT / "memories" / "consensus.md"
PID_FILE = REPO_ROOT / ".auto-loop.pid"
LOOP_SCRIPT = REPO_ROOT / "scripts" / "core" / "auto-loop.sh"


def read_text_file(path: Path, fallback: str = "") -> str:
    try:
        raw = path.read_bytes()
    except FileNotFoundError:
        return fallback
    except Exception as exc:
        return f"(read error: {exc})"
    for enc in ("utf-8", "utf-8-sig"):
        try:
            return raw.decode(enc)
        except UnicodeDecodeError:
            continue
    return raw.decode("utf-8", errors="replace")


def read_tail(path: Path, lines: int = 120) -> str:
    if lines <= 0:
        return ""
    text = read_text_file(path, "")
    if not text:
        return ""
    rows = text.splitlines()
    return "\n".join(rows[-lines:])


def pid_is_running(pid: int) -> bool:
    try:
        os.kill(pid, 0)
        return True
    except (OSError, ProcessLookupError):
        return False


def get_loop_status() -> dict[str, Any]:
    """Check loop status by reading PID file and process state."""
    result = {
        "state": "stopped",
        "pid": None,
    }
    if PID_FILE.exists():
        try:
            pid = int(PID_FILE.read_text().strip())
            if pid_is_running(pid):
                result["state"] = "running"
                result["pid"] = pid
        except (ValueError, OSError):
            pass
    return result


def get_daemon_status() -> dict[str, Any]:
    """Check launchd daemon status on macOS."""
    result = {
        "state": "not_installed",
        "activeState": "unknown",
        "subState": "unknown",
        "mainPid": None,
    }
    try:
        proc = subprocess.run(
            ["launchctl", "list"],
            capture_output=True, text=True, timeout=5,
        )
        for line in proc.stdout.splitlines():
            if "auto-company" in line.lower() or "auto-loop" in line.lower():
                parts = line.split()
                result["state"] = "active"
                result["activeState"] = "active"
                result["subState"] = "running"
                if parts[0] != "-" and parts[0].isdigit():
                    result["mainPid"] = int(parts[0])
                return result
    except (subprocess.TimeoutExpired, FileNotFoundError, OSError):
        pass
    return result


def get_state_file() -> dict[str, str]:
    text = read_text_file(STATE_FILE, "").strip()
    pairs: dict[str, str] = {}
    if text:
        for row in text.splitlines():
            if "=" in row:
                k, v = row.split("=", 1)
                pairs[k.strip()] = v.strip()
    return pairs


def gather_status_payload() -> dict[str, Any]:
    loop = get_loop_status()
    daemon = get_daemon_status()
    state_pairs = get_state_file()

    loop["engine"] = state_pairs.get("ENGINE", "claude")
    loop["model"] = state_pairs.get("MODEL", "")
    loop["lastRun"] = state_pairs.get("LAST_RUN", "")
    loop["errorCount"] = state_pairs.get("ERROR_COUNT", "0")
    loop["loopCount"] = state_pairs.get("LOOP_COUNT", "0")
    loop["daemonSummary"] = daemon["activeState"]

    parsed = {
        "guardian": {"state": "running" if loop["state"] == "running" else "stopped", "pid": loop["pid"], "raw": ""},
        "autostart": {"state": "not_configured", "raw": "macOS launchd"},
        "daemon": daemon,
        "loop": loop,
        "consensusPreview": "",
        "recentLog": "",
    }

    if daemon["state"] == "active":
        parsed["autostart"]["state"] = "configured"

    return {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "ok": True,
        "exitCode": 0,
        "elapsedMs": 0,
        "raw": f"Loop: {loop['state'].upper()}, Daemon: {daemon['state']}",
        "parsed": parsed,
        "stateFile": state_pairs,
        "consensusHead": read_text_file(CONSENSUS_FILE, "(no consensus file)")[:3000],
        "logTail": read_tail(LOG_FILE, lines=180),
    }


def start_loop() -> dict[str, Any]:
    """Start the auto-loop in background."""
    if not LOOP_SCRIPT.exists():
        return {"ok": False, "exitCode": 1, "elapsedMs": 0, "output": f"Loop script not found: {LOOP_SCRIPT}"}
    try:
        subprocess.Popen(
            ["bash", str(LOOP_SCRIPT)],
            cwd=str(REPO_ROOT),
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )
        time.sleep(1)
        return {"ok": True, "exitCode": 0, "elapsedMs": 0, "output": "Loop started"}
    except Exception as exc:
        return {"ok": False, "exitCode": 1, "elapsedMs": 0, "output": str(exc)}


def stop_loop() -> dict[str, Any]:
    """Stop the auto-loop by sending SIGTERM to PID."""
    if not PID_FILE.exists():
        return {"ok": True, "exitCode": 0, "elapsedMs": 0, "output": "No loop running (no PID file)"}
    try:
        pid = int(PID_FILE.read_text().strip())
        if pid_is_running(pid):
            os.kill(pid, 15)  # SIGTERM
            time.sleep(1)
            return {"ok": True, "exitCode": 0, "elapsedMs": 0, "output": f"Sent SIGTERM to PID {pid}"}
        else:
            return {"ok": True, "exitCode": 0, "elapsedMs": 0, "output": f"PID {pid} not running"}
    except Exception as exc:
        return {"ok": False, "exitCode": 1, "elapsedMs": 0, "output": str(exc)}


class DashboardHandler(BaseHTTPRequestHandler):
    def _json(self, payload: dict[str, Any], code: int = 200) -> None:
        raw = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(raw)))
        self.end_headers()
        self.wfile.write(raw)

    def _serve_file(self, path: Path, content_type: str) -> None:
        if not path.exists():
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"Not found")
            return
        data = path.read_bytes()
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self) -> None:
        parsed = urlparse(self.path)
        path = parsed.path

        routes = {
            "/": ("index.html", "text/html; charset=utf-8"),
            "/index.html": ("index.html", "text/html; charset=utf-8"),
            "/app.js": ("app.js", "application/javascript; charset=utf-8"),
            "/styles.css": ("styles.css", "text/css; charset=utf-8"),
            "/favicon.svg": ("favicon.svg", "image/svg+xml"),
        }

        if path in routes:
            filename, ctype = routes[path]
            self._serve_file(DASHBOARD_DIR / filename, ctype)
            return

        if path == "/api/status":
            self._json(gather_status_payload())
            return

        if path == "/api/log-tail":
            qs = parse_qs(parsed.query)
            lines = int(qs.get("lines", ["180"])[0])
            self._json({
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "lines": lines,
                "logTail": read_tail(LOG_FILE, lines=lines),
            })
            return

        self.send_response(404)
        self.end_headers()
        self.wfile.write(b"Not found")

    def do_POST(self) -> None:
        parsed = urlparse(self.path)
        path = parsed.path

        if path == "/api/action/start":
            res = start_loop()
        elif path == "/api/action/stop":
            res = stop_loop()
        elif path == "/api/action/refresh":
            res = {"ok": True, "exitCode": 0, "elapsedMs": 0, "output": "refreshed"}
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"Not found")
            return

        payload = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "action": path.rsplit("/", 1)[-1],
            **res,
        }
        self._json(payload, code=200 if res["ok"] else 400)

    def log_message(self, fmt: str, *args: Any) -> None:
        pass


def main() -> None:
    parser = argparse.ArgumentParser(description="Auto Company dashboard (macOS/Linux)")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8787)
    args = parser.parse_args()

    server = ThreadingHTTPServer((args.host, args.port), DashboardHandler)
    print(f"[dashboard] http://{args.host}:{args.port}")
    print(f"[dashboard] repo: {REPO_ROOT}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
        print("[dashboard] stopped")


if __name__ == "__main__":
    os.chdir(REPO_ROOT)
    main()
