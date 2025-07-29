---
role: crawl-management
summary: |
  Eager link crawling for websh. After fetching a page, automatically prefetch
  linked pages 1-2 layers deep in background. Makes navigation feel instant.
see-also:
  - cache.md: Cache structure
  - ../shell.md: Shell semantics
  - ../commands.md: Command reference
---

# websh Eager Crawl

When you `cd` to a URL, websh can automatically prefetch linked pages in the background. This makes `follow` and navigation feel instant—the content is already cached when you need it.

---

## How It Works

```
┌────────────────────────────────────────────────────────────┐
│                                                            │
│   cd https://news.ycombinator.com                         │
│         │                                                  │
│         ▼                                                  │
│   ┌───────────────┐                                       │
│   │ Fetch + Extract│  ← Background haiku (existing)       │
│   │ the main page  │                                      │
│   └───────┬───────┘                                       │
│           │ After Pass 1 (links identified)               │
│           ▼                                                │
│   ┌───────────────┐                                       │
│   │ Spawn Eager   │  ← New background haiku               │
│   │ Crawl Agent   │                                       │
│   └───────┬───────┘                                       │
│           │                                                │
│           ▼                                                │
│   For each link (prioritized, rate-limited):             │
│   ┌───────────────┐                                       │
│   │ Fetch + Extract│  ← Parallel background tasks          │
│   │ linked page    │                                       │
│   └───────┬───────┘                                       │
│           │ If depth < max_depth                          │
│           ▼                                                │
│   Queue its links for next layer...                       │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

The user gets their prompt back immediately. All crawling happens async.

---

## Crawl Settings

Stored in `.websh/session.md` under Environment:

```markdown
## Environment

EAGER_CRAWL: true
CRAWL_DEPTH: 2
CRAWL_SAME_DOMAIN: true
CRAWL_MAX_PER_PAGE: 20
CRAWL_MAX_CONCURRENT: 5
CRAWL_DELAY_MS: 200
```

### Setting Descriptions

| Variable | Default | Description |
|----------|---------|-------------|
| `EAGER_CRAWL` | `true` | Enable/disable eager crawling |
| `CRAWL_DEPTH` | `2` | How many layers deep to prefetch |
| `CRAWL_SAME_DOMAIN` | `true` | Only crawl same-domain links |
| `CRAWL_MAX_PER_PAGE` | `20` | Max links to prefetch per page |
| `CRAWL_MAX_CONCURRENT` | `5` | Max simultaneous fetches |
| `CRAWL_DELAY_MS` | `200` | Delay between requests (rate limit) |

### Changing Settings

```
export EAGER_CRAWL=false           # disable eager crawl
export CRAWL_DEPTH=3               # go 3 layers deep
export CRAWL_SAME_DOMAIN=false     # include external links
prefetch off                       # shortcut to disable
prefetch on --depth 3              # enable with depth 3
```

---

## Crawl Queue

Track in `.websh/crawl-queue.md`:

```markdown
# websh crawl queue

## Active Crawl

origin: https://news.ycombinator.com
started: 2026-01-24T10:30:00Z
depth: 2
same_domain: true

## In Progress

| Slug | URL | Depth | Status |
|------|-----|-------|--------|
| news-ycombinator-com-item-id-41234567 | https://news.ycombinator.com/item?id=41234567 | 1 | extracting |
| news-ycombinator-com-item-id-41234568 | https://news.ycombinator.com/item?id=41234568 | 1 | fetching |

## Queued

| URL | Depth | Priority |
|-----|-------|----------|
| https://news.ycombinator.com/item?id=41234569 | 1 | 2 |
| https://news.ycombinator.com/item?id=41234570 | 1 | 3 |
...

## Completed

| Slug | URL | Depth | Links Found |
|------|-----|-------|-------------|
| news-ycombinator-com | https://news.ycombinator.com | 0 | 30 |

## Skipped

| URL | Reason |
|-----|--------|
| https://external.com/article | external (same_domain=true) |
| https://news.ycombinator.com/login | already cached |
```

---

## Priority Algorithm

Links are prioritized for crawling:

1. **Position on page** — Links appearing earlier get higher priority
2. **Same domain** — Internal links before external
3. **Content signals** — Links in main content > nav/footer
4. **Avoid duplicates** — Skip already-cached URLs
5. **Skip non-content** — Ignore login, logout, settings, etc.

### Link Scoring

```python
