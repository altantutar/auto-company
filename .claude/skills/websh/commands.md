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

