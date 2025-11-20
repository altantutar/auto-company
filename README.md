<div align="center">

# Auto Company

**全自主 AI 公司，24/7 不停歇运行**

14 个 AI Agent，每个都是该领域世界顶级专家的思维分身。
自主构思产品、做决策、写代码、部署上线、搞营销。没有人类参与。

基于 [Codex CLI](https://www.npmjs.com/package/@openai/codex) 驱动（macOS 原生 + Windows/WSL）。

[![macOS](https://img.shields.io/badge/平台-macOS-blue)](#依赖)
[![Windows WSL](https://img.shields.io/badge/平台-Windows%20WSL-blue)](#windows-wsl-快速开始)
[![Codex CLI](https://img.shields.io/badge/驱动-Codex%20CLI-orange)](https://www.npmjs.com/package/@openai/codex)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](#license)
[![Status](https://img.shields.io/badge/状态-实验中-red)](#%EF%B8%8F-免责声明)

> **⚠️ 实验项目** — 还在测试中，能跑但不一定稳定。  
> macOS 使用 launchd；Windows 使用 WSL systemd --user + PowerShell 入口。

</div>

---

## 这是什么？

你启动一个循环。AI 团队醒来，读取共识记忆，决定干什么，组建 3-5 人小队，执行任务，更新共识记忆，然后睡一觉。接着又醒来。如此往复，永不停歇。

```
launchd (崩溃自重启)
  └── scripts/core/auto-loop.sh (永续循环)
        ├── 读 PROMPT.md + consensus.md
        ├── codex exec (驱动一个工作周期)
        │   ├── 读 CLAUDE.md (公司章程 + 安全红线)
        │   ├── 读 .claude/skills/team/SKILL.md (组队方法)
        │   ├── 组建 Agent Team (3-5 人)
        │   ├── 执行：调研、写码、部署、营销
        │   └── 更新 memories/consensus.md (传递接力棒)
        ├── 失败处理: 限额等待 / 熔断保护 / consensus 回滚
        └── sleep → 下一轮
```

每个周期是一次独立的 `codex exec` 调用。`memories/consensus.md` 是唯一的跨周期状态——类似接力赛传棒。

## 团队阵容（14 人）

不是"你是一个开发者"，而是"你是 DHH"——用真实传奇人物激活 LLM 的深层知识。

| 层级 | 角色 | 专家 | 核心能力 |
|------|------|------|----------|
| **战略** | CEO | Jeff Bezos | PR/FAQ、飞轮效应、Day 1 心态 |
| | CTO | Werner Vogels | 为失败而设计、API First |
| | 逆向思考 | Charlie Munger | 逆向思维、Pre-Mortem、心理误判清单 |
| **产品** | 产品设计 | Don Norman | 可供性、心智模型、以人为本 |
| | UI 设计 | Matías Duarte | Material 隐喻、Typography 优先 |
| | 交互设计 | Alan Cooper | Goal-Directed Design、Persona 驱动 |
| **工程** | 全栈开发 | DHH | 约定优于配置、Majestic Monolith |
| | QA | James Bach | 探索性测试、Testing ≠ Checking |
| | DevOps/SRE | Kelsey Hightower | Serverless 优先、自动化一切 |
| **商业** | 营销 | Seth Godin | 紫牛、许可营销、最小可行受众 |
| | 运营 | Paul Graham | Do Things That Don't Scale、拉面盈利 |
| | 销售 | Aaron Ross | 可预测收入、漏斗思维 |
| | CFO | Patrick Campbell | 基于价值定价、单位经济学 |
| **情报** | 调研分析 | Ben Thompson | Aggregation Theory、价值链分析 |

另配 **30+ 技能**（深度调研、网页抓取、财务建模、SEO、安全审计、UX 审计……），任何 Agent 按需取用。

## 快速开始

```bash
# 前提:
# - macOS
# - 已安装 Codex CLI 并完成登录
# - 可用模型配额

# 克隆
git clone https://github.com/nicepkg/auto-company.git
cd auto-company

# 前台运行（直接看输出）
make start

# 或安装为守护进程（开机自启 + 崩溃自重启）
make install
```

## Windows (WSL) 快速开始

Windows 下推荐“PowerShell 命令入口 + WSL 执行内核”：

1. 在 Windows 安装 WSL2 + Ubuntu。
2. 在 WSL 中一次性安装运行依赖（`node`、`codex`、`jq`）。
3. 在 PowerShell 直接运行 `*-win.ps1` 脚本。

详细步骤见：[`docs/windows-setup.md`](docs/windows-setup.md)

常用 Windows 命令（在 `clone_win` 目录执行）：

```powershell
.\scripts\windows\start-win.ps1              # 启动 WSL daemon + 运行时防睡眠
.\scripts\windows\status-win.ps1             # 查看 guardian + daemon + 循环状态
.\scripts\windows\monitor-win.ps1            # 实时日志
.\scripts\windows\last-win.ps1               # 上一轮完整输出
.\scripts\windows\cycles-win.ps1             # 历史周期摘要
.\scripts\windows\stop-win.ps1               # 停止循环
.\scripts\windows\enable-autostart-win.ps1  # 可选：启用登录后自启
.\scripts\windows\disable-autostart-win.ps1 # 关闭登录后自启
.\scripts\windows\autostart-status-win.ps1  # 查看自启状态
```

### Windows 前置事项（每次开始前）

1. 只在 `clone_win/` 运行与提交，`clone/` 仅留档。
2. WSL 内 `make`、`codex`、`jq` 可用。
3. `codex` 已在 WSL 内登录且可调用。
4. 建议 `command -v codex` 优先指向 WSL 本地路径（`/home/...`）。
5. `clone/` 若在 WSL 下显示大量 `git status` 修改（多为换行差异）可忽略，不要在该目录提交。

### Windows 推荐操作（标准）

```powershell
.\scripts\windows\start-win.ps1 -CycleTimeoutSeconds 1800 -LoopInterval 30
.\scripts\windows\status-win.ps1
.\scripts\windows\monitor-win.ps1
.\scripts\windows\last-win.ps1
.\scripts\windows\cycles-win.ps1
.\scripts\windows\stop-win.ps1
```

推荐参数：
- `CycleTimeoutSeconds` 建议 `900-1800`
- `LoopInterval` 建议 `30-60`

可选自启：
- 默认不自动启用
- 按需执行 `.\scripts\windows\enable-autostart-win.ps1`
- 若提示 `Access is denied`，请用“管理员 PowerShell”执行启用/关闭自启脚本

### Windows + WSL 索引

完整目录索引与脚本职责表请看：[`INDEX.md`](INDEX.md)

### Chat-first 操作方式（推荐）

如果你不想手动执行命令，可以直接和 Codex 对话，由 Codex 在 Windows 侧代你调用 WSL。

可行性：
- 可行。
- 底层仍是同一套脚本链路：`scripts/windows/start-win.ps1` -> WSL `systemd --user` -> `scripts/core/auto-loop.sh`。
- 核心运行机制与手动执行一致，差异只在“操作入口”从手工命令变为对话驱动。

## 常用命令

```bash
make help       # 查看所有命令
make start      # 前台启动循环
make start-awake# 前台启动 + 防止 macOS 睡眠（仅 macOS）
make stop       # 停止循环
make status     # 查看状态 + 最新共识
make monitor    # 实时日志
make last       # 上一轮完整输出
make cycles     # 历史周期摘要
make awake      # 已在跑时，为当前 PID 挂防睡眠（仅 macOS）
make install    # 安装守护进程（macOS: launchd, Linux/WSL: systemd --user）
make uninstall  # 卸载守护进程
make pause      # 暂停守护（macOS/WSL）
make resume     # 恢复守护（macOS/WSL）
```

## 防止 Mac 睡眠（推荐）

macOS 的屏保/锁屏通常不会杀进程，但系统睡眠会让任务暂停。长时间运行建议开启防睡眠：

```bash
make start-awake   # 启动循环并保持系统唤醒（直到循环退出）

# 如果循环已经在跑（比如你已执行 make start）：
make awake         # 读取 .auto-loop.pid 并对该 PID 挂 caffeinate
```

说明：
- 这两个命令依赖 macOS 自带 `caffeinate`
- `make awake` 会在 PID 结束后自动退出

## 运作机制

### 自动收敛（防止无限讨论）

| 周期 | 动作 |
|------|------|
| Cycle 1 | 头脑风暴——每个 Agent 提一个想法，排出 top 3 |
| Cycle 2 | 验证 #1——Munger 做 Pre-Mortem，Thompson 验证市场，Campbell 算账 → **GO / NO-GO** |
| Cycle 3+ | GO → 建 repo 写代码部署。NO-GO → 试下一个。**纯讨论禁止** |

### 六大标准流程

| # | 流程 | 协作链 |
|---|------|--------|
| 1 | **新产品评估** | 调研 → CEO → Munger → 产品 → CTO → CFO |
| 2 | **功能开发** | 交互 → UI → 全栈 → QA → DevOps |
| 3 | **产品发布** | QA → DevOps → 营销 → 销售 → 运营 → CEO |
| 4 | **定价变现** | 调研 → CFO → 销售 → Munger → CEO |
| 5 | **每周复盘** | 运营 → 销售 → CFO → QA → CEO |
| 6 | **机会发现** | 调研 → CEO → Munger → CFO |

## 引导方向

AI 团队全自主运行，但你可以随时介入：

| 方式 | 操作 |
|------|------|
| **改方向** | 修改 `memories/consensus.md` 的 "Next Action" |
| **暂停** | `make pause`（macOS/WSL 守护模式）或 `.\scripts\windows\stop-win.ps1`（Windows 入口） |
| **恢复** | `make resume`，回到自主模式 |
| **审查产出** | 查看 `docs/*/`——每个 Agent 的工作成果 |

## 安全红线

写死在 `CLAUDE.md`，对所有 Agent 强制生效：
