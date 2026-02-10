---
role: command-reference
summary: |
  Complete reference for all websh commands. Navigation, query, process management,
  monitoring, environment, mounting, and more—treating the web as a Unix filesystem.
see-also:
  - shell.md: Shell semantics and execution model
  - state/cache.md: How cache is structured
---

# websh Command Reference

## Navigation Commands

### `cd <url>`

Navigate to a URL. Fetches the page, caches it, and spawns async extraction.

**Syntax:**
```
cd <url>
cd <relative-path>
cd -                 # go to previous location
cd ~                 # go to home/start (clears navigation)
```

**Examples:**
```
cd https://news.ycombinator.com
cd https://x.com/deepfates
cd /item?id=12345          # relative to current domain
cd ..                       # up one path level
cd -                        # back to previous URL
```

**Output:** Navigation confirmation, extraction status

---

### `pwd`

Print the current URL.

**Syntax:**
```
pwd
pwd -P               # show full resolved URL (no aliases)
```

**Output:** Full current URL or `(no page loaded)`

---

### `back`

Go back to the previous URL in navigation history.

**Syntax:**
```
back
back <n>             # go back n steps
```

**Behavior:** Uses cached content, no refetch.

---

### `forward`

Go forward in navigation history (after using `back`).

**Syntax:**
```
forward
forward <n>
```

---

### `follow <target>`

Navigate to a link on the current page.

**Syntax:**
```
follow <index>       # by number from ls output
follow "<text>"      # by link text (partial match)
follow -n            # follow without adding to history
```

**Examples:**
```
follow 3                    # follow the 4th link (0-indexed)
follow "State of AI"        # follow link containing this text
```

---

### `refresh`

Re-fetch the current URL, updating the cache.

**Syntax:**
```
refresh
refresh --hard       # clear extraction, start fresh
```

---

### `chroot <url>`

Restrict navigation to a subdomain or path prefix.

**Syntax:**
```
chroot <url>         # set root boundary
chroot               # show current chroot
chroot /             # clear chroot
```

**Example:**
```
chroot https://docs.python.org/3/
cd tutorial          # OK: within chroot
cd https://google.com # error: outside chroot
```

---

## Query Commands

### `ls [selector]`

List links or elements on the current page.

**Syntax:**
```
ls                   # list all links
ls <selector>        # list elements matching CSS selector
ls -l                # long format with hrefs
ls -a                # include hidden/navigation links
ls -t                # sort by position in page
ls -S                # sort by text length
```

**Output:**
```
[0] First link text
[1] Second link text
```

With `-l`:
```
[0] First link text → /path/to/page
[1] Second link text → https://external.com/
```

**Pipeable:** Yes

---

### `cat <selector>`

Extract text content from elements.

**Syntax:**
```
cat <selector>
cat .                # entire page text
cat -n               # with line numbers
cat -A               # show all (including hidden elements)
```

**Examples:**
```
cat .title
cat article
cat .comment | head 3
cat -n .code-block
```

**Pipeable:** Yes

---

### `grep <pattern>`

Filter content by text pattern (regex supported).

**Syntax:**
```
grep <pattern>
grep -i <pattern>    # case-insensitive
grep -v <pattern>    # invert match
grep -c <pattern>    # count matches
grep -n <pattern>    # show line numbers
grep -o <pattern>    # only matching part
grep -A <n>          # n lines after match
grep -B <n>          # n lines before match
grep -C <n>          # n lines context (before and after)
grep -E <pattern>    # extended regex
grep -l              # list pages with matches (for locate/find)
```

**Pipeable:** Yes (filters input stream or searches page)

---

### `stat`

Show metadata about the current page.

**Syntax:**
```
stat
stat -v              # verbose (all metadata)
```

**Output:**
```
URL:       https://news.ycombinator.com
Title:     Hacker News
Fetched:   2026-01-24T10:30:00Z
Extracted: 3 passes, complete
Links:     30
Forms:     2
Images:    0
Size:      45 KB (html), 12 KB (parsed)
```

---

### `head <n>` / `tail <n>`

Take first or last n items from a stream.

**Syntax:**
```
head <n>
head -n <n>          # same as head <n>
tail <n>
tail -f              # follow (for watch/stream)
```

**Pipeable:** Yes (must be in pipe or with file)

---

### `sort`

Sort lines of output.

**Syntax:**
```
sort                 # alphabetical
sort -n              # numeric
sort -r              # reverse
sort -u              # unique (remove duplicates)
sort -k <n>          # sort by nth field
sort -t <delim>      # field delimiter
```

**Pipeable:** Yes

---

### `uniq`

Remove duplicate lines.

**Syntax:**
```
uniq
uniq -c              # prefix with count
uniq -d              # only show duplicates
uniq -u              # only show unique
```

**Pipeable:** Yes

---

### `wc`

Count words, lines, characters.

**Syntax:**
```
wc                   # all counts
wc -l                # lines only
wc -w                # words only
wc -c                # characters only
wc -L                # longest line length
```

**Web-specific:**
```
wc --links           # count links
wc --images          # count images
wc --forms           # count forms
wc --headings        # count headings
```

**Pipeable:** Yes

---

### `cut`

Extract columns/fields from output.

**Syntax:**
```
cut -f <n>           # field n (1-indexed)
cut -f <n,m>         # fields n and m
cut -d <delim>       # delimiter (default: tab)
cut -c <range>       # character positions
```

**Example:**
```
ls -l | cut -f 1     # just link text, no URLs
```

**Pipeable:** Yes

---

### `tr`

Translate/transform characters.

**Syntax:**
```
tr <set1> <set2>     # replace set1 chars with set2
tr -d <set>          # delete characters
tr -s <set>          # squeeze repeated chars
tr '[:upper:]' '[:lower:]'  # lowercase
```

**Pipeable:** Yes

---

### `sed`

Stream editor for transformations.

**Syntax:**
```
sed 's/old/new/'     # replace first occurrence
sed 's/old/new/g'    # replace all
sed -n '5,10p'       # print lines 5-10
sed '/pattern/d'     # delete matching lines
```

**Pipeable:** Yes

---

### `source`

View raw HTML source.

**Syntax:**
```
source               # full HTML
source | head 50     # first 50 lines
source -l            # with line numbers
```

---

### `dom`

Show DOM tree structure.

**Syntax:**
```
dom                  # full tree
dom <selector>       # subtree from selector
dom -d <n>           # depth limit
dom --tags           # tag names only
```

**Output:**
```
html
├── head
│   ├── title
│   ├── meta
│   └── link
└── body
    ├── header
    │   └── nav
    ├── main
    │   ├── article
    │   └── aside
    └── footer
```

---

## Prefetching & Crawling

### `prefetch`

Control eager link crawling. By default, websh automatically prefetches visible links 1-2 layers deep in the background after you navigate to a page.

**Syntax:**
```
prefetch                     # show status
prefetch on                  # enable eager crawl
prefetch off                 # disable eager crawl
prefetch <url>               # manually prefetch a URL
prefetch --depth <n>         # set crawl depth (default: 2)
prefetch --stop              # stop current crawl
```

**Examples:**
```
prefetch                     # check crawl progress
prefetch off                 # disable for slow connections
prefetch https://example.com # manually queue URL
```

**Status output:**
```
Eager crawl: enabled
Depth: 2, Same domain: yes, Max per page: 20

Current crawl:
  Origin: https://news.ycombinator.com
  Progress: Layer 1 - 15/20 complete
  Queued: 42 URLs for Layer 2
```

---

### `crawl`

Explicitly crawl a URL to a specified depth.

**Syntax:**
```
crawl <url>                  # crawl from URL
crawl --depth <n>            # depth (default: 2)
crawl --all                  # include external links
crawl --follow <pattern>     # only follow matching URLs
crawl --max <n>              # max pages to fetch
```

**Examples:**
```
crawl https://docs.example.com --depth 3
crawl https://api.example.com --follow "/docs/*"
crawl https://blog.com --max 50
```

**Difference from prefetch:**
- `prefetch` is automatic and runs in background after `cd`
- `crawl` is manual and can go deeper / wider

---

### `queue`

Show the crawl queue.

**Syntax:**
```
queue                        # show queue status
queue -l                     # long format with all URLs
queue --clear                # clear pending queue
```

**Output:**
```
In progress: 3
  [→] https://hn.com/item?id=123 (extracting)
  [→] https://hn.com/item?id=124 (fetching)
  [→] https://hn.com/item?id=125 (fetching)

Queued: 17
  [0] https://hn.com/item?id=126 (depth 1)
  [1] https://hn.com/item?id=127 (depth 1)
  ...

Completed: 12
Skipped: 5 (external/cached)
```

---

## Search & Discovery

### `find <pattern>`

Recursively search/crawl from current page.

**Syntax:**
```
find <text-pattern>              # search page content
find -name "<pattern>"           # search link text
find -href "<pattern>"           # search URLs
find -selector "<css>"           # find elements
find -depth <n>                  # crawl n levels deep
find -maxpages <n>               # limit pages to crawl
find -type <t>                   # filter: link, image, form, heading
find -follow                     # actually fetch found pages
```

**Examples:**
```
find "API documentation"                    # find text across linked pages
find -name "*.pdf" -depth 2                # find PDF links, 2 levels deep
find -selector "form" -depth 1             # find all forms on this + linked pages
find -href "/api/" -follow                 # crawl all /api/ pages
```

**Output:** List of matches with source page

---

### `locate <term>`

Instant search across ALL cached pages.

**Syntax:**
```
locate <pattern>
locate -i <pattern>  # case-insensitive
locate -r <regex>    # regex mode
locate --urls        # search URLs only
locate --titles      # search titles only
```

**Example:**
```
locate "authentication"    # find in all cached content
locate -i "OAuth"          # case-insensitive
```

**Output:**
```
news-ycombinator-com: [3 matches]
  - "OAuth authentication flow..."
  - "...using authentication tokens..."
techcrunch-com-article: [1 match]
  - "...new authentication method..."
```

---

### `tree`

Show site structure.

**Syntax:**
```
tree                 # from current page
tree -d <n>          # depth limit
tree -L <n>          # same as -d
tree --sitemap       # use sitemap.xml if available
tree --infer         # infer from links
tree -P <pattern>    # only matching paths
```

**Output:**
```
https://example.com/
├── /about
├── /products
│   ├── /products/widget
│   └── /products/gadget
├── /blog
│   ├── /blog/post-1
│   └── /blog/post-2
└── /contact
```

---

### `which <link>`

Resolve where a link actually goes (follow redirects).

**Syntax:**
```
which <url>
which <index>        # from ls output
which -a             # show all redirects in chain
```

**Output:**
```
https://bit.ly/xyz → https://example.com/actual-page
```

With `-a`:
```
https://bit.ly/xyz
  → https://example.com/redirect
  → https://example.com/actual-page (200 OK)
```

---

## Comparison & Diff

### `diff`

Compare pages or versions.

**Syntax:**
```
diff <url1> <url2>           # compare two URLs
diff <url>                   # compare current vs URL
diff -c                      # context format
diff -u                      # unified format
diff --side-by-side          # side by side
diff --links                 # compare only links
diff --text                  # compare only text content
```

**Time-based:**
```
diff -t <duration>           # compare to cached version from <duration> ago
diff --wayback <date>        # compare to Wayback Machine snapshot
```

**Examples:**
```
diff https://a.com https://b.com
diff -t 1h                   # compare to 1 hour ago
diff --wayback 2024-01-01    # compare to Wayback snapshot
```

---

### `patch`

Apply changes (for APIs with write access).

**Syntax:**
```
patch <file>         # apply diff file
```

*Note: Requires mounted API with write permissions.*

---

## Monitoring

### `watch`

Monitor URL for changes.

**Syntax:**
```
watch <url>                  # poll every 60s
watch -n <seconds>           # custom interval
watch -d                     # highlight differences
watch --notify               # system notification on change
watch --exec <cmd>           # run command on change
watch --selector <css>       # only watch specific element
```

**Examples:**
```
watch https://status.example.com -n 30
watch -d --selector ".price"
watch --notify --exec "echo 'Changed!'"
```

**Output:** Shows content, updates in place, highlights changes

---

### `tail -f <url>`

Stream live content (for SSE, websocket, or polling).

**Syntax:**
```
tail -f <url>                # stream updates
tail -f --sse                # Server-Sent Events
tail -f --ws                 # WebSocket
tail -f --poll <n>           # poll every n seconds
```

---

### `ping`

Check if site is up.

**Syntax:**
```
ping <url>
ping -c <n>          # count of pings
ping -i <seconds>    # interval
```

**Output:**
```
PING https://example.com
200 OK - 145ms
200 OK - 132ms
200 OK - 156ms
--- 3 requests, avg 144ms ---
```

---

### `traceroute`

Show redirect chain.

**Syntax:**
```
traceroute <url>
```

**Output:**
```
1. https://short.link/abc (301)
2. https://example.com/redirect (302)
3. https://example.com/final (200)
```

---

### `time`

Measure command execution time.

**Syntax:**
```
time <command>
```

**Output:**
```
[command output]

real    0.45s
fetch   0.32s
extract 0.13s
```

---

## Process & Job Management

### `ps`

Show running background tasks.

**Syntax:**
```
ps                   # list all tasks
ps -l                # long format
ps -a                # all (including completed)
```

**Output:**
```
PID   STATUS      URL/TASK
1     extracting  news-ycombinator-com
2     fetching    x-com-deepfates
3     watching    status.example.com
```

---

### `jobs`

List background jobs.

**Syntax:**
```
jobs
jobs -l              # with PIDs
jobs -r              # running only
jobs -s              # stopped only
```

**Output:**
```
[1]  + running     cd https://example.com &
[2]  - extracting  follow 3 &
[3]    watching    watch https://status.com
```

---

### `kill`

Cancel a background task.

**Syntax:**
```
kill <pid>
kill %<job-number>
kill -9 <pid>        # force kill
killall watch        # kill all watch processes
```

---

### `wait`

Wait for background task to complete.

**Syntax:**
```
wait                 # wait for all
wait <pid>           # wait for specific
wait %<job>          # wait for job number
```

---

### `bg` / `fg`

Move jobs to background/foreground.

**Syntax:**
```
bg %<job>            # continue job in background
fg %<job>            # bring job to foreground
```

---

### `&` (background operator)

Run command in background.

**Syntax:**
```
cd https://example.com &
watch https://status.com &
```

---

### `nohup`

Run command immune to hangups.

**Syntax:**
```
nohup watch https://example.com &
```

---

## Environment & Auth

### `env`

Show current environment (headers, cookies, settings).

**Syntax:**
```
env                  # all variables
env | grep COOKIE    # filter
```

**Output:**
```
USER_AGENT=websh/1.0
ACCEPT=text/html
COOKIE_session=abc123
HEADER_Authorization=Bearer xyz
TIMEOUT=30
RATE_LIMIT=10/min
```

---

### `export`

Set environment variable (headers, cookies).

**Syntax:**
```
export VAR=value
export HEADER_X-Custom=value
export COOKIE_session=abc123
export USER_AGENT="Custom Agent"
export TIMEOUT=60
```

**Examples:**
```
export HEADER_Authorization="Bearer mytoken"
export COOKIE_session="abc123"
export USER_AGENT="Mozilla/5.0..."
```

**Crawl settings:**
```
export EAGER_CRAWL=true              # enable/disable prefetching
export CRAWL_DEPTH=2                 # layers deep to prefetch
export CRAWL_SAME_DOMAIN=true        # only prefetch same-domain links
export CRAWL_MAX_PER_PAGE=20         # max links per page
export CRAWL_MAX_CONCURRENT=5        # parallel fetches
export CRAWL_DELAY_MS=200            # rate limit delay
```

---

### `unset`

Remove environment variable.

**Syntax:**
```
unset VAR
unset HEADER_Authorization
unset COOKIE_session
```

---

### `whoami`

Show logged-in identity (if detectable).

**Syntax:**
```
whoami
whoami -v            # verbose (show how detected)
```

**Output:**
```
@deepfates (detected from: meta tag, cookie)
```

Or:
```
(not logged in)
