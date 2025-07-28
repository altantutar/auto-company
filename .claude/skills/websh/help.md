---
role: user-documentation
summary: |
  User-facing help for websh. Quick start, full command cheatsheet, examples.
---

# websh Help

A Unix-like shell for the web. Navigate URLs like directories, query pages with familiar commands.

## Quick Start

```
websh                                # start the shell
ls                                   # shows suggested sites
go hn                                # go to Hacker News (preset bookmark)
ls | head 5                          # first 5 links
grep "AI"                            # search for text
follow 1                             # click the 2nd link
cat .title                           # extract text by selector
back                                 # go back
```

## Starter Bookmarks

websh comes with bookmarks for interesting public sites:

| Shortcut | Site |
|----------|------|
| `go hn` | Hacker News |
| `go lobsters` | Lobsters |
| `go tildes` | Tildes |
| `go wiby` | Wiby (indie search) |
| `go marginalia` | Marginalia (indie search) |
| `go wiki` | Wikipedia |
| `go sourcehut` | Sourcehut |
| `go arena` | Are.na |

Add your own with `bookmark <name>`.

---

## Command Cheatsheet

### Navigation

| Command | Description |
|---------|-------------|
| `cd <url>` | Go to URL |
| `cd -` | Go to previous URL |
| `cd ~` | Go to start (clear navigation) |
| `pwd` | Show current URL |
| `back` / `forward` | Navigate history |
| `follow <n>` | Follow nth link |
| `follow "text"` | Follow link containing text |
| `refresh` | Re-fetch current page |
| `chroot <url>` | Restrict navigation to URL prefix |

### Query & Extract

| Command | Description |
|---------|-------------|
| `ls` | List all links |
| `ls -l` | List with URLs |
| `ls <selector>` | List elements matching selector |
| `cat <selector>` | Extract text content |
| `grep <pattern>` | Search/filter by pattern |
| `grep -i` | Case-insensitive |
| `grep -v` | Invert match |
| `stat` | Show page metadata |
| `source` | View raw HTML |
| `dom` | Show DOM tree |

### Prefetching

| Command | Description |
|---------|-------------|
| `prefetch` | Show crawl status |
| `prefetch on/off` | Enable/disable eager crawl |
| `prefetch <url>` | Manually prefetch a URL |
| `prefetch --depth <n>` | Set prefetch depth |
| `crawl <url>` | Explicit deep crawl |
| `queue` | Show crawl queue |

### Search & Discovery

| Command | Description |
|---------|-------------|
| `find <pattern>` | Recursive search/crawl |
| `find -depth <n>` | Crawl n levels deep |
| `locate <term>` | Search all cached pages |
| `tree` | Show site structure |
| `which <link>` | Resolve redirects |

### Text Processing

| Command | Description |
|---------|-------------|
| `head <n>` | First n items |
| `tail <n>` | Last n items |
| `sort` | Sort output |
| `sort -r` | Reverse sort |
| `uniq` | Remove duplicates |
| `wc` | Count lines/words |
| `wc --links` | Count links |
| `cut -f <n>` | Extract field |
| `tr` | Transform characters |
| `sed 's/a/b/'` | Stream edit |

### Comparison

| Command | Description |
|---------|-------------|
| `diff <url1> <url2>` | Compare two pages |
| `diff -t 1h` | Compare to 1 hour ago |
| `diff --wayback <date>` | Compare to Wayback snapshot |

### Monitoring

| Command | Description |
|---------|-------------|
| `watch <url>` | Monitor for changes |
| `watch -n 30` | Poll every 30 seconds |
| `watch --notify` | System notification on change |
| `ping <url>` | Check if site is up |
| `traceroute <url>` | Show redirect chain |
| `time <cmd>` | Measure execution time |

### Jobs & Background

| Command | Description |
|---------|-------------|
| `<cmd> &` | Run in background |
| `ps` | Show running tasks |
| `jobs` | List background jobs |
| `fg %<n>` | Bring job to foreground |
| `bg %<n>` | Continue in background |
| `kill %<n>` | Cancel job |
| `wait` | Wait for all jobs |

### Environment & Auth

| Command | Description |
|---------|-------------|
| `env` | Show environment |
| `export VAR=val` | Set variable |
| `export HEADER_X=val` | Set request header |
| `export COOKIE_x=val` | Set cookie |
| `unset VAR` | Remove variable |
| `whoami` | Show logged-in identity |
