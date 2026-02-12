# Cycle 004 Pilot Session Report (qa-bach)

## 测试环境
- 日期: 2026-02-12
- 仓库: `clone_win`
- 项目: `projects/ar-collections-assistant`
- 运行方式: `wrangler dev --local` + 本地 D1 (`--persist-to .wrangler/pilot-smoke`)
- 样例数据: `projects/ar-collections-assistant/sample/invoices.sample.csv`
- 一键脚本: `projects/ar-collections-assistant/scripts/pilot-smoke.sh`

## 可复现步骤与结果
1. 初始化本地 schema
- 命令: `npx wrangler d1 migrations apply ar-assistant-db --local --persist-to .wrangler/pilot-smoke`
- 结果: `0001_init.sql` 应用成功。

2. 启动本地服务
- 命令: `npx wrangler dev --local --port 8791 --persist-to .wrangler/pilot-smoke`
- 结果: 服务就绪 (`http://127.0.0.1:8791`)。

3. 初始化 defaults
- 请求: `POST /init-defaults`
- 结果: 成功（观察到 `200` 或 `303`，两者均可完成初始化）。

4. 导入 sample CSV
- 请求: `POST /import/csv`（multipart 上传 `sample/invoices.sample.csv`）
- 结果: `200`，导入完成；事件表新增 `invoice_imported=2`。

5. 跑 cadence
- 请求: `POST /cadence/run`
- 结果: 页面显示 `Cadence run complete`，`Drafts created: 2`，`Skipped: 0`。

6. Queue 审批与发送标记
- 请求: `POST /queue/:id/approve`（选择一条 pending draft）
- 请求: `POST /queue/:id/mark-sent`
- 结果: 均返回 `303`；状态分布校验为 `pending=1, approved=0, sent=1`；事件表包含 `draft_approved=1`, `email_marked_sent=1`。

7. send 可用性检查
- 条件: 未配置 `RESEND_API_KEY/RESEND_FROM_EMAIL`
- 结果: Queue 中未出现 `send (resend)` 按钮；首页显示 `resend: not configured`。

## 发现的问题（按严重度）
### 高危（High）
1. 审批闭环可被绕过（`mark-sent` 不要求先 approve）
- 复现:
  - 取一条 `pending` draft。
  - 直接调用 `POST /queue/:id/mark-sent`。
- 实际结果: 返回 `303` 并将该 draft 置为 `sent`，事件写入 `email_marked_sent`。
- 预期结果: 未审批 draft 不应允许进入 `sent`，应阻断并提示先审批。
- 影响: 核心流程控制失效，导致“未审批即出站/已发送”状态污染，影响审计与催收操作可信度。

### 中低风险
1. `POST /init-defaults` 返回码在不同状态下表现不一致（`200` vs `303`）
- 影响: 自动化脚本需兼容多返回码，增加回归脚本脆弱性。
- 说明: 功能本身可用，但建议统一语义（如全部 `303` 或全部 `200` + 明确页面状态）。

## 发布建议
- 结论: **NO-GO**（当前不建议进入首轮 pilot session）。
- 阻断条件:
  - 修复 `mark-sent` 的状态机约束，至少要求 `approved -> sent` 单向流转。
  - 增加对应回归测试（接口级 smoke 覆盖“pending 直达 sent 必须失败”）。
- 修复后建议复验:
  - 重新执行 `scripts/pilot-smoke.sh`。
  - 增补一条负向用例：pending draft 直接 mark-sent 应失败。

## 修复后复验（2026-02-12）
- 修复项已落地：
  - `POST /queue/:id/mark-sent` 仅允许 `approved` 状态。
  - `POST /queue/:id/send` 仅允许 `approved` 状态。
  - Queue UI 仅在 `approved` 状态展示 `mark sent` / `send (resend)`。
  - `scripts/pilot-smoke.sh` 新增负向用例：`pending -> mark-sent` 必须被阻断。
- 复验结果：
  - `npm run typecheck` 通过。
  - `bash ./scripts/pilot-smoke.sh` 通过（含负向用例）。
  - 关键断言通过：预审批 `mark-sent` 后 draft 仍为 `pending`。

### 复验结论
- 结论更新为：**GO with conditions**。
- 条件：
  - 远程 staging 部署仍需先完成 Cloudflare 登录与 staging D1 `database_id` 回填。
  - 首场外部 pilot 继续执行人工审批路径（`approve -> mark-sent`），并记录异常样本。
