---
name: github-explorer
description: >
  Deep-dive analysis of GitHub projects. Use when the user mentions a GitHub repo/project name
  and wants to understand it — triggered by phrases like "帮我看看这个项目", "了解一下 XXX",
  "这个项目怎么样", "分析一下 repo", or any request to explore/evaluate a GitHub project.
  Covers architecture, community health, competitive landscape, and cross-platform knowledge sources.
---

# GitHub Explorer — 项目深度分析

> **Philosophy**: README 只是门面，真正的价值藏在 Issues、Commits 和社区讨论里。

## Workflow

```
[项目名] → [1. 定位 Repo] → [2. 多源采集] → [3. 分析研判] → [4. 结构化输出]
```

### Phase 1: 定位 Repo

- 用 `web_search` 搜索 `site:github.com <project_name>` 确认完整 org/repo
- 用 `search-layer`（Deep 模式 + 意图感知）补充获取社区链接和非 GitHub 资源：
  ```bash
  python3 skills/search-layer/scripts/search.py \
    --queries "<project_name> review" "<project_name> 评测 使用体验" \
    --mode deep --intent exploratory --num 5
  ```
- 用 `web_fetch` 抓取 repo 主页获取基础信息（README、Stars、Forks、License、最近更新）

### Phase 2: 多源采集（并行）

以下来源**按需检查**，有则采集，无则跳过：

| 来源 | URL 模式 | 采集内容 | 建议工具 |
|---|---|---|---|
| GitHub Repo | `github.com/{org}/{repo}` | README、About、Contributors | `web_fetch` |
| GitHub Issues | `github.com/{org}/{repo}/issues?q=sort:comments` | Top 3-5 高质量 Issue | `browser` |
| 中文社区 | 微信/知乎/小红书 | 深度评测、使用经验 | `content-extract` |
| 技术博客 | Medium/Dev.to | 技术架构分析 | `web_fetch` / `content-extract` |
| 讨论区 | V2EX/Reddit | 用户反馈、槽点 | `search-layer`（Deep 模式） |

#### search-layer 调用规范

search-layer v2 支持意图感知评分。github-explorer 场景下的推荐用法：

| 场景 | 命令 | 说明 |
|------|------|------|
| **项目调研（默认）** | `python3 skills/search-layer/scripts/search.py --queries "<project> review" "<project> 评测" --mode deep --intent exploratory --num 5` | 多查询并行，按权威性排序 |
| **最新动态** | `python3 skills/search-layer/scripts/search.py "<project> latest release" --mode deep --intent status --freshness pw --num 5` | 优先新鲜度，过滤一周内 |
| **竞品对比** | `python3 skills/search-layer/scripts/search.py --queries "<project> vs <competitor>" "<project> alternatives" --mode deep --intent comparison --num 5` | 对比意图，关键词+权威双权重 |
| **快速查链接** | `python3 skills/search-layer/scripts/search.py "<project> official docs" --mode fast --intent resource --num 3` | 精确匹配，最快 |
| **社区讨论** | `python3 skills/search-layer/scripts/search.py "<project> discussion experience" --mode deep --intent exploratory --domain-boost reddit.com,news.ycombinator.com --num 5` | 加权社区站点 |

**意图类型速查**：`factual`(事实) / `status`(动态) / `comparison`(对比) / `tutorial`(教程) / `exploratory`(探索) / `news`(新闻) / `resource`(资源定位)

> 不带 `--intent` 时行为与 v1 完全一致（无评分，按原始顺序输出）。

降级规则：Exa/Tavily 任一 429/5xx → 继续用剩余源；脚本整体失败 → 退回 `web_search` 单源。

---

### 抓取降级与增强协议 (Extraction Upgrade)

当遇到以下情况时，**必须**从 `web_fetch` 升级为 `content-extract`：
1. **域名限制**: `mp.weixin.qq.com`, `zhihu.com`, `xiaohongshu.com`。
2. **结构复杂**: 页面包含大量公式 (LaTeX)、复杂表格、或 `web_fetch` 返回的 Markdown 极其凌乱。
3. **内容缺失**: `web_fetch` 因反爬返回空内容或 Challenge 页面。

调用方式：
```bash
python3 skills/content-extract/scripts/content_extract.py --url <URL>
```

content-extract 内部会：
- 先检查域名白名单（微信/知乎等），命中则直接走 MinerU
- 否则先用 `web_fetch` 探针，失败再 fallback 到 MinerU-HTML
- 返回统一 JSON 合同（含 `ok`, `markdown`, `sources` 等字段）

### Phase 3: 分析研判

基于采集数据进行判断：

- **项目阶段**: 早期实验 / 快速成长 / 成熟稳定 / 维护模式 / 停滞（基于 commit 频率和内容）
- **精选 Issue 标准**: 评论数多、maintainer 参与、暴露架构问题、或包含有价值的技术讨论
- **竞品识别**: 从 README 的 "Comparison"/"Alternatives" 章节、Issues 讨论、以及 web 搜索中提取

### Phase 4: 结构化输出

严格按以下模板输出，**每个模块都必须有实质内容或明确标注"未找到"**。

#### 排版规则（强制）

1. **标题必须链接到 GitHub 仓库**（格式：`# [Project Name](https://github.com/org/repo)`，确保可点击跳转）
2. **标题前后都统一空行**（上一板块结尾 → 空行 → 标题 → 空行 → 内容，确保视觉分隔清晰）
3. **Telegram 空行修复（强制）**：Telegram 会吞掉列表项（`-` 开头）后面的空行。解决方案：在列表末尾与下一个标题之间，插入一行盲文空格 `⠀`（U+2800），格式如下：
   ```
   - 列表最后一项

   ⠀
   **下一个标题**
   ```
   这确保在 Telegram 渲染时标题前的空行不被吞掉。
2. **所有标题加粗**（emoji + 粗体文字）
3. **竞品对比必须附链接**（GitHub / 官网 / 文档，至少一个）
4. **社区声量必须具体**：引用具体的帖子/推文/讨论内容摘要，附原始链接。不要写"评价很高"、"热度很高"这种概括性描述，要写"某某说了什么"或"某帖讨论了什么具体问题"
