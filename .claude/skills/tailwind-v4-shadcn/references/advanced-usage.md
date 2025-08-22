# Advanced Usage Patterns

**Purpose**: Advanced customization and component patterns for experienced Tailwind v4 + shadcn/ui developers
**When to Load**: User asks for custom colors beyond defaults, advanced component patterns, composition best practices, or component customization

---

## Custom Colors

Add new semantic colors beyond the default palette:

```css
:root {
  --brand: hsl(280 65% 60%);
  --brand-foreground: hsl(0 0% 100%);
}

.dark {
  --brand: hsl(280 75% 70%);
  --brand-foreground: hsl(280 20% 10%);
}

@theme inline {
  --color-brand: var(--brand);
  --color-brand-foreground: var(--brand-foreground);
}
```

**Usage:**
```tsx
<div className="bg-brand text-brand-foreground">Branded Component</div>
```

**Key Pattern**: Define CSS variable in `:root`/`.dark`, then reference in `@theme inline` with `--color-` prefix.

---

## Migration from Tailwind v3

For complete v3 → v4 migration steps, see `references/migration-guide.md`.

**Quick Summary**:
- Remove `tailwind.config.js` (v4 uses CSS configuration)
- Convert hardcoded colors to CSS variables
- Update plugin syntax: `require('tailwindcss/plugin')(plugin)` in v3 config → `@plugin "plugin-name"` in CSS
- Change Vite plugin: `require('tailwindcss')` or `import tailwindcss from 'tailwindcss'` in v3 → `import tailwindcss from '@tailwindcss/vite'` in v4

---

## Component Best Practices

### 1. Always Use Semantic Tokens

**✅ CORRECT:**
```tsx
<Button variant="destructive">Delete</Button>
```

**❌ WRONG:**
```tsx
<Button className="bg-red-600">Delete</Button>
```

**Why**: Semantic tokens (`destructive`, `primary`, `secondary`) adapt to theme changes. Hardcoded colors break dark mode and theme customization.

---

### 2. Use `cn()` for Conditional Styling

**Import:**
```tsx
import { cn } from "@/lib/utils"
```

**Usage:**
```tsx
<div className={cn(
  "base-class",
  isActive && "active-class",
  hasError && "error-class"
)} />
```

**What `cn()` does**: Merges Tailwind classes intelligently (later classes override earlier ones).

---
