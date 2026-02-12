# Windows + WSL Setup Guide

本项目在 Windows 上采用：

- Windows PowerShell 作为控制入口
- WSL2 (Ubuntu + systemd) 作为执行内核
- WSL `systemd --user` 提供守护与崩溃自拉起
- Windows `scripts/windows/awake-guardian-win.ps1` 提供运行时防睡眠
- Windows `scripts/windows/wsl-anchor-win.ps1` 提供 WSL 会话保活（防止空闲退出）

## 1. 一次性安装（WSL 内）

在 Ubuntu 终端执行：

```bash
sudo apt update
sudo apt install -y make jq curl

# 安装 Node.js（推荐 LTS）
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# 安装 Codex CLI
npm install -g @openai/codex
```

## 2. 一次性自检（WSL 内）

```bash
make --version
codex --version
jq --version
systemctl --user --version
ps -p 1 -o comm=
```

判定标准：
- `systemctl --user --version` 成功
- `ps -p 1 -o comm=` 输出 `systemd`

建议额外检查 Codex 路径：

```bash
bash -lc 'command -v codex; codex --version'
bash -ic 'command -v codex; codex --version'
```

应优先命中 WSL 本地路径（`/home/<user>/...`），避免 `/mnt/c/...`。

建议一次性启用 linger（提高 user service 持续性）：

```powershell
wsl -d Ubuntu -u root loginctl enable-linger max
```

## 3. 前置事项（每次开始前）

1. 只在 `clone_win/` 运行与提交，`clone/` 仅留档。
2. WSL 内 `make`、`codex`、`jq`、`systemctl --user` 可用。
3. `codex` 在 WSL 内已登录且可用。
4. 建议确认 `codex` 路径优先是 WSL 本地路径（`/home/...`）。

可选快速检查（PowerShell）：

```powershell
wsl -d Ubuntu bash -lc 'make --version; codex --version; jq --version; systemctl --user --version'
wsl -d Ubuntu bash -lc 'command -v codex'
```

## 4. 推荐操作（标准）

在 `clone_win` 目录运行：

```powershell
.\scripts\windows\start-win.ps1 -CycleTimeoutSeconds 1800 -LoopInterval 30
.\scripts\windows\status-win.ps1
.\scripts\windows\monitor-win.ps1
.\scripts\windows\last-win.ps1
.\scripts\windows\cycles-win.ps1
.\scripts\windows\stop-win.ps1
.\scripts\windows\dashboard-win.ps1
```

说明：
- `.\scripts\windows\start-win.ps1` 会写入 `.auto-loop.env`，并启动 `auto-company.service` + `awake guardian` + `wsl anchor`
- `.\scripts\windows\stop-win.ps1` 会停止 `auto-company.service` 并关闭 `awake guardian` + `wsl anchor`
- `.\scripts\windows\dashboard-win.ps1` 会启动本地 Web 看板（默认 `http://127.0.0.1:8787`）

推荐参数：
- `CycleTimeoutSeconds`：`900-1800`
- `LoopInterval`：`30-60`

脚本定位说明：
- 所有脚本实现位于 `scripts/windows/`、`scripts/core/`、`scripts/wsl/`、`scripts/macos/`
- 日常执行入口也统一使用 `scripts/` 下脚本
- 如需维护逻辑，请直接修改 `scripts/` 下对应实现文件

## 5. 可选：登录后自启

默认不启用。需要时执行：

```powershell
.\scripts\windows\enable-autostart-win.ps1
.\scripts\windows\autostart-status-win.ps1
```

关闭：

```powershell
.\scripts\windows\disable-autostart-win.ps1
```

自启任务名：`AutoCompany-WSL-Start`（触发器：At logon）。
若提示 `Access is denied`，请使用管理员 PowerShell 重新执行。

## 6. Chat-first 模式（只和 Codex 对话）

如果你不想手动执行命令，可直接在 Windows 里和 Codex 对话，让 Codex 代你操作。

底层链路：

`scripts/windows/start-win.ps1` -> WSL `systemd --user` -> `scripts/core/auto-loop.sh`

与手动命令的核心行为一致，差异只在入口方式。

## 7. 常见问题

### `bad interpreter: /bin/bash^M`

- 原因：文件是 CRLF
- 处理：

```bash
git config core.autocrlf false
git config core.eol lf
```

### `codex: node not found`

- 原因：WSL 中缺 Node/Codex
- 处理：回到第 1 步重新安装

### `systemctl --user` 不可用

- 原因：WSL 未启用 systemd 或会话未正确初始化
- 处理：
  - 先确认 `ps -p 1 -o comm=` 是 `systemd`
  - 再验证 `systemctl --user --version`
  - 必要时重开 WSL 会话后重试

### `status` 显示 Codex bin 在 `/mnt/c/...`

- 原因：PATH 先命中 Windows 侧 codex
- 影响：版本和行为可能与 WSL 本地终端不一致
- 处理：在 WSL 内安装并优先使用本地 Codex（`/home/<user>/...`）

### `clone/` 在 WSL 下 `git status` 显示大量修改

- 原因：`clone/` 作为留档目录，可能受 CRLF/LF 差异影响。
- 结论：如果你只在 `clone_win/` 开发，这些状态可忽略。
- 要求：
  - 不在 `clone/` 提交代码。
  - 只在 `clone_win/` 目录开发和提交。

### guardian 启动失败

- 现象：`scripts/windows/start-win.ps1` 提示 daemon 已启动，但 guardian 启动失败并返回非零
- 处理：先执行 `.\scripts\windows\status-win.ps1` 确认服务状态，再手动执行 `.\scripts\windows\awake-guardian-win.ps1 -Action start`

### 频繁出现 `Cycle #1 START` 且伴随 `Auto Loop Shutting Down`

- 原因：WSL 会话被回收（常见于 linger 未开启或缺少 keepalive）
- 处理：
  - 确认 `wsl-anchor` 为 RUNNING：`.\scripts\windows\status-win.ps1`
  - 一次性启用 linger：`wsl -d Ubuntu -u root loginctl enable-linger max`
  - 重启服务：`.\scripts\windows\stop-win.ps1` 然后 `.\scripts\windows\start-win.ps1`

### 自启脚本提示 `Access is denied`

- 原因：当前 PowerShell 权限不足以写入计划任务
- 处理：使用管理员 PowerShell 执行：
  - `.\scripts\windows\enable-autostart-win.ps1`
  - `.\scripts\windows\disable-autostart-win.ps1`
