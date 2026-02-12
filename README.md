<div align="center">

# Auto Company

**A fully autonomous AI company running 24/7**

14 AI agents, each modeled after world-class experts in their domain.
They ideate products, make decisions, write code, deploy, and market - without human intervention.

Powered by [Codex CLI](https://www.npmjs.com/package/@openai/codex) (macOS native + Windows/WSL).

[![macOS](https://img.shields.io/badge/Platform-macOS-blue)](#dependencies)
[![Windows WSL](https://img.shields.io/badge/Platform-Windows%20WSL-blue)](#windows-wsl-quick-start)
[![Codex CLI](https://img.shields.io/badge/Engine-Codex%20CLI-orange)](https://www.npmjs.com/package/@openai/codex)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](#license)
[![Status](https://img.shields.io/badge/Status-Experimental-red)](#disclaimer)

> **Experimental project** - still under active testing. It runs, but stability is not guaranteed.  
> macOS uses launchd; Windows uses WSL systemd --user + PowerShell entry scripts.

</div>

---

[中文版本](README-ZH.md)

## Dashboard Preview

![Auto Company Dashboard](presentation/dashboard-showcase.png)

## What Is This?

You start a loop. The AI team wakes up, reads shared consensus memory, decides what to do, forms a 3-5 person squad, executes, updates consensus memory, then sleeps briefly. Then it repeats.

```
daemon (launchd / systemd --user, auto-restart on crash)
  └── scripts/core/auto-loop.sh (continuous loop)
        ├── reads PROMPT.md + consensus.md
        ├── codex exec (runs one work cycle)
        │   ├── reads CLAUDE.md (charter + guardrails)
        │   ├── reads .claude/skills/team/SKILL.md (teaming method)
        │   ├── forms an Agent Team (3-5 agents)
        │   ├── executes: research, coding, deploy, marketing
        │   └── updates memories/consensus.md (handoff baton)
        ├── failure handling: rate-limit wait / circuit breaker / consensus rollback
        └── sleep -> next cycle
```

Each cycle is an independent `codex exec` call. `memories/consensus.md` is the only cross-cycle state.

## Where To Start (By Platform)

- Windows users: start from [Windows (WSL) Quick Start](#windows-wsl-quick-start), then read [`docs/windows-setup.md`](docs/windows-setup.md)
- macOS users: start from [macOS Quick Start](#macos-quick-start), then see [Command Quick Reference](#command-quick-reference-by-platform)

## Team Lineup (14 Agents)

This is not "you are a generic developer". It is "you are DHH" style role prompting with real expert mental models.

| Layer | Role | Expert Persona | Core Strength |
|------|------|------|----------|
| **Strategy** | CEO | Jeff Bezos | PR/FAQ, flywheel thinking, Day 1 mindset |
| | CTO | Werner Vogels | Design for failure, API-first architecture |
| | Inversion | Charlie Munger | Inversion, pre-mortems, misjudgment checklist |
| **Product** | Product Design | Don Norman | Affordance, mental models, human-centered design |
| | UI Design | Matias Duarte | Material metaphor, typography-first design |
| | Interaction Design | Alan Cooper | Goal-directed design, persona-driven decisions |
| **Engineering** | Full-Stack | DHH | Convention over configuration, majestic monolith |
| | QA | James Bach | Exploratory testing, testing is not checking |
| | DevOps/SRE | Kelsey Hightower | Automation first, reliability discipline |
| **Business** | Marketing | Seth Godin | Purple cow, permission marketing, smallest viable audience |
| | Operations | Paul Graham | Do things that do not scale, ramen profitability |
| | Sales | Aaron Ross | Predictable revenue, funnel systems |
| | CFO | Patrick Campbell | Value-based pricing, unit economics |
| **Intelligence** | Research Analyst | Ben Thompson | Aggregation theory, value chain analysis |

Plus 30+ reusable skills (deep research, scraping, financial modeling, SEO, security audit, UX audit, etc.).

## macOS Quick Start

```bash
# Prerequisites:
# - macOS
# - Codex CLI installed and authenticated
# - Available model quota

# Clone
git clone https://github.com/nicepkg/auto-company.git
cd auto-company

# Foreground run (live output)
make start

# Or install daemon (auto-start + auto-restart)
make install
```

## Windows (WSL) Quick Start

Recommended architecture on Windows: PowerShell command entry + WSL execution core.

1. Install WSL2 + Ubuntu on Windows.
2. Install runtime dependencies inside WSL (`node`, `codex`, `jq`).
3. Run `*-win.ps1` scripts from PowerShell.

Detailed guide: [`docs/windows-setup.md`](docs/windows-setup.md)

Common Windows commands (run in `clone_win`):

```powershell
.\scripts\windows\start-win.ps1              # Start WSL daemon + awake guardian + WSL keepalive
.\scripts\windows\status-win.ps1             # Guardian + keepalive + daemon + loop status
.\scripts\windows\monitor-win.ps1            # Live logs
.\scripts\windows\last-win.ps1               # Last full cycle output
.\scripts\windows\cycles-win.ps1             # Cycle summary
.\scripts\windows\stop-win.ps1               # Stop loop
.\scripts\windows\dashboard-win.ps1          # Local web dashboard
.\scripts\windows\enable-autostart-win.ps1  # Optional: enable start-on-login
.\scripts\windows\disable-autostart-win.ps1 # Disable start-on-login
.\scripts\windows\autostart-status-win.ps1  # Check autostart status
```

### Windows Preconditions (Before Each Run)

1. Develop and commit only in `clone_win/`; keep `clone/` as archive.
2. Ensure `make`, `codex`, and `jq` are available inside WSL.
3. Ensure `codex` is authenticated and runnable inside WSL.
4. Prefer WSL-local Codex path (`/home/...`) from `command -v codex`.
5. If `clone/` shows many WSL Git changes (usually line-ending noise), ignore and do not commit there.

### Windows Recommended Flow

```powershell
.\scripts\windows\start-win.ps1 -CycleTimeoutSeconds 1800 -LoopInterval 30
.\scripts\windows\status-win.ps1
.\scripts\windows\monitor-win.ps1
.\scripts\windows\last-win.ps1
.\scripts\windows\cycles-win.ps1
.\scripts\windows\stop-win.ps1
.\scripts\windows\dashboard-win.ps1
```

Suggested parameters:
- `CycleTimeoutSeconds`: `900-1800`
- `LoopInterval`: `30-60`

Optional autostart:
- Disabled by default
- Enable with `.\scripts\windows\enable-autostart-win.ps1`
- If you see `Access is denied`, retry in an elevated (Administrator) PowerShell

### Windows + WSL Index

For full file index and script responsibility matrix, see [`INDEX.md`](INDEX.md).

### Chat-First Operation (Recommended)

If you do not want to run commands manually, you can operate through Codex chat on Windows.

Feasibility:
- Yes, this works.
- Core chain remains the same: `scripts/windows/start-win.ps1` -> WSL `systemd --user` -> `scripts/core/auto-loop.sh`.
- Windows entry also starts `wsl-anchor-win.ps1` to reduce idle WSL session teardown.
- Core behavior is identical to manual operation; only the control interface changes.

## Command Quick Reference (By Platform)

| Task | macOS / WSL (Terminal) | Windows (PowerShell) |
|---|---|---|
| Start | `make start` | `.\scripts\windows\start-win.ps1` |
| Status | `make status` | `.\scripts\windows\status-win.ps1` |
| Live logs | `make monitor` | `.\scripts\windows\monitor-win.ps1` |
| Last cycle output | `make last` | `.\scripts\windows\last-win.ps1` |
| Cycle summary | `make cycles` | `.\scripts\windows\cycles-win.ps1` |
| Stop | `make stop` | `.\scripts\windows\stop-win.ps1` |
| Web dashboard | N/A | `.\scripts\windows\dashboard-win.ps1` |
| Install daemon | `make install` | Auto-installed/started by `start-win.ps1` |
| Uninstall daemon | `make uninstall` | `wsl -d Ubuntu --cd <repo_wsl_path> bash -lc 'make uninstall'` |
| Pause daemon | `make pause` | `wsl -d Ubuntu --cd <repo_wsl_path> bash -lc 'make pause'` |
| Resume daemon | `make resume` | `wsl -d Ubuntu --cd <repo_wsl_path> bash -lc 'make resume'` |

### macOS Sleep Prevention (macOS Only)

macOS screen lock usually does not kill processes, but system sleep can pause work. For long runs:

```bash
make start-awake   # Start loop and keep system awake until loop exits

# If loop is already running (after make start):
make awake         # Attach caffeinate to PID in .auto-loop.pid
```

Notes:
- Both commands depend on built-in `caffeinate`
- `make awake` exits automatically when target PID exits

## Operating Model

### Automatic Convergence (No Endless Discussion)

| Cycle | Action |
|------|------|
| Cycle 1 | Brainstorm: each agent proposes ideas, rank top 3 |
| Cycle 2 | Validate #1: Munger pre-mortem + Thompson market check + Campbell economics -> **GO / NO-GO** |
| Cycle 3+ | GO -> create repo, build, deploy. NO-GO -> move to next idea. Discussion-only loops are forbidden |

### Six Standard Workflows

| # | Workflow | Collaboration Chain |
|---|------|--------|
| 1 | **New Product Evaluation** | Research -> CEO -> Munger -> Product -> CTO -> CFO |
| 2 | **Feature Development** | Interaction -> UI -> Full-stack -> QA -> DevOps |
| 3 | **Product Launch** | QA -> DevOps -> Marketing -> Sales -> Ops -> CEO |
| 4 | **Pricing and Monetization** | Research -> CFO -> Sales -> Munger -> CEO |
| 5 | **Weekly Review** | Ops -> Sales -> CFO -> QA -> CEO |
| 6 | **Opportunity Discovery** | Research -> CEO -> Munger -> CFO |

## Steering

The team runs autonomously, but you can intervene at any time:

| Method | Action |
|------|------|
| **Change direction** | Edit "Next Action" in `memories/consensus.md` |
| **Pause** | `make pause` (macOS/WSL daemon mode) or `.\scripts\windows\stop-win.ps1` (Windows entry) |
| **Resume** | `make resume` |
| **Review outputs** | Check `docs/*/` for artifacts generated by agents |

## Safety Guardrails

Hard constraints in `CLAUDE.md`, enforced for all agents:

- Do not delete GitHub repos (`gh repo delete`)
- Do not delete Cloudflare projects (`wrangler delete`)
- Do not delete system directories (`~/.ssh/`, `~/.config/`, etc.)
- Do not perform illegal activity
- Do not leak credentials into public repositories
- Do not force push to main/master
- Create all new projects under `projects/`

## Configuration

Environment variable overrides:

```bash
MODEL=gpt-5.3-codex make start             # Optional model override
LOOP_INTERVAL=60 make start                # 60s interval (default 30)
CYCLE_TIMEOUT_SECONDS=3600 make start      # 1h cycle timeout (default 1800)
MAX_CONSECUTIVE_ERRORS=3 make start        # Circuit-breaker threshold (default 5)
CODEX_SANDBOX_MODE=workspace-write make start  # Optional sandbox override
```

## Project Structure

```
auto-company/
├── CLAUDE.md              # Company charter (mission + guardrails + team + workflows)
├── PROMPT.md              # Per-cycle execution prompt (convergence rules)
├── Makefile               # Common command entry
├── INDEX.md               # clone_win index + script responsibility table
├── dashboard/             # Local web status dashboard (started via dashboard-win.ps1)
├── scripts/
│   ├── core/              # Core loop and control scripts (auto-loop/monitor/stop)
│   ├── windows/           # Windows entry/guardian/autostart scripts
│   ├── wsl/               # WSL systemd --user daemon scripts
│   └── macos/             # macOS launchd daemon scripts
├── memories/
│   └── consensus.md       # Shared handoff memory across cycles
├── docs/                  # Agent outputs (14 folders + Windows guide)
├── projects/              # Workspace for generated projects
├── logs/                  # Loop logs
└── .claude/
    ├── agents/            # 14 agent definitions (expert personas)
    ├── skills/            # 30+ reusable skills
    └── settings.json      # Permissions + Agent Teams switch
```

## Dependencies

| Dependency | Notes |
|------|------|
| **[Codex CLI](https://www.npmjs.com/package/@openai/codex)** | Required, must be installed and logged in |
| **macOS or Windows + WSL2 (Ubuntu)** | macOS uses launchd; Windows uses WSL execution core |
| `node` | Codex runtime |
| `make` | Start/stop/monitor command entry (WSL/macOS) |
| `jq` | Recommended for log processing |
| `gh` | Optional, GitHub CLI |
| `wrangler` | Optional, Cloudflare CLI |

## FAQ

### 1) WSL `.sh` fails with `^M` / `bad interpreter`

- Cause: CRLF line endings in shell scripts
- Fix:
  - Keep LF rules in `.gitattributes`
  - Run `git config core.autocrlf false && git config core.eol lf`

### 2) WSL says `codex: node not found`

- Cause: Codex/Node installed on Windows only, missing in WSL
- Fix: install `node` and `@openai/codex` inside WSL

### 3) `make install` fails inside WSL

- Cause: no available `systemctl --user` in current session
- Fix:
  - Verify WSL systemd is enabled
  - Run `systemctl --user --version`
  - Re-open WSL session and retry if needed

### 4) `clone/` shows many Git changes under WSL

- Cause: archive directory with potential CRLF/LF noise
- Can it be ignored: yes, if you do not commit there
- Requirement:
  - Develop and commit only in `clone_win/`
  - Keep `clone/` for archival comparison only

## Disclaimer

This is an **experimental project**:

- **Daemon mode works on both macOS and WSL**: launchd on macOS, systemd --user on WSL
- **Windows entry requires WSL**: PowerShell is only the control layer
- **Still under test**: runs, but stability is not guaranteed
- **Costs money**: each cycle consumes model quota
- **Fully autonomous**: agents act without approval prompts; configure guardrails carefully in `CLAUDE.md`
- **No warranty**: review `docs/` and `projects/` regularly

Suggested rollout: start with `make start` (foreground), then move to daemon mode (`make install` on macOS/WSL, `.\scripts\windows\start-win.ps1` on Windows).

## Acknowledgments

- [continuous-claude](https://github.com/AnandChowdhary/continuous-claude) - cross-session shared notes
- [ralph-claude-code](https://github.com/frankbria/ralph-claude-code) - exit signal interception
- [claude-auto-resume](https://github.com/terryso/claude-auto-resume) - usage-limit resume pattern

## License

MIT
