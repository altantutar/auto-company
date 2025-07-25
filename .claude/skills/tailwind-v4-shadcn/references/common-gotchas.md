# Common Gotchas & Solutions

## Critical Failures (Will Break Your Build)

### 1. `:root` Inside `@layer base`

❌ **WRONG:**
```css
@layer base {
  :root {
    --background: hsl(0 0% 100%);
  }
}
```

✅ **CORRECT:**
```css
:root {
  --background: hsl(0 0% 100%);
}

@layer base {
  body {
    background-color: var(--background);
  }
}
```

**Why:** Tailwind v4 strips CSS outside `@theme`/`@layer`, but `:root` must be at root level.

---

### 2. Nested `@theme` Directive

❌ **WRONG:**
```css
@theme {
  --color-primary: hsl(0 0% 0%);
}

.dark {
  @theme {
    --color-primary: hsl(0 0% 100%);
  }
}
```

✅ **CORRECT:**
```css
:root {
  --primary: hsl(0 0% 0%);
}

.dark {
  --primary: hsl(0 0% 100%);
}

@theme inline {
  --color-primary: var(--primary);
}
```

**Why:** Tailwind v4 doesn't support `@theme` inside selectors.

---

### 3. Double `hsl()` Wrapping

❌ **WRONG:**
```css
@layer base {
  body {
    background-color: hsl(var(--background));
  }
}
```

✅ **CORRECT:**
```css
@layer base {
  body {
    background-color: var(--background);  /* Already has hsl() */
  }
}
```

**Why:** Variables already contain `hsl()`, double-wrapping creates `hsl(hsl(...))`.

---

### 4. Colors in `tailwind.config.ts`

❌ **WRONG:**
```typescript
// tailwind.config.ts
export default {
  theme: {
    extend: {
      colors: {
        primary: 'hsl(var(--primary))'
      }
    }
  }
}
```

✅ **CORRECT:**
```typescript
// Delete tailwind.config.ts entirely OR leave it empty
export default {}

// components.json
{
  "tailwind": {
    "config": ""  // ← Empty string
  }
}
```

**Why:** Tailwind v4 completely ignores `theme.extend.colors`.

---

### 5. Missing `@theme inline` Mapping

❌ **WRONG:**
```css
:root {
  --background: hsl(0 0% 100%);
}

/* No @theme inline block */
```

Result: `bg-background` class doesn't exist

✅ **CORRECT:**
```css
:root {
  --background: hsl(0 0% 100%);
}

@theme inline {
  --color-background: var(--background);
}
```

**Why:** `@theme inline` generates the utility classes.

---

## Configuration Gotchas

### 6. Wrong components.json Config

❌ **WRONG:**
```json
