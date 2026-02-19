# Yield Router: Visual Design Specification

**Author:** ui-duarte (UI Design Director)
**Date:** 2026-02-19
**Status:** FINAL -- Ready for Frontend Engineer (fullstack-dhh)
**Predecessors:** interaction-cooper UX spec, defi-kulechov product spec, pipeline-replay visual reference
**Design System:** Synapse (adapted for DeFi financial application)

---

## 0. Design Philosophy

This document translates the Synapse design system into a complete visual specification for Yield Router's landing page and dApp. Every decision here serves one principle inherited from interaction-cooper: **trust is the interaction.**

The visual language must accomplish three things simultaneously:

1. **Signal financial seriousness.** This is not a meme coin dashboard. The visual tone is closer to a Bloomberg terminal reimagined for the dark-mode web than to a neon DeFi swap interface. Instrument Serif headlines carry the weight of a financial institution. The vantablack background recedes, letting data and content advance.

2. **Reduce cognitive load through hierarchy.** Maya (primary persona) should never have to scan the page to find what matters. Visual hierarchy through size, weight, color, and spacing tells her eyes exactly where to look. One headline number per screen. One primary action per view.

3. **Earn trust through restraint.** No gradients on backgrounds. No particle effects. No animated borders for decoration. Every visual element has a reason. When something moves, it communicates information. When something glows, it indicates a live state. The interface earns trust by being quiet, precise, and honest.

---

## 1. Design Tokens

### 1.1 Color Palette

#### Surface Colors

| Token | Value | Usage |
|-------|-------|-------|
| `--surface-base` | `#030303` | Page background. Vantablack. |
| `--surface-raised` | `rgba(10, 10, 10, 0.7)` | Cards, panels, modals. Always with `backdrop-filter: blur(16px)`. |
| `--surface-raised-hover` | `rgba(14, 14, 14, 0.8)` | Hovered cards and interactive panels. |
| `--surface-overlay` | `rgba(3, 3, 3, 0.94)` | Full-screen overlays (wallet modal backdrop). With `backdrop-filter: blur(40px)`. |
| `--surface-input` | `rgba(255, 255, 255, 0.03)` | Input field backgrounds. |
| `--surface-input-focus` | `rgba(255, 255, 255, 0.05)` | Focused input field backgrounds. |

#### Border Colors

| Token | Value | Usage |
|-------|-------|-------|
| `--border-default` | `rgba(255, 255, 255, 0.06)` | Default card/panel borders. |
| `--border-subtle` | `rgba(255, 255, 255, 0.04)` | Dividers inside cards (e.g., footer separator). |
| `--border-hover` | `rgba(255, 255, 255, 0.10)` | Hovered card borders. |
| `--border-focus` | `rgba(139, 92, 246, 0.5)` | Focused input borders (violet). |
| `--border-active` | `rgba(139, 92, 246, 0.4)` | Active/processing state borders. |

#### Text Colors

| Token | Value | Usage |
|-------|-------|-------|
| `--text-primary` | `#FFFFFF` | Headlines, primary numbers, wallet address. |
| `--text-secondary` | `rgba(255, 255, 255, 0.7)` | Body text, descriptions, secondary info. |
| `--text-tertiary` | `rgba(255, 255, 255, 0.4)` | Labels, captions, timestamps. |
| `--text-muted` | `rgba(255, 255, 255, 0.3)` | Disabled text, placeholder text. |

#### Accent Colors (Semantic)

| Token | Value | CSS Variable | Usage |
|-------|-------|-------------|-------|
| `--accent-primary` | `#8B5CF6` | Violet | Primary actions (Deposit, CTA buttons), active tab indicator, focus rings. |
| `--accent-primary-hover` | `#7C3AED` | Violet darker | Hovered primary buttons. |
| `--accent-primary-bg` | `rgba(139, 92, 246, 0.06)` | Violet bg | Subtle backgrounds for primary-colored elements. |
| `--accent-primary-bg-hover` | `rgba(139, 92, 246, 0.10)` | Violet bg hover | Hovered ghost buttons. |
| `--accent-info` | `#06B6D4` | Cyan | Data points, live indicators, informational badges. |
| `--accent-info-bg` | `rgba(6, 182, 212, 0.08)` | Cyan bg | Info badge backgrounds. |
| `--accent-success` | `#10B981` | Emerald | Positive yield, success states, green checkmarks, price-up. |
| `--accent-success-bg` | `rgba(16, 185, 129, 0.08)` | Emerald bg | Success message backgrounds. |
| `--accent-warning` | `#F59E0B` | Amber | Warnings, risk callouts, paused state, yield-down. |
| `--accent-warning-bg` | `rgba(245, 158, 11, 0.08)` | Amber bg | Warning banner backgrounds. |
| `--accent-error` | `#EF4444` | Red | Errors, failed transactions, critical issues. |
| `--accent-error-bg` | `rgba(239, 68, 68, 0.08)` | Red bg | Error message backgrounds. |

#### Protocol Brand Colors (for allocation chart only)

| Protocol | Color | Usage |
|----------|-------|-------|
| Aave V3 | `#B6509E` | Allocation bar segment, protocol label. Aave's official pink-purple. |
| Morpho Blue | `#2470FF` | Allocation bar segment, protocol label. Morpho's official blue. |
| Aerodrome | `#0098EA` | Allocation bar segment, protocol label. Aerodrome's official blue. |
| Idle Buffer | `rgba(255, 255, 255, 0.15)` | Allocation bar segment. Neutral, muted. |

### 1.2 Typography Scale

Three typefaces. No exceptions. No substitutions.

#### Font Stack

| Role | Family | Fallback | Weight Range | Load |
|------|--------|----------|-------------|------|
| Display/Headings | `'Instrument Serif'` | `Georgia, serif` | 400 only | Google Fonts, `display=swap` |
| Body/UI | `'Inter'` | `-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif` | 300, 400, 500, 600 | Google Fonts, `display=swap` |
| Data/Monospace | `'JetBrains Mono'` | `'SF Mono', 'Fira Code', 'Consolas', monospace` | 400, 500, 600 | Google Fonts, `display=swap` |

#### Type Scale

| Token | Font | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|------|--------|-------------|---------------|-------|
| `--type-display-xl` | Instrument Serif | 56px / clamp(36px, 7vw, 56px) | 400 | 1.05 | -0.04em | Landing hero headline. |
| `--type-display-lg` | Instrument Serif | 36px / clamp(28px, 5vw, 36px) | 400 | 1.1 | -0.03em | Section headings on landing page. |
| `--type-display-md` | Instrument Serif | 24px | 400 | 1.15 | -0.02em | Card headings in dApp (e.g., "Deposit USDC"). |
| `--type-display-sm` | Instrument Serif | 18px | 400 | 1.2 | -0.02em | Sub-section headings. |
| `--type-body-lg` | Inter | 16px | 300 | 1.6 | 0 | Landing page body copy. |
| `--type-body-md` | Inter | 14px | 400 | 1.5 | 0 | dApp body text, descriptions. |
| `--type-body-sm` | Inter | 13px | 400 | 1.5 | 0 | Secondary text, inline info. |
| `--type-caption` | Inter | 12px | 400 | 1.4 | 0 | Captions, helper text below inputs. |
| `--type-overline` | JetBrains Mono | 10px | 500 | 1.3 | 0.12em | Overlines, step labels (uppercase). |
| `--type-label` | Inter | 12px | 500 | 1.3 | 0.02em | Button labels, tab labels, form labels. |
| `--type-data-xl` | JetBrains Mono | 40px / clamp(28px, 5vw, 40px) | 600 | 1.1 | -0.02em | Hero stat numbers (TVL, APY on landing). |
| `--type-data-lg` | JetBrains Mono | 28px | 600 | 1.15 | -0.01em | Portfolio headline number (current value). |
| `--type-data-md` | JetBrains Mono | 18px | 500 | 1.2 | 0 | Inline data (share price, APY in dApp). |
| `--type-data-sm` | JetBrains Mono | 14px | 400 | 1.3 | 0 | Secondary data (wallet balance, cap remaining). |
| `--type-data-xs` | JetBrains Mono | 12px | 400 | 1.3 | 0 | Tertiary data (timestamps, addresses). |

**Critical rule for financial numbers:** All numeric data uses `font-variant-numeric: tabular-nums` on JetBrains Mono. This ensures digits have equal width so columns of numbers align perfectly and animated counters do not jitter.

**Global anti-aliasing:**
```css
body {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
```

### 1.3 Spacing Scale

Base unit: 4px. All spacing is a multiple of 4px. No exceptions.

| Token | Value | Usage |
|-------|-------|-------|
| `--space-1` | 4px | Minimum gap (between icon and label). |
| `--space-2` | 8px | Tight gap (between related elements within a group). |
| `--space-3` | 12px | Default gap (between items in a list, padding inside small elements). |
| `--space-4` | 16px | Card internal padding, gap between card sections. |
| `--space-5` | 20px | Main layout padding (horizontal page margins). |
| `--space-6` | 24px | Section gap inside a card, gap between form elements. |
| `--space-8` | 32px | Gap between cards/sections in the dApp. |
| `--space-10` | 40px | Section spacing on landing page. |
| `--space-12` | 48px | Large section spacing on landing page. |
| `--space-16` | 64px | Landing page section top/bottom padding (desktop). |
| `--space-20` | 80px | Landing hero top/bottom padding (desktop). |
| `--space-24` | 96px | Maximum section spacing. |

**Container widths:**

| Token | Value | Usage |
|-------|-------|-------|
| `--container-sm` | 480px | dApp card max-width (deposit/withdraw forms). |
| `--container-md` | 640px | dApp wider cards (portfolio, vault info). |
| `--container-lg` | 960px | Landing page content max-width. |
| `--container-xl` | 1200px | Landing page outer max-width. |

### 1.4 Border Radius Tokens

| Token | Value | Usage |
|-------|-------|-------|
| `--radius-sm` | 6px | Inputs, small buttons, inner elements. |
| `--radius-md` | 8px | Tooltips, badges, dropdown menus. |
| `--radius-lg` | 12px | Cards, panels, modals. |
| `--radius-xl` | 16px | Hero stat cards on landing page. |
| `--radius-pill` | 9999px | Pills, tags, APY badges. |

### 1.5 Shadow and Glow Tokens

This interface uses light/glow rather than traditional drop shadows. Dark backgrounds do not respond to box-shadow in the traditional sense -- instead, we use colored glow effects and border luminance to create elevation.

| Token | Value | Usage |
|-------|-------|-------|
| `--glow-none` | `none` | Default resting state. Cards sit flat. |
| `--glow-primary-subtle` | `0 0 20px -10px rgba(139, 92, 246, 0.4)` | Active/processing card. Violet halo. |
| `--glow-primary-button` | `0 0 24px -8px rgba(139, 92, 246, 0.35)` | Primary button hover. |
| `--glow-success-subtle` | `0 0 20px -10px rgba(16, 185, 129, 0.3)` | Success state card. |
| `--glow-warning-subtle` | `0 0 20px -10px rgba(245, 158, 11, 0.3)` | Warning state card. |
| `--glow-error-subtle` | `0 0 20px -10px rgba(239, 68, 68, 0.3)` | Error state card. |
| `--glow-card-hover` | `0 0 30px -12px rgba(255, 255, 255, 0.04)` | Subtle hover lift for interactive cards. |

**Elevation is communicated through border opacity and backdrop blur, not box-shadow.** A "higher" element has a brighter border and stronger blur. This is the Synapse system's version of Material's elevation scale.

| Level | Border Opacity | Backdrop Blur | Context |
|-------|---------------|--------------|---------|
| 0 (base) | 0 | 0 | Page background. |
| 1 (surface) | 0.06 | 16px | Cards, panels. |
| 2 (raised) | 0.08 | 20px | Hovered cards, dropdowns. |
| 3 (overlay) | 0.10 | 24px | Modals, toasts. |
| 4 (top) | 0.12 | 32px | Tooltip overlays, critical alerts. |

### 1.6 Transition Tokens

| Token | Value | Usage |
|-------|-------|-------|
| `--ease-snappy` | `cubic-bezier(0.23, 1, 0.32, 1)` | Default for all UI transitions. Snappy overshoot feel. |
| `--ease-smooth` | `cubic-bezier(0.4, 0, 0.2, 1)` | Smooth deceleration for page transitions. |
| `--ease-bounce` | `cubic-bezier(0.34, 1.56, 0.64, 1)` | Slight bounce for success states. |
| `--duration-fast` | `150ms` | Hover states, button press feedback. |
| `--duration-normal` | `250ms` | Typical transitions (border color, background). |
| `--duration-medium` | `400ms` | Card state changes, tab switches. |
| `--duration-slow` | `600ms` | Page transitions, overlay appear/disappear. |
| `--duration-number` | `200ms` | Real-time number fade updates (per UX spec). |

---

## 2. Component Library

### 2.1 Buttons

#### Primary Button (Violet)

The primary call-to-action. Used for: "Start Earning", "Deposit USDC", "Withdraw USDC", "Approve USDC".

```css
.btn-primary {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 14px 28px;
  background: #8B5CF6;
  color: #FFFFFF;
  border: none;
  border-radius: 6px;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  font-weight: 600;
  line-height: 1;
  letter-spacing: 0.01em;
  cursor: pointer;
  transition: background 150ms cubic-bezier(0.23, 1, 0.32, 1),
              box-shadow 150ms cubic-bezier(0.23, 1, 0.32, 1),
              transform 150ms cubic-bezier(0.23, 1, 0.32, 1);
}

.btn-primary:hover {
  background: #7C3AED;
  box-shadow: 0 0 24px -8px rgba(139, 92, 246, 0.35);
}

.btn-primary:active {
  transform: scale(0.98);
  background: #6D28D9;
}

.btn-primary:focus-visible {
  outline: 2px solid #8B5CF6;
  outline-offset: 2px;
}
```

**Full-width variant** (dApp form actions):
```css
.btn-primary--full {
  width: 100%;
  padding: 16px 28px;
  font-size: 15px;
}
```

**States:**

| State | Background | Text | Cursor | Additional |
|-------|-----------|------|--------|-----------|
| Default | `#8B5CF6` | `#FFFFFF` | `pointer` | -- |
| Hover | `#7C3AED` | `#FFFFFF` | `pointer` | `box-shadow: 0 0 24px -8px rgba(139, 92, 246, 0.35)` |
| Active/Pressed | `#6D28D9` | `#FFFFFF` | `pointer` | `transform: scale(0.98)` |
| Disabled | `rgba(139, 92, 246, 0.2)` | `rgba(255, 255, 255, 0.3)` | `not-allowed` | No hover effect. |
| Loading | `#8B5CF6` | `#FFFFFF` | `wait` | 16px spinner icon replaces text or appears before text. |

#### Secondary Button (Ghost)

Used for: "See How It Works", "Dismiss", "Use different wallet", secondary actions.

```css
.btn-secondary {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 14px 28px;
  background: transparent;
  color: rgba(255, 255, 255, 0.7);
  border: 1px solid rgba(255, 255, 255, 0.10);
  border-radius: 6px;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  font-weight: 500;
  line-height: 1;
  cursor: pointer;
  transition: border-color 150ms cubic-bezier(0.23, 1, 0.32, 1),
              color 150ms cubic-bezier(0.23, 1, 0.32, 1),
              background 150ms cubic-bezier(0.23, 1, 0.32, 1);
}

.btn-secondary:hover {
  border-color: rgba(255, 255, 255, 0.20);
  color: #FFFFFF;
  background: rgba(255, 255, 255, 0.03);
}

.btn-secondary:active {
  background: rgba(255, 255, 255, 0.05);
}

.btn-secondary:focus-visible {
  outline: 2px solid rgba(255, 255, 255, 0.3);
  outline-offset: 2px;
}
```

#### Text Button (Inline Link)

Used for: "View on Basescan", "Learn more", "Read the full audit report".

```css
.btn-text {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 0;
  background: none;
  border: none;
  color: #8B5CF6;
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: color 150ms cubic-bezier(0.23, 1, 0.32, 1);
  text-decoration: none;
}

.btn-text:hover {
  color: #A78BFA;
  text-decoration: underline;
  text-underline-offset: 2px;
}
```

#### Wallet Connect Button

Located in the navigation bar. Dual state: disconnected and connected.

**Disconnected state:**
```css
.btn-wallet {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  background: rgba(139, 92, 246, 0.08);
  color: #8B5CF6;
  border: 1px solid rgba(139, 92, 246, 0.15);
  border-radius: 6px;
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: background 150ms cubic-bezier(0.23, 1, 0.32, 1),
              border-color 150ms cubic-bezier(0.23, 1, 0.32, 1);
}

.btn-wallet:hover {
  background: rgba(139, 92, 246, 0.12);
  border-color: rgba(139, 92, 246, 0.25);
}
```

**Connected state:**
```css
.btn-wallet--connected {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 6px 12px;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.06);
  border-radius: 6px;
  font-family: 'JetBrains Mono', monospace;
  font-size: 12px;
  font-weight: 400;
  color: rgba(255, 255, 255, 0.7);
  cursor: pointer;
  transition: border-color 150ms cubic-bezier(0.23, 1, 0.32, 1);
}
/* Contains a 20px Jazzicon/identicon circle + truncated address (0x1234...5678) */

.btn-wallet--connected:hover {
  border-color: rgba(255, 255, 255, 0.12);
}
```

#### MAX Button (inside amount inputs)

```css
.btn-max {
  padding: 4px 10px;
  background: rgba(139, 92, 246, 0.08);
  color: #8B5CF6;
  border: 1px solid rgba(139, 92, 246, 0.12);
  border-radius: 4px;
  font-family: 'Inter', sans-serif;
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  cursor: pointer;
  transition: background 150ms cubic-bezier(0.23, 1, 0.32, 1);
  min-width: 44px;  /* Apple HIG minimum touch target */
  min-height: 28px;
}

.btn-max:hover {
  background: rgba(139, 92, 246, 0.15);
}
```

### 2.2 Input Fields

#### Amount Input

The amount input is the most critical interactive element. It appears on Deposit and Withdraw tabs.

```
+----------------------------------------------------------------+
|  Amount                                             [MAX]       |
|                                                                 |
|  [_________________________ 0.00 ] USDC                         |
|                                                                 |
|  Wallet balance: 12,450.00 USDC                                 |
+----------------------------------------------------------------+
```

```css
.input-amount-container {
  background: var(--surface-raised);
  border: 1px solid var(--border-default);
  border-radius: 12px;
  padding: 16px;
  transition: border-color 250ms cubic-bezier(0.23, 1, 0.32, 1),
              box-shadow 250ms cubic-bezier(0.23, 1, 0.32, 1);
}

.input-amount-container:focus-within {
  border-color: rgba(139, 92, 246, 0.5);
  box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.08);
}

.input-amount-container--error:focus-within {
  border-color: rgba(239, 68, 68, 0.5);
  box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.08);
}

.input-amount-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.input-amount-label {
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  font-weight: 500;
  color: rgba(255, 255, 255, 0.4);
  letter-spacing: 0.02em;
}

.input-amount-field-row {
  display: flex;
  align-items: center;
  gap: 12px;
}

.input-amount-field {
  flex: 1;
  background: none;
  border: none;
  outline: none;
  font-family: 'JetBrains Mono', monospace;
  font-size: 24px;
  font-weight: 500;
  color: #FFFFFF;
  font-variant-numeric: tabular-nums;
  letter-spacing: -0.01em;
}

.input-amount-field::placeholder {
  color: rgba(255, 255, 255, 0.15);
}

.input-amount-token {
  display: flex;
  align-items: center;
  gap: 6px;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  font-weight: 600;
  color: #FFFFFF;
  flex-shrink: 0;
}
/* The USDC icon is a 20x20px circle with the USDC logo. */

.input-amount-balance {
  margin-top: 12px;
  font-family: 'JetBrains Mono', monospace;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.3);
}

/* Mobile: input gets inputmode="decimal" for numeric keyboard */
/* Mobile: field font-size stays at 24px -- never below 16px to prevent iOS zoom */
```

**Validation states:**

| State | Border | Message Style |
|-------|--------|---------------|
| Default | `rgba(255, 255, 255, 0.06)` | No message. |
| Focus | `rgba(139, 92, 246, 0.5)` | No message. |
| Error | `rgba(239, 68, 68, 0.5)` | Red text below input, `font-size: 12px`, color `#EF4444`. |
| Warning | `rgba(245, 158, 11, 0.5)` | Amber text below input, `font-size: 12px`, color `#F59E0B`. |

**Inline validation message:**
```css
.input-validation-msg {
  margin-top: 8px;
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  line-height: 1.4;
  animation: slideDown 200ms cubic-bezier(0.23, 1, 0.32, 1);
}

.input-validation-msg--error { color: #EF4444; }
.input-validation-msg--warning { color: #F59E0B; }

@keyframes slideDown {
  from { opacity: 0; transform: translateY(-4px); }
  to { opacity: 1; transform: translateY(0); }
}
```

### 2.3 Cards

#### Glass Card (Standard)

The primary container for all grouped content in the dApp.

```css
.card {
  background: rgba(10, 10, 10, 0.7);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border: 1px solid rgba(255, 255, 255, 0.06);
  border-radius: 12px;
  padding: 24px;
  transition: border-color 400ms cubic-bezier(0.23, 1, 0.32, 1),
              background 400ms cubic-bezier(0.23, 1, 0.32, 1),
              box-shadow 400ms cubic-bezier(0.23, 1, 0.32, 1);
}

.card:hover {
  border-color: rgba(255, 255, 255, 0.10);
}
```

**Card variants:**

| Variant | Border Override | Background Override | Usage |
|---------|---------------|--------------------|----|
| `.card--stat` | Default | Default | Landing page stat cards. Taller padding (32px). |
| `.card--form` | Default | Default | Deposit/Withdraw form container. Max-width: 480px. |
| `.card--portfolio` | Default | Default | Portfolio summary card. Max-width: 640px. |
| `.card--info` | Default | Default | Vault info sections. Max-width: 640px. |
| `.card--success` | `rgba(16, 185, 129, 0.2)` | `rgba(16, 185, 129, 0.04)` | Success confirmation inline card. |
| `.card--error` | `rgba(239, 68, 68, 0.2)` | `rgba(239, 68, 68, 0.04)` | Error confirmation inline card. |
| `.card--warning` | `rgba(245, 158, 11, 0.2)` | `rgba(245, 158, 11, 0.04)` | Warning / risk callout card. |

#### Portfolio Headline Card

The most prominent card in the dApp -- shows current value on the Portfolio tab.

```css
.card--portfolio-headline {
  background: rgba(10, 10, 10, 0.7);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border: 1px solid rgba(255, 255, 255, 0.06);
  border-radius: 12px;
  padding: 32px;
  text-align: center;
}

.portfolio-value {
  font-family: 'JetBrains Mono', monospace;
  font-size: 40px;
  font-weight: 600;
  color: #FFFFFF;
  letter-spacing: -0.02em;
  font-variant-numeric: tabular-nums;
  line-height: 1.1;
  margin-bottom: 4px;
}

.portfolio-label {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.4);
  margin-bottom: 16px;
}

.portfolio-earned {
  font-family: 'JetBrains Mono', monospace;
  font-size: 16px;
  font-weight: 500;
  color: #10B981;  /* Emerald -- always green unless loss */
  margin-bottom: 4px;
}

.portfolio-since {
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.3);
}
```

### 2.4 Navigation

#### Desktop Top Bar

Fixed to viewport top. Height: 56px. Full width.

```
+----------------------------------------------------------------------+
|  [Logo] Yield Router     Deposit | Portfolio | Withdraw | Vault  [Wallet] |
+----------------------------------------------------------------------+
```

```css
.topbar {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 50;
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  background: rgba(3, 3, 3, 0.8);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
}

.topbar-logo {
  font-family: 'Instrument Serif', Georgia, serif;
  font-size: 18px;
  font-weight: 400;
  letter-spacing: -0.02em;
  color: #FFFFFF;
  text-decoration: none;
  cursor: pointer;
}

.topbar-tabs {
  display: flex;
  align-items: center;
  gap: 0;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 8px;
  padding: 3px;
}

.topbar-tab {
  padding: 7px 16px;
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 500;
  color: rgba(255, 255, 255, 0.4);
  border-radius: 6px;
  cursor: pointer;
  transition: color 150ms cubic-bezier(0.23, 1, 0.32, 1),
              background 150ms cubic-bezier(0.23, 1, 0.32, 1);
  text-decoration: none;
  border: none;
  background: none;
}

.topbar-tab:hover {
  color: rgba(255, 255, 255, 0.7);
}

.topbar-tab--active {
  color: #FFFFFF;
  background: rgba(139, 92, 246, 0.12);
}

.topbar-tab--disabled {
  color: rgba(255, 255, 255, 0.15);
  cursor: default;
}
```

#### Mobile Bottom Tab Bar

Replaces the top tab group on screens < 768px. The top bar on mobile shows only the logo (left) and wallet button (right).

```css
.bottom-tabs {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 50;
  display: none;  /* Hidden on desktop */
  align-items: center;
  justify-content: space-around;
  height: 64px;
  padding-bottom: env(safe-area-inset-bottom, 0px);
  background: rgba(3, 3, 3, 0.9);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-top: 1px solid rgba(255, 255, 255, 0.06);
}

@media (max-width: 767px) {
  .bottom-tabs { display: flex; }
  .topbar-tabs { display: none; }
}

.bottom-tab {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  padding: 8px 0;
  min-width: 64px;
  background: none;
  border: none;
  cursor: pointer;
}

.bottom-tab-icon {
  width: 20px;
  height: 20px;
  color: rgba(255, 255, 255, 0.3);
  transition: color 150ms cubic-bezier(0.23, 1, 0.32, 1);
}

.bottom-tab-label {
  font-family: 'Inter', sans-serif;
  font-size: 10px;
  font-weight: 500;
  color: rgba(255, 255, 255, 0.3);
  transition: color 150ms cubic-bezier(0.23, 1, 0.32, 1);
}

.bottom-tab--active .bottom-tab-icon { color: #8B5CF6; }
.bottom-tab--active .bottom-tab-label { color: #8B5CF6; }
```

### 2.5 Data Display Components

#### APY Badge

Used on the landing hero and beside deposit/portfolio numbers. Pill-shaped, cyan tint.

```css
.apy-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  background: rgba(6, 182, 212, 0.08);
  border: 1px solid rgba(6, 182, 212, 0.15);
  border-radius: 9999px;
  font-family: 'JetBrains Mono', monospace;
  font-size: 14px;
  font-weight: 500;
  color: #06B6D4;
}

/* Small variant for inline use */
.apy-badge--sm {
  padding: 4px 10px;
  font-size: 12px;
}

/* Pulsing dot indicating live data */
.apy-badge-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: #06B6D4;
  animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.3; }
}
```

#### Stat Card (Landing Page)

Four stats in a row: TVL, Net APY, Users, Yield Paid.

```css
.stat-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
}

@media (max-width: 767px) {
  .stat-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 8px;
  }
}

.stat-card {
  background: rgba(10, 10, 10, 0.7);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border: 1px solid rgba(255, 255, 255, 0.06);
  border-radius: 16px;
  padding: 24px;
  text-align: center;
}

.stat-value {
  font-family: 'JetBrains Mono', monospace;
  font-size: 32px;
  font-weight: 600;
  color: #FFFFFF;
  letter-spacing: -0.02em;
  font-variant-numeric: tabular-nums;
  line-height: 1.1;
  margin-bottom: 4px;
}

@media (max-width: 767px) {
  .stat-value { font-size: 24px; }
}

.stat-label {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 400;
  color: rgba(255, 255, 255, 0.4);
}

.stat-tooltip-trigger {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 16px;
  height: 16px;
  margin-left: 4px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.06);
  color: rgba(255, 255, 255, 0.3);
  font-size: 10px;
  cursor: help;
  vertical-align: middle;
}
```

#### Data Row (Key-Value Pair)

Used in Portfolio details and Vault Info for parameter listings.

```css
.data-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 0;
  border-bottom: 1px solid rgba(255, 255, 255, 0.04);
}

.data-row:last-child {
  border-bottom: none;
}

.data-row-label {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.4);
}

.data-row-value {
  font-family: 'JetBrains Mono', monospace;
  font-size: 13px;
  font-weight: 500;
  color: #FFFFFF;
  font-variant-numeric: tabular-nums;
}
```

#### Address Display (with copy and link)

Used in Vault Info for contract addresses.

```css
.address-display {
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.address-text {
  font-family: 'JetBrains Mono', monospace;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.7);
}

.address-action {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  border-radius: 4px;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.06);
  color: rgba(255, 255, 255, 0.3);
  cursor: pointer;
  transition: color 150ms, background 150ms;
}

.address-action:hover {
  background: rgba(255, 255, 255, 0.06);
  color: rgba(255, 255, 255, 0.6);
}

/* After copying -- flash green */
.address-action--copied {
  background: rgba(16, 185, 129, 0.08);
  color: #10B981;
  border-color: rgba(16, 185, 129, 0.15);
}
```

### 2.6 Transaction State Components

#### Transaction Button States

The primary button morphs through states. It never leaves the form -- the button IS the transaction state indicator.

| State | Label | Icon | Background | Behavior |
|-------|-------|------|-----------|----------|
| Idle | "Deposit USDC" | None | `#8B5CF6` | Clickable. |
| Confirm in wallet | "Confirm in wallet..." | 16px spinner (white, left of text) | `#8B5CF6` | Not clickable. Cursor: `wait`. |
| Pending | "Depositing..." | 16px spinner (white, left of text) | `#7C3AED` | Not clickable. |
| Success | "Deposit USDC" (resets) | None | `#8B5CF6` | Clickable again. Success card appears below. |
| Failed | "Deposit USDC" (resets) | None | `#8B5CF6` | Clickable again. Error card appears below. |

**Spinner spec:**
```css
.spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.2);
  border-top-color: #FFFFFF;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
```

#### Inline Success Card

Appears below the form after a successful transaction. Persistent until dismissed.

```css
.tx-success {
  display: flex;
  gap: 12px;
  padding: 16px;
  background: rgba(16, 185, 129, 0.04);
  border: 1px solid rgba(16, 185, 129, 0.2);
  border-radius: 12px;
  margin-top: 16px;
  animation: slideUp 300ms cubic-bezier(0.23, 1, 0.32, 1);
}

.tx-success-icon {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: rgba(16, 185, 129, 0.12);
  color: #10B981;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  /* Contains a checkmark icon */
}

.tx-success-body {
  flex: 1;
}

.tx-success-title {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 500;
  color: #10B981;
  margin-bottom: 4px;
}

.tx-success-detail {
  font-family: 'JetBrains Mono', monospace;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.4);
  margin-bottom: 2px;
}

.tx-success-link {
  font-family: 'JetBrains Mono', monospace;
  font-size: 11px;
  color: #8B5CF6;
  text-decoration: none;
}

.tx-success-link:hover {
  text-decoration: underline;
}

.tx-success-dismiss {
  align-self: flex-start;
  background: none;
  border: none;
  color: rgba(255, 255, 255, 0.2);
  cursor: pointer;
  padding: 4px;
  font-size: 14px;
}

.tx-success-dismiss:hover {
  color: rgba(255, 255, 255, 0.5);
}

@keyframes slideUp {
  from { opacity: 0; transform: translateY(8px); }
  to { opacity: 1; transform: translateY(0); }
}
```

#### Inline Error Card

Same structure as success, with red colors.

```css
.tx-error {
  display: flex;
  gap: 12px;
  padding: 16px;
  background: rgba(239, 68, 68, 0.04);
  border: 1px solid rgba(239, 68, 68, 0.2);
  border-radius: 12px;
  margin-top: 16px;
  animation: slideUp 300ms cubic-bezier(0.23, 1, 0.32, 1);
}

.tx-error-icon {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: rgba(239, 68, 68, 0.12);
  color: #EF4444;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.tx-error-title {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 500;
  color: #EF4444;
  margin-bottom: 4px;
}

.tx-error-detail {
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.4);
}
```

#### Warning Banner

Full-width banner for vault paused, network errors, etc. Sits between the top bar and the main content.

```css
.banner-warning {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 10px 24px;
  background: rgba(245, 158, 11, 0.06);
  border-bottom: 1px solid rgba(245, 158, 11, 0.15);
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: #F59E0B;
  text-align: center;
}

.banner-error {
  background: rgba(239, 68, 68, 0.06);
  border-bottom: 1px solid rgba(239, 68, 68, 0.15);
  color: #EF4444;
}
```

### 2.7 Charts

#### Yield History Line Chart

Located on the Portfolio tab. Clean, minimal axis treatment.

**Visual spec:**

| Property | Value |
|----------|-------|
| Line color | `#8B5CF6` (violet) |
| Line width | 2px |
| Line join | Round |
| Fill under line | Linear gradient from `rgba(139, 92, 246, 0.12)` at top to `rgba(139, 92, 246, 0)` at bottom |
| Grid lines | Horizontal only, `rgba(255, 255, 255, 0.04)`, 1px |
| X-axis labels | JetBrains Mono, 10px, `rgba(255, 255, 255, 0.2)` |
| Y-axis labels | JetBrains Mono, 10px, `rgba(255, 255, 255, 0.2)`, formatted as `$XX,XXX` |
| Hover crosshair | Vertical line, `rgba(255, 255, 255, 0.1)`, 1px dashed |
| Hover dot | 6px circle, `#8B5CF6` fill, 2px white border |
| Hover tooltip | Glass card (level 4 elevation), shows date + value in JetBrains Mono 12px |
| Chart height | 200px on desktop, 160px on mobile |
| Chart padding | 0 horizontal, 8px top/bottom for breathing room |
| No data state | Dashed horizontal line at center, `rgba(255, 255, 255, 0.1)`, text "No data yet" centered |

**Time range selector:**
```css
.chart-range-selector {
  display: flex;
  gap: 4px;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 6px;
  padding: 3px;
}

.chart-range-btn {
  padding: 4px 12px;
  background: none;
  border: none;
  border-radius: 4px;
  font-family: 'JetBrains Mono', monospace;
  font-size: 11px;
  font-weight: 500;
  color: rgba(255, 255, 255, 0.3);
  cursor: pointer;
  transition: color 150ms, background 150ms;
}

.chart-range-btn:hover {
  color: rgba(255, 255, 255, 0.6);
}

.chart-range-btn--active {
  color: #FFFFFF;
  background: rgba(139, 92, 246, 0.12);
}
```

#### Allocation Bar (Horizontal Stacked)

Located on the Portfolio tab. Shows vault allocation across protocols.

```css
.allocation-bar {
  width: 100%;
  height: 8px;
  border-radius: 4px;
  overflow: hidden;
  display: flex;
  background: rgba(255, 255, 255, 0.04);
}

.allocation-segment {
  height: 100%;
  transition: width 600ms cubic-bezier(0.23, 1, 0.32, 1);
  /* Colors assigned per-protocol (see Protocol Brand Colors above) */
}

/* First segment gets left radius, last gets right radius */
.allocation-segment:first-child { border-radius: 4px 0 0 4px; }
.allocation-segment:last-child { border-radius: 0 4px 4px 0; }
```

**Allocation legend:**
```css
.allocation-legend {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  margin-top: 12px;
}

.allocation-legend-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.allocation-legend-dot {
  width: 8px;
  height: 8px;
  border-radius: 2px;
  flex-shrink: 0;
}

.allocation-legend-name {
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.5);
}

.allocation-legend-pct {
  font-family: 'JetBrains Mono', monospace;
  font-size: 12px;
  font-weight: 500;
  color: rgba(255, 255, 255, 0.7);
}
```

### 2.8 Wallet Modal

The wallet connection modal follows the interaction spec (Section 4.1). Glass panel, centered, with backdrop.

```css
.modal-backdrop {
  position: fixed;
  inset: 0;
  z-index: 60;
  background: rgba(3, 3, 3, 0.7);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  visibility: hidden;
  transition: opacity 300ms cubic-bezier(0.23, 1, 0.32, 1),
              visibility 300ms cubic-bezier(0.23, 1, 0.32, 1);
}

.modal-backdrop--open {
  opacity: 1;
  visibility: visible;
}

.modal {
  background: rgba(14, 14, 14, 0.95);
  backdrop-filter: blur(24px);
  -webkit-backdrop-filter: blur(24px);
  border: 1px solid rgba(255, 255, 255, 0.10);
  border-radius: 16px;
  padding: 24px;
  width: 380px;
  max-width: calc(100vw - 32px);
  transform: scale(0.96) translateY(8px);
  transition: transform 300ms cubic-bezier(0.23, 1, 0.32, 1);
}

.modal-backdrop--open .modal {
  transform: scale(1) translateY(0);
}

.modal-title {
  font-family: 'Instrument Serif', Georgia, serif;
  font-size: 20px;
  font-weight: 400;
  letter-spacing: -0.02em;
  color: #FFFFFF;
  margin-bottom: 20px;
}

.wallet-option {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.06);
  border-radius: 8px;
  cursor: pointer;
  transition: border-color 150ms, background 150ms;
  margin-bottom: 8px;
  width: 100%;
}

.wallet-option:hover {
  border-color: rgba(255, 255, 255, 0.12);
  background: rgba(255, 255, 255, 0.05);
}

.wallet-option--primary {
  border-color: rgba(139, 92, 246, 0.15);
  background: rgba(139, 92, 246, 0.04);
}

.wallet-option--primary:hover {
  border-color: rgba(139, 92, 246, 0.25);
  background: rgba(139, 92, 246, 0.08);
}

.wallet-option-icon {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  flex-shrink: 0;
}

.wallet-option-name {
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  font-weight: 500;
  color: #FFFFFF;
}

.wallet-option-desc {
  font-family: 'Inter', sans-serif;
  font-size: 11px;
  color: rgba(255, 255, 255, 0.3);
}
```

**Wallet order in the modal:**
1. Coinbase Wallet (`.wallet-option--primary` -- slightly emphasized)
2. MetaMask
3. WalletConnect
4. Rabby

### 2.9 FAQ Accordion

Landing page FAQ section. Clean expand/collapse.

```css
.faq-item {
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
}

.faq-trigger {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  padding: 20px 0;
  background: none;
  border: none;
  cursor: pointer;
  text-align: left;
}

.faq-question {
  font-family: 'Inter', sans-serif;
  font-size: 15px;
  font-weight: 500;
  color: rgba(255, 255, 255, 0.7);
  transition: color 150ms;
}

.faq-trigger:hover .faq-question {
  color: #FFFFFF;
}

.faq-chevron {
  width: 20px;
  height: 20px;
  color: rgba(255, 255, 255, 0.2);
  transition: transform 300ms cubic-bezier(0.23, 1, 0.32, 1),
              color 150ms;
  flex-shrink: 0;
}

.faq-item--open .faq-chevron {
  transform: rotate(180deg);
  color: rgba(255, 255, 255, 0.5);
}

.faq-answer {
  max-height: 0;
  overflow: hidden;
  transition: max-height 300ms cubic-bezier(0.23, 1, 0.32, 1),
              opacity 300ms cubic-bezier(0.23, 1, 0.32, 1);
  opacity: 0;
}

.faq-item--open .faq-answer {
  max-height: 200px; /* Adjust per content */
  opacity: 1;
}

.faq-answer-inner {
  padding-bottom: 20px;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  font-weight: 300;
  color: rgba(255, 255, 255, 0.5);
  line-height: 1.7;
}
```

### 2.10 Loading Skeletons

Per the UX spec: skeletons, never spinners, for initial data loads.

```css
.skeleton {
  background: linear-gradient(
    90deg,
    rgba(255, 255, 255, 0.03) 25%,
    rgba(255, 255, 255, 0.06) 50%,
    rgba(255, 255, 255, 0.03) 75%
  );
  background-size: 200% 100%;
  animation: shimmer 1.5s ease-in-out infinite;
  border-radius: 4px;
}

@keyframes shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

/* Skeleton size variants */
.skeleton--text-sm { height: 12px; width: 80px; }
.skeleton--text-md { height: 14px; width: 120px; }
.skeleton--text-lg { height: 18px; width: 160px; }
.skeleton--number-lg { height: 40px; width: 180px; border-radius: 6px; }
.skeleton--number-md { height: 24px; width: 120px; border-radius: 4px; }
.skeleton--chart { height: 200px; width: 100%; border-radius: 8px; }
.skeleton--bar { height: 8px; width: 100%; border-radius: 4px; }
```

### 2.11 Tooltip

For (i) info icons next to stats and technical terms.

```css
.tooltip {
  position: absolute;
  z-index: 70;
  padding: 10px 14px;
  background: rgba(20, 20, 20, 0.95);
  backdrop-filter: blur(24px);
  -webkit-backdrop-filter: blur(24px);
  border: 1px solid rgba(255, 255, 255, 0.10);
  border-radius: 8px;
  max-width: 260px;
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  font-weight: 400;
  color: rgba(255, 255, 255, 0.6);
  line-height: 1.5;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
  pointer-events: none;
  opacity: 0;
  transform: translateY(4px);
  transition: opacity 200ms cubic-bezier(0.23, 1, 0.32, 1),
              transform 200ms cubic-bezier(0.23, 1, 0.32, 1);
}

.tooltip--visible {
  opacity: 1;
  transform: translateY(0);
  pointer-events: auto;
}
```

### 2.12 Security Checklist

Landing page trust section. Green checkmarks with labels.

```css
.checklist {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.checklist-item {
  display: flex;
  align-items: center;
  gap: 12px;
}

.checklist-icon {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: rgba(16, 185, 129, 0.1);
  color: #10B981;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  /* Contains a checkmark SVG, 12px */
}

.checklist-text {
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  font-weight: 400;
  color: rgba(255, 255, 255, 0.6);
}
```

### 2.13 Risk Callout Card

The yellow-bordered risk disclosure box on the landing page and Vault Info tab.

```css
.risk-callout {
  padding: 20px;
  background: rgba(245, 158, 11, 0.03);
  border: 1px solid rgba(245, 158, 11, 0.15);
  border-radius: 12px;
}

.risk-callout-title {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 600;
  color: #F59E0B;
  margin-bottom: 12px;
}

.risk-callout-text {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 300;
  color: rgba(255, 255, 255, 0.5);
  line-height: 1.7;
}

.risk-callout-text ul {
  list-style: none;
  padding: 0;
}

.risk-callout-text li {
  padding-left: 16px;
  position: relative;
  margin-bottom: 8px;
}

.risk-callout-text li::before {
  content: '-';
  position: absolute;
  left: 0;
  color: rgba(245, 158, 11, 0.5);
}
```

---

## 3. Page Layouts

### 3.1 Landing Page

The landing page is a single scrollable page with six sections. It lives at `/` and uses a distinct layout from the dApp: wider content, more generous spacing, marketing-optimized typography.

**Global structure:**
```
[Sticky Top Bar -- full width]
[Hero Section -- full viewport height]
[How It Works -- content-width centered]
[Live Stats -- content-width centered]
[Security & Trust -- content-width centered]
[FAQ -- content-width centered]
[Footer CTA -- full-width section]
[Footer -- full width]
```

**Content centering pattern:**
```css
.landing-section {
  width: 100%;
  display: flex;
  justify-content: center;
  padding: 64px 24px;
}

@media (max-width: 767px) {
  .landing-section { padding: 40px 16px; }
}

.landing-content {
  width: 100%;
  max-width: 960px;
}
```

#### Section 1: Hero

**Desktop layout (>= 1024px):**
```
                         (centered, max-width: 640px)
                    +---------------------------------+
                    |                                 |
                    |  Your USDC. Earning more.       |
                    |  Automatically.                 |
                    |                                 |
                    |  [subheadline - 2 lines]        |
                    |                                 |
                    |  [APY Badge: 7.2% net]          |
                    |                                 |
                    |  [Start Earning] [How It Works] |
                    |                                 |
                    +---------------------------------+
```

**Specs:**
- Full viewport height (`min-height: 100vh`), centered content via flexbox.
- Background: `#030303` solid. No gradient, no image, no animation.
- Headline: `--type-display-xl` (Instrument Serif, 56px, tracking -0.04em), color `#FFFFFF`, text-align center. Line break between "Earning more." and "Automatically." on desktop. Responsive via `clamp(36px, 7vw, 56px)`.
- Subheadline: `--type-body-lg` (Inter, 16px, weight 300), color `rgba(255, 255, 255, 0.5)`, text-align center, max-width 520px margin auto, margin-top 16px.
- APY Badge: Centered, margin-top 24px. Uses `.apy-badge` component. Contents: pulsing dot + "Current net APY: 7.2%".
- Button row: `display: flex; gap: 12px; justify-content: center; margin-top: 32px;`. Primary button "Start Earning" + secondary button "See How It Works".
- Scroll indicator: Subtle down-arrow at bottom of hero area, `position: absolute; bottom: 24px;`, color `rgba(255, 255, 255, 0.15)`, animated with gentle bounce (translateY 0 to 8px, 2s infinite).

#### Section 2: How It Works

**Desktop layout (>= 1024px):**
```
  How It Works
  (section heading, left-aligned)

  +------------------+  +------------------+  +------------------+
  |  [Deposit Icon]  |  |  [Router Icon]   |  |  [Growth Icon]   |
  |                  |  |                  |  |                  |
  |  Deposit USDC    |  |  We optimize     |  |  You earn        |
  |  Connect your    |  |  Yield Router    |  |  Watch your      |
  |  wallet and      |  |  allocates your  |  |  balance grow.   |
  |  deposit any     |  |  USDC across...  |  |  Withdraw...     |
  |  amount of USDC. |  |                  |  |                  |
  |                  |  |  [Allocation bar]|  |                  |
  +------------------+  +------------------+  +------------------+

  You receive yrUSDC -- a standard ERC-4626 vault share that grows...
  (footnote, centered, dim text)
```

**Specs:**
- Section heading: `--type-display-lg` (Instrument Serif, 36px), color `#FFFFFF`, margin-bottom 40px.
- Three-column grid: `grid-template-columns: repeat(3, 1fr); gap: 16px;`. On mobile (<768px): `grid-template-columns: 1fr;` stacked.
- Step cards: `.card` with padding 24px. No hover effect.
  - Step icon: 40x40px, line-art SVG, stroke-width 1.5px, color `rgba(255, 255, 255, 0.4)`. Simple, not illustrative.
  - Step number: `--type-overline` (JetBrains Mono, 10px, uppercase, letter-spacing 0.12em), color `rgba(255, 255, 255, 0.2)`. Example: "STEP 1".
  - Step title: `--type-display-sm` (Instrument Serif, 18px), color `#FFFFFF`, margin-top 12px.
  - Step body: `--type-body-sm` (Inter, 13px, weight 300), color `rgba(255, 255, 255, 0.5)`, margin-top 8px, line-height 1.6.
- Allocation bar animation (in step 2 card): The horizontal stacked bar uses protocol brand colors and slowly shifts weights over a 10-second CSS animation (keyframes that change flex percentages). Subtle and decorative only.
- Footnote: `--type-body-sm` (Inter, 13px), color `rgba(255, 255, 255, 0.3)`, text-align center, margin-top 32px.
  - "ERC-4626" is wrapped in a dotted underline with a tooltip on hover explaining the standard in plain language.

#### Section 3: Live Stats

**Desktop layout (>= 1024px):**
```
  +----------+  +----------+  +----------+  +----------+
  |  $4.2M   |  |  7.2%    |  |  312     |  |  $180K   |
  |  TVL     |  |  Net APY |  |  Users   |  | Yield Paid|
  +----------+  +----------+  +----------+  +----------+
```

**Specs:**
- Uses `.stat-grid` and `.stat-card` components (see Section 2.5).
- Each stat value uses `--type-data-xl` (JetBrains Mono, 40px).
- Numbers animate with count-up on first appearance (intersection observer triggered). Duration: 1200ms, easing `cubic-bezier(0.23, 1, 0.32, 1)`. Counts from 0 to actual value. This is the ONLY place count-up animations are used (per UX spec -- real-time updates use fade, not count-up).
- Mobile (< 768px): 2x2 grid, stat-value drops to 24px.
- Each stat label has a small (i) tooltip trigger that reveals a one-sentence explanation.

#### Section 4: Security & Trust

**Desktop layout (>= 1024px):**
```
  Security First
  (section heading)

  +----------------------------+  +----------------------------+
  |  [check] Audited by...     |  |  Our smart contracts have  |
  |  [check] Open source       |  |  been independently...     |
  |  [check] Non-custodial     |  |                            |
  |  [check] No token          |  |  [Audit Report link]       |
  |  [check] 48-hour timelock  |  |  [Basescan link]           |
  |  [check] Max 10% fee       |  |  [Security docs link]      |
  +----------------------------+  +----------------------------+

  +----------------------------------------------------------+
  |  (amber border) Risks to understand before depositing    |
  |  - Smart contract risk...                                |
  |  - Yield variability...                                  |
  |  - This is not a bank...                                 |
  +----------------------------------------------------------+
```

**Specs:**
- Section heading: same as Section 2.
- Two-column layout: `grid-template-columns: 1fr 1fr; gap: 32px;`. On mobile: stacked single column.
- Left column: `.checklist` component (see Section 2.12).
- Right column: Body text in `--type-body-md` (Inter, 14px, weight 300), color `rgba(255, 255, 255, 0.5)`, line-height 1.7. Links styled as `.btn-text`.
- Risk callout: `.risk-callout` component below the two-column grid, margin-top 32px. Full width within the content container.

#### Section 5: FAQ

**Specs:**
- Section heading: "Frequently Asked Questions", same heading style.
- Uses `.faq-item` accordion component (see Section 2.9).
- Max-width: 640px, centered within the landing-content container.
- 10 questions per the UX spec, in the specified order.

#### Section 6: Footer CTA

**Specs:**
- Full-width section with `background: rgba(139, 92, 246, 0.03); border-top: 1px solid rgba(139, 92, 246, 0.08); border-bottom: 1px solid rgba(139, 92, 246, 0.08);`
- Centered content, padding 64px.
- Heading: `--type-display-lg` (Instrument Serif, 36px), color `#FFFFFF`. "Ready to put your USDC to work?"
- Primary button below heading, margin-top 24px. "Start Earning -- Connect Wallet".
- Sub-text: `--type-body-sm` (Inter, 13px), color `rgba(255, 255, 255, 0.3)`, margin-top 16px, text-align center.

#### Footer

```css
.footer {
  padding: 32px 24px;
  border-top: 1px solid rgba(255, 255, 255, 0.06);
  display: flex;
  align-items: center;
  justify-content: space-between;
}

@media (max-width: 767px) {
  .footer {
    flex-direction: column;
    gap: 16px;
    text-align: center;
  }
}

.footer-links {
  display: flex;
  gap: 24px;
}

.footer-link {
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.3);
  text-decoration: none;
  transition: color 150ms;
}

.footer-link:hover { color: rgba(255, 255, 255, 0.6); }

.footer-copyright {
  font-family: 'Inter', sans-serif;
  font-size: 11px;
  color: rgba(255, 255, 255, 0.15);
}
```

### 3.2 dApp Layout -- Deposit Tab

The dApp is a single-page application within the `/app/*` routes. All tabs share the same shell: top bar + content area + (mobile) bottom tabs.

**Content area** is centered, narrow, form-focused.

```
[Sticky Top Bar with active tab indicator]

         (centered, max-width: 480px)
    +-----------------------------------+
    |  Deposit USDC                     |   <-- Instrument Serif, 24px
    |                                   |
    |  +-------------------------------+|   <-- .input-amount-container
    |  | Amount                 [MAX]  ||
    |  |                               ||
    |  | [_________ 0.00] USDC         ||
    |  |                               ||
    |  | Wallet balance: 12,450 USDC   ||
    |  +-------------------------------+|
    |                                   |
    |  You will receive: ~12,283 yrUSDC |   <-- Inter 13px, dim
    |  Current share price: 1.0136      |   <-- JetBrains Mono 13px
    |  Net APY: 7.2%                    |   <-- JetBrains Mono 13px, cyan
    |                                   |
    |  [======= Deposit USDC ========] |   <-- .btn-primary--full
    |                                   |
    |  Vault deposit cap: $800K left    |   <-- Inter 12px, dim
    |  Minimum deposit: 10 USDC        |
    +-----------------------------------+

    [Inline success/error card area]     <-- Appears after tx
```

**Specs:**
- Page title: `--type-display-md` (Instrument Serif, 24px), color `#FFFFFF`, margin-bottom 24px.
- Content padding-top: 56px (top bar height) + 32px.
- Maximum content width: 480px, centered with `margin: 0 auto`.
- Horizontal padding: 24px on desktop, 16px on mobile.
- Gap between input container and preview data: 20px.
- Preview data lines: each is a `.data-row` with smaller padding (6px 0).
  - "You will receive" label: Inter 13px, `rgba(255, 255, 255, 0.4)`.
  - yrUSDC value: JetBrains Mono 13px, `#FFFFFF`.
  - Share price: JetBrains Mono 13px, `rgba(255, 255, 255, 0.7)`.
  - Net APY: JetBrains Mono 13px, `#06B6D4` (cyan).
- Gap between preview data and button: 24px.
- Cap/minimum info: Inter 12px, `rgba(255, 255, 255, 0.2)`, margin-top 16px, text-align center.

### 3.3 dApp Layout -- Portfolio Tab

**Desktop layout:**
```
[Sticky Top Bar]

         (centered, max-width: 640px)
    +-----------------------------------+
    |          $12,614.20               |   <-- JetBrains Mono 40px, white
    |          Current Value            |   <-- Inter 13px, dim
    |                                   |
    |   +$164.20 earned (+1.32%)        |   <-- JetBrains Mono 16px, green
    |   since your first deposit        |   <-- Inter 12px, dim
    +-----------------------------------+

    +-----------------------------------+
    |  Shares held     12,283.47 yrUSDC |   <-- .data-row
    |  Share price     1.0269 USDC      |
    |  Net APY         7.2%             |
    |  Your share      0.3%             |
    +-----------------------------------+

    +-----------------------------------+
    |  Yield History      [7D][30D][ALL]|
    |                                   |
    |  [Line chart -- 200px tall]       |
    |                                   |
    +-----------------------------------+

    +-----------------------------------+
    |  Vault Allocation                 |
    |  [======= stacked bar =========] |
    |                                   |
    |  * Aave V3  32%  * Morpho  45%   |
    |  * Aero     18%  * Idle     5%   |
    +-----------------------------------+
```

**Specs:**
- Portfolio headline card: `.card--portfolio-headline`, centered text. Uses `.portfolio-value`, `.portfolio-label`, `.portfolio-earned`, `.portfolio-since` (see Section 2.3).
- Details card: `.card` with `.data-row` items. Margin-top 16px.
- Chart card: `.card`. Margin-top 16px. Chart header with title (Instrument Serif 18px) and range selector, flexbox space-between.
- Allocation card: `.card`. Margin-top 16px. Bar + legend.
- All cards max-width 640px, centered.
- Mobile: all stacked single column, same widths, full horizontal space minus 16px padding.

### 3.4 dApp Layout -- Withdraw Tab

Structurally identical to Deposit tab. Same max-width (480px), same centering.

**Differences:**
- Title: "Withdraw USDC"
- Balance label: "Available to withdraw: 12,614.20 USDC" with a second line "(12,283.47 yrUSDC at 1.0269 USDC/share)" in `--type-data-xs` dim text.
- Preview data: "You will burn: ~X yrUSDC" and "You will receive: ~X USDC".
- Button label: "Withdraw USDC".
- No cap info or minimum deposit line.

### 3.5 dApp Layout -- Vault Info Tab

The widest dApp view. Uses max-width 640px.

**Desktop layout:**
```
[Sticky Top Bar]

         (centered, max-width: 640px)
    Vault Details                          <-- Instrument Serif, 24px

    +-----------------------------------+
    |  Vault address   0x12...78 [copy] |   <-- .data-row + .address-display
    |  Asset           USDC             |
    |  Share token     yrUSDC           |
    |  Standard        ERC-4626         |
    +-----------------------------------+

    +-----------------------------------+
    |  Parameters                       |
    |                                   |
    |  Performance fee    10%           |
    |  Max fee (hardcoded) 10%         |
    |  Management fee     None          |
    |  Withdrawal fee     None          |
    |  Deposit cap        $1,000,000    |
    |  Minimum deposit    10 USDC       |
    |  Idle buffer        5%            |
    |  Rebalance threshold 200 bps      |
    |  Timelock delay     48 hours      |
    +-----------------------------------+

    +-----------------------------------+
    |  Adapters (Yield Sources)         |
    |                                   |
    |  1. Aave V3 USDC Supply           |
    |     0xaaaa...bbbb [Basescan]      |
    |     Balance: $1.34M  APY: 6.8%    |
    |     Status: Active                |
    |                                   |
    |  2. Morpho Blue USDC/cbBTC        |
    |     ... (same pattern)            |
    |                                   |
    |  3. Morpho Blue USDC/cbETH        |
    |     ... (same pattern)            |
    |                                   |
    |  Idle Buffer: $340K (8.1%)        |
    +-----------------------------------+

    +-----------------------------------+
    |  Security                         |
    |                                   |
    |  Audit report    [PDF link]       |
    |  Source code     [GitHub link]    |
    |  Governance      3/5 multisig     |
    |  Guardian        2/3 multisig     |
    |  Pending changes None             |
    |  Bug bounty      $25,000          |
    +-----------------------------------+

    +-----------------------------------+
    |  (amber border) Risk Disclosures  |
    |  [Full text of 5 risk items]      |
    +-----------------------------------+
```

**Adapter item spec:**
```css
.adapter-item {
  padding: 16px 0;
  border-bottom: 1px solid rgba(255, 255, 255, 0.04);
}

.adapter-item:last-child { border-bottom: none; }

.adapter-name {
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  font-weight: 500;
  color: #FFFFFF;
  margin-bottom: 4px;
}

.adapter-address {
  margin-bottom: 8px;
  /* Uses .address-display component */
}

.adapter-stats {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
}

.adapter-stat {
  font-family: 'JetBrains Mono', monospace;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.5);
}

.adapter-stat-value {
  color: #FFFFFF;
  font-weight: 500;
}

.adapter-status {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-family: 'JetBrains Mono', monospace;
  font-size: 11px;
  color: #10B981;
  /* Green dot + "Active" */
}
```

**"Pending Changes" section (V2 state):**
When governance changes are queued, the "Pending changes" row becomes a highlighted sub-card:
```css
.pending-change {
  padding: 12px;
  background: rgba(245, 158, 11, 0.04);
  border: 1px solid rgba(245, 158, 11, 0.15);
  border-radius: 8px;
  margin-top: 8px;
}

.pending-change-title {
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  font-weight: 500;
  color: #F59E0B;
  margin-bottom: 4px;
}

.pending-change-detail {
  font-family: 'JetBrains Mono', monospace;
  font-size: 11px;
  color: rgba(255, 255, 255, 0.5);
}
```

---

## 4. Responsive Strategy

### 4.1 Breakpoints

| Breakpoint | Name | Layout Behavior |
|-----------|------|-----------------|
| >= 1200px | Desktop XL | Full desktop layout. Max-width containers centered. Generous spacing. |
| 1024px -- 1199px | Desktop | Same as XL but with reduced horizontal padding (20px instead of 24px). |
| 768px -- 1023px | Tablet | Stats grid becomes 2x2. How It Works stays 3-column. Navigation tabs stay in top bar. Reduced section padding (48px instead of 64px). |
| < 768px | Mobile | Single column. Bottom tab bar. Full-width buttons. Reduced padding (16px horizontal, 32px vertical for sections). Mobile-specific input sizing. |

### 4.2 Navigation Adaptation

| Breakpoint | Navigation |
|-----------|-----------|
| >= 768px | Top bar: Logo (left), tab group (center), wallet button (right). All in one row. |
| < 768px | Top bar: Logo (left), wallet button (right). Tabs move to bottom tab bar (4 items). Top bar height stays 56px. Bottom bar height: 64px + safe area inset. |

### 4.3 Content Adaptation

**Landing page:**

| Element | Desktop (>= 1024px) | Tablet (768-1023px) | Mobile (< 768px) |
|---------|---------------------|---------------------|-------------------|
| Hero headline | 56px | 44px | 36px |
| How It Works | 3-column grid | 3-column grid (tighter gap) | 1-column stack |
| Stats grid | 4-column | 2x2 | 2x2 |
| Security | 2-column | 2-column (tighter gap) | 1-column stack |
| FAQ | 640px max-width | 640px max-width | Full width |
| Section padding (vertical) | 64px | 48px | 32px |
| Section padding (horizontal) | 24px | 20px | 16px |

**dApp:**

| Element | Desktop | Mobile |
|---------|---------|--------|
| Form max-width | 480px centered | Full width - 32px margin |
| Portfolio max-width | 640px centered | Full width - 32px margin |
| Vault Info max-width | 640px centered | Full width - 32px margin |
| Button width | Full width of form card | Full width of form card |
| Input field font size | 24px | 24px (never below 16px -- prevents iOS zoom) |
| Content padding-top | 56px (topbar) + 32px | 56px (topbar) + 16px |
| Content padding-bottom | 32px | 64px (bottom tabs) + 16px |
| Amount input touch target | Standard | Minimum 44x44px for MAX button, input, and action button |
| Chart height | 200px | 160px |
| Adapter stats in Vault Info | Horizontal row | Wrap to 2 lines if needed |

### 4.4 Touch Targets (Mobile)

Per Apple Human Interface Guidelines, all interactive elements on mobile must have a minimum touch target of 44x44px. This applies to:

| Element | Desktop Size | Mobile Minimum |
|---------|-------------|---------------|
| MAX button | 28px tall | 44px tall (padding increase) |
| Tab items (bottom bar) | N/A | 64px tall, 64px wide minimum |
| FAQ accordion triggers | 20px padding | 20px padding (row itself exceeds 44px) |
| Wallet button | 36px tall | 44px tall |
| Copy/link action icons | 24x24px | 44x44px touch area (visual remains 24px, padding adds touch space) |
| Tooltip (i) icons | 16x16px | 44x44px touch area |

---

## 5. Motion and Animation

### 5.1 Core Easing

All motion uses `cubic-bezier(0.23, 1, 0.32, 1)` unless specified otherwise. This curve has a fast attack and gentle overshoot -- it feels snappy and physical without being bouncy.

### 5.2 Page Transitions

When switching between dApp tabs (Deposit, Portfolio, Withdraw, Vault), the content area transitions:

```css
.page-enter {
  opacity: 0;
  transform: translateY(8px);
}

.page-enter-active {
  opacity: 1;
  transform: translateY(0);
  transition: opacity 250ms cubic-bezier(0.23, 1, 0.32, 1),
              transform 250ms cubic-bezier(0.23, 1, 0.32, 1);
}

.page-exit {
  opacity: 1;
}

.page-exit-active {
  opacity: 0;
  transition: opacity 150ms cubic-bezier(0.23, 1, 0.32, 1);
}
```

**Duration:** 250ms enter, 150ms exit. The enter is slightly longer to allow the content to "settle." Exit is faster because we want to get out of the way quickly.

**No horizontal sliding.** Horizontal slide implies spatial relationship between tabs (left/right). These tabs are not spatially ordered -- they are categorically different views. Vertical fade is semantically neutral.

### 5.3 Loading Skeletons

Skeletons use the shimmer animation defined in Section 2.10. They appear immediately on page load and fade out as data arrives:

```css
.skeleton-to-content {
  transition: opacity 200ms cubic-bezier(0.23, 1, 0.32, 1);
}
```

When data arrives, the skeleton fades out and the real content fades in. Both transitions are 200ms. The skeleton never "transforms" into content -- it simply crossfades.

### 5.4 Number Animations

**First-load count-up (landing page stats only):**

When the stats section scrolls into view (intersection observer), numbers count from 0 to their final value:

| Property | Value |
|----------|-------|
| Duration | 1200ms |
| Easing | `cubic-bezier(0.23, 1, 0.32, 1)` |
| Trigger | Intersection observer, threshold 0.3 |
| Number formatting | Maintained throughout animation (commas, decimals, $ signs) |
| Decimal places | Fixed during animation (no jitter) |

**Real-time data updates (dApp):**

Per UX spec Section 5.4, real-time data uses a 200ms fade, not a count-up:

```css
.data-value-update {
  transition: opacity 200ms cubic-bezier(0.23, 1, 0.32, 1);
}
```

When a value changes: old value fades to 0 opacity, new value fades in from 0. Both 200ms. The two transitions overlap so the swap feels instantaneous but not jarring.

### 5.5 Hover and Focus States

| Element | Hover Effect | Focus-Visible Effect |
|---------|-------------|---------------------|
| Primary button | Background darkens (`#7C3AED`), violet glow appears | 2px `#8B5CF6` outline, 2px offset |
| Secondary button | Border brightens, text brightens, subtle bg | 2px `rgba(255,255,255,0.3)` outline |
| Card | Border opacity increases to 0.10 | N/A (cards are not focusable unless interactive) |
| Input container | N/A (focus-within handled) | Violet border + ring |
| Tab item | Text brightens | 2px violet outline |
| Link | Color lightens, underline appears | 2px violet outline |
| Wallet option | Border brightens, bg lightens | 2px violet outline |
| FAQ trigger | Question text brightens | 2px outline |
| Copy/link icon | Bg and icon brighten | 2px outline |

**All hover transitions:** 150ms duration, `cubic-bezier(0.23, 1, 0.32, 1)`.

**Focus-visible only (not focus):** We use `:focus-visible` not `:focus` so that mouse users do not see focus rings. Keyboard users see them.

### 5.6 Transaction State Animations

**Button loading spinner:** 0.6s linear infinite rotation (see Section 2.6). Spinner appears with a quick 100ms fade-in. Text changes simultaneously.

**Success card appearance:** `slideUp` animation, 300ms, `cubic-bezier(0.23, 1, 0.32, 1)`. Starts 8px below final position and at 0 opacity.

**Error card appearance:** Same `slideUp` animation as success.

**Dismiss animation:** 200ms fade-out + scale down to 0.98. Then element is removed from DOM.

### 5.7 Allocation Bar Animation

On the landing page (How It Works section step 2), the allocation bar slowly shifts proportions:

```css
@keyframes rebalance-demo {
  0%   { flex: 32; } /* Aave */
  25%  { flex: 28; }
  50%  { flex: 35; }
  75%  { flex: 30; }
  100% { flex: 32; }
}
```

Each segment has its own keyframe animation with different timings, creating a subtle "breathing" effect that suggests continuous rebalancing. Total cycle: 10 seconds, infinite loop. Animation is CSS-only, no JavaScript.

On the dApp Portfolio tab, the allocation bar updates with data. Width transitions use 600ms `cubic-bezier(0.23, 1, 0.32, 1)` when percentages change.

### 5.8 Scroll-Triggered Animations (Landing Page Only)

Landing page sections fade in as they scroll into view. This is the only scroll-triggered animation in the entire product.

```css
.landing-section {
  opacity: 0;
  transform: translateY(16px);
  transition: opacity 600ms cubic-bezier(0.23, 1, 0.32, 1),
              transform 600ms cubic-bezier(0.23, 1, 0.32, 1);
}

.landing-section--visible {
  opacity: 1;
  transform: translateY(0);
}
```

Triggered by intersection observer at threshold 0.15. Each section animates independently. No staggered delays -- that feels artificial on scroll.

**Not on the dApp.** The dApp is a utility interface. It should feel instant, not theatrical.

---

## 6. Accessibility

### 6.1 Color Contrast

All text/background combinations must meet WCAG 2.1 AA minimum contrast ratios.

| Element | Foreground | Background | Contrast Ratio | Passes AA? |
|---------|-----------|-----------|----------------|-----------|
| Primary text on base | `#FFFFFF` | `#030303` | 19.4:1 | Yes |
| Secondary text on base | `rgba(255,255,255,0.7)` ~= `#B3B3B3` | `#030303` | 11.6:1 | Yes |
| Tertiary text on base | `rgba(255,255,255,0.4)` ~= `#666666` | `#030303` | 4.8:1 | Yes (for 14px+ text, passes 3:1 for large text; for smaller text, passes 4.5:1) |
| Muted text on base | `rgba(255,255,255,0.3)` ~= `#4D4D4D` | `#030303` | 3.5:1 | Yes for large text only. Used only for labels >= 12px. |
| Violet accent on base | `#8B5CF6` | `#030303` | 5.3:1 | Yes |
| Cyan accent on base | `#06B6D4` | `#030303` | 7.2:1 | Yes |
| Green accent on base | `#10B981` | `#030303` | 7.8:1 | Yes |
| Amber accent on base | `#F59E0B` | `#030303` | 9.6:1 | Yes |
| Red accent on base | `#EF4444` | `#030303` | 4.6:1 | Yes |
| Button text on violet | `#FFFFFF` | `#8B5CF6` | 3.6:1 | Yes (large text -- buttons are 14px+ bold) |

**Note on muted text:** `rgba(255,255,255,0.3)` (~3.5:1) is used only for decorative/supplementary labels (deposit cap, timestamps) that are not critical for understanding. All critical information uses `rgba(255,255,255,0.4)` or higher.

### 6.2 Focus Management

- All interactive elements have `:focus-visible` styles (2px outline in brand color, 2px offset).
- Modal dialogs trap focus within the modal. Tab cycles through focusable elements. Escape closes the modal and returns focus to the trigger element.
- Tab order follows visual order (top to bottom, left to right).
- Skip links: Include a visually hidden "Skip to main content" link as the first focusable element on the page.

### 6.3 ARIA

- Transaction status changes use `aria-live="polite"` regions. When a transaction transitions from "Pending" to "Success" or "Error", the screen reader announces the new status.
- The allocation chart includes `role="img"` and an `aria-label` with the text equivalent (e.g., "Vault allocation: Aave V3 32%, Morpho Blue 45%, Aerodrome 18%, Idle 5%").
- Number displays that update in real-time use `aria-live="off"` (too frequent to announce) but have accessible labels.
- Form inputs have associated `<label>` elements, not just placeholder text.
- Error messages are linked to their inputs via `aria-describedby`.
- Loading skeletons have `aria-hidden="true"` and the real content has `aria-busy="true"` until loaded.

### 6.4 Reduced Motion

Respect `prefers-reduced-motion`:

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }

  .skeleton {
    animation: none;
    background: rgba(255, 255, 255, 0.04);
  }

  .apy-badge-dot {
    animation: none;
    opacity: 1;
  }
}
```

---

## 7. Icon System

### 7.1 Icon Specifications

Use a consistent line-art icon set. Recommended: Lucide Icons (open source, clean, consistent with the design tone).

| Property | Value |
|----------|-------|
| Style | Outline / line art |
| Stroke width | 1.5px (default), 2px for small (16px) icons |
| Default size | 20px |
| Small size | 16px (inline with text) |
| Large size | 40px (step icons on landing page) |
| Color | Inherits from `currentColor` |
| Format | Inline SVG (not icon font -- better accessibility and tree-shaking) |

### 7.2 Required Icons

| Icon | Usage | Suggested Lucide Name |
|------|-------|--------------------|
| Deposit | Bottom tab, step 1 | `arrow-down-to-line` |
| Portfolio | Bottom tab | `bar-chart-2` |
| Withdraw | Bottom tab | `arrow-up-from-line` |
| Vault | Bottom tab | `shield-check` |
| Wallet | Wallet button | `wallet` |
| Copy | Address copy action | `copy` |
| External link | Basescan links | `external-link` |
| Checkmark | Success state, checklist | `check` |
| X/Close | Modal close, dismiss | `x` |
| Chevron down | FAQ accordion, dropdown | `chevron-down` |
| Info | Tooltip trigger | `info` |
| Loader/Spinner | Transaction pending | Custom CSS spinner (not icon) |
| Alert triangle | Warning states | `alert-triangle` |
| Arrow down | Scroll indicator on hero | `chevron-down` |

### 7.3 Protocol Logos

Use official SVG logos for Aave, Morpho, and Aerodrome in the allocation display and Vault Info adapters section. Each at 20x20px, displayed inline with the protocol name. Obtain usage permission or use under fair use for product integration display.

---

## 8. Tailwind CSS Implementation Notes

If using Tailwind CSS v4, map the design tokens to the Tailwind config. The following is a reference mapping for the frontend engineer.

```js
// tailwind.config.js (extend section)
{
  theme: {
    extend: {
      colors: {
        surface: {
          base: '#030303',
          raised: 'rgba(10, 10, 10, 0.7)',
        },
        border: {
          DEFAULT: 'rgba(255, 255, 255, 0.06)',
          subtle: 'rgba(255, 255, 255, 0.04)',
          hover: 'rgba(255, 255, 255, 0.10)',
        },
        text: {
          primary: '#FFFFFF',
          secondary: 'rgba(255, 255, 255, 0.7)',
          tertiary: 'rgba(255, 255, 255, 0.4)',
          muted: 'rgba(255, 255, 255, 0.3)',
        },
        accent: {
          violet: '#8B5CF6',
          'violet-hover': '#7C3AED',
          cyan: '#06B6D4',
          emerald: '#10B981',
          amber: '#F59E0B',
          red: '#EF4444',
        },
        protocol: {
          aave: '#B6509E',
          morpho: '#2470FF',
          aerodrome: '#0098EA',
        },
      },
      fontFamily: {
        display: ['Instrument Serif', 'Georgia', 'serif'],
        body: ['Inter', '-apple-system', 'sans-serif'],
        mono: ['JetBrains Mono', 'SF Mono', 'monospace'],
      },
      borderRadius: {
        sm: '6px',
        md: '8px',
        lg: '12px',
        xl: '16px',
        pill: '9999px',
      },
      transitionTimingFunction: {
        snappy: 'cubic-bezier(0.23, 1, 0.32, 1)',
        smooth: 'cubic-bezier(0.4, 0, 0.2, 1)',
      },
      backdropBlur: {
        panel: '16px',
        overlay: '40px',
      },
    },
  },
}
```

---

## 9. Asset Checklist

Files the frontend engineer will need:

| Asset | Format | Source |
|-------|--------|--------|
| Fonts | Google Fonts embed | `Instrument Serif`, `Inter` (300-600), `JetBrains Mono` (400-600) |
| USDC icon | SVG, 20x20 | Official Circle USDC brand kit |
| Aave logo | SVG, 20x20 | Aave brand assets |
| Morpho logo | SVG, 20x20 | Morpho brand assets |
| Aerodrome logo | SVG, 20x20 | Aerodrome brand assets |
| UI icons | Inline SVG | Lucide Icons package (`lucide-react` or `lucide-vue`) |
| Favicon | SVG + PNG 32x32 | Simple "yr" monogram in Instrument Serif, white on transparent |
| OG image | PNG 1200x630 | "Yield Router -- Auto-optimized USDC yield on Base" on dark background |

---

## 10. Implementation Priority

For the frontend engineer, build in this order:

1. **Design tokens and global styles** -- CSS custom properties, font loading, reset.
2. **Top bar and navigation** -- Fixed top bar, tab group, wallet button shell.
3. **Deposit tab** -- Amount input, button states, inline success/error.
4. **Withdraw tab** -- Near-identical to Deposit, different labels.
5. **Portfolio tab** -- Headline card, data rows, chart (placeholder), allocation bar.
6. **Vault Info tab** -- Data rows, adapter items, address displays.
7. **Landing page** -- Hero, How It Works, Stats, Security, FAQ, Footer.
8. **Mobile responsive** -- Bottom tabs, touch targets, stacking.
9. **Motion** -- Page transitions, skeletons, count-up, hover/focus states.
10. **Wallet modal** -- Connection flow, states.

Build the dApp first, then the landing page. The dApp is the product. The landing page is marketing. Ship the product before polishing the marketing.

---

*This document reflects the visual design specification of ui-duarte for Yield Router. It defines every color, size, spacing, and motion value needed to implement the complete frontend. The frontend engineer should treat this as the authoritative visual reference. Every value is specific and implementation-ready. If a value is not specified here, the answer is: use the nearest design token and maintain consistency.*
