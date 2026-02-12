# History Rewrite Report

- Generated: 2026-02-12
- Repository: `d:\Max\Projects\Dev\Auto-Company\clone_win`
- Target branch: `main`
- Rewrite target: 450 linear commits
- Identity target: `MaxMiksa <kongzheyuan@outlook.com>`

## 1. Execution Overview

Status: **COMPLETED**

Completed actions:
- Consolidated script entrypoints to `scripts/` and removed root wrapper scripts.
- Captured source snapshot commit and tree for parity checks.
- Rebuilt local `main` as a new linear history with 450 commits.
- Normalized author/committer identity and synchronized author/commit timestamps.
- Recreated milestone lightweight tags.
- Performed post-rewrite validations.

## 2. Verification Checklist

| Check | Command | Expected | Actual | Result |
|---|---|---|---|---|
| Commit count | `git rev-list --count main` | `450` | `450` | PASS |
| Merge commits | `git rev-list --count --merges main` | `0` | `0` | PASS |
| Identity uniqueness | `git log --format='%an|%ae|%cn|%ce' main \| sort -u` | single target identity | `MaxMiksa|kongzheyuan@outlook.com|MaxMiksa|kongzheyuan@outlook.com` | PASS |
| Date range | custom validator | all in `2025-07-01..2026-02-12` (America/New_York) | `RANGE_FAIL=0` | PASS |
| Weekday rule | custom validator | no weekends | `WEEKEND_FAIL=0` | PASS |
| Holiday exclusions | custom validator | no excluded US holidays | `HOLIDAY_FAIL=0` | PASS |
| AuthorDate == CommitDate | custom validator | exact equality | `AUTHOR_COMMIT_DATE_MISMATCH=0` | PASS |
| Daily distribution | custom validator | `{0:6,1:11,2:36,3:79,5:18,8:5}` over 155 workdays | `FREQ {0: 6, 1: 11, 2: 36, 3: 79, 5: 18, 8: 5}` | PASS |
| Final tree parity | `git rev-parse main^{tree}` vs snapshot tree | equal | `a9cd394103f7735e07ca2140fd188d87fa9f462b` == `a9cd394103f7735e07ca2140fd188d87fa9f462b` | PASS |
| Banned words in subjects | custom grep | none | `BANNED_WORD_CHECK=PASS` | PASS |
| Tags present | `git tag --list m0-bootstrap m1-core-loop m2-win-wsl m3-daemon-guardian` | 4 tags | 4 tags listed | PASS |
| Build | `npm run build` when `package.json` exists | pass or N/A | `BUILD=N/A (no package.json)` | PASS (N/A) |

## 3. Tag Positions

- `m0-bootstrap` -> `7c53de80122968eba94d5cb2cefb122bbb38ae13`
- `m1-core-loop` -> `05a2b96b3c613e072caa80225eff70068bef707d`
- `m2-win-wsl` -> `d6553eb61ddb70992abe21fefef40bf12d330697`
- `m3-daemon-guardian` -> `43252fdaa84243021b57acbc45ee4cbf2da8b245`

## 4. Build Result

- `package.json` not present in repository root.
- Build check marked as **N/A** per policy.

## 5. Branch / Remote Status

- `git status -sb`: `## main...origin/main [ahead 450, behind 12]`
- `git remote -v`:
  - `origin https://github.com/nicepkg/auto-company (fetch)`
  - `origin https://github.com/nicepkg/auto-company (push)`
- Push not performed.

## 6. Rollback Anchors

- Backup branch (pre-rewrite): `backup/pre-rewrite-20260212-150929`
- Backup branch (source snapshot): `backup/source-snapshot-20260212-150929`
- Bundle snapshot: `D:\Max\Projects\Dev\Auto-Company\clone_win-pre-rewrite-20260212-150929.bundle`

## 7. Rollback Commands

```bash
git switch main
git reset --hard backup/pre-rewrite-20260212-150929
```

Bundle-based recovery:

```bash
git clone D:/Max/Projects/Dev/Auto-Company/clone_win-pre-rewrite-20260212-150929.bundle recovered-clone-win
```
