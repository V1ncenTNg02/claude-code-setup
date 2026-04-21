# UI Design System

**Project:** <name>
**Version:** 1.0
**Status:** Draft
**Date:** YYYY-MM-DD
**Author(s):** <name(s)>

> Save as: `docs/design/ui-design.md` (one file per project — this is the single source of truth for all visual decisions).
> The frontend agent MUST read this file at the start of every frontend session before touching any component or page.
> When this file changes, all affected components must be audited for compliance.

---

## Design source (optional)

If this project adopts an existing design system from [awesome-design-md](https://github.com/VoltAgent/awesome-design-md):

**Chosen design profile:** `<e.g. Stripe / Linear / Notion / None — custom>`

**Setup:** Copy the chosen `DESIGN.md` from the repo into your project root and reference it here.
The AI agent will use it as the pixel-perfect style specification when generating components.

If no external profile is chosen, fill in the sections below manually.

---

## Visual theme

**Mode:** Light / Dark / Both (with toggle)

**Brand personality:** `<e.g. minimal and professional / bold and energetic / calm and trustworthy>`

### Color palette

| Role | Light mode | Dark mode | Notes |
|---|---|---|---|
| Background | `#ffffff` | `#0f0f0f` | Page canvas |
| Surface | `#f8f9fa` | `#1a1a1a` | Cards, panels |
| Border | `#e2e8f0` | `#2d2d2d` | Dividers, outlines |
| Text primary | `#111827` | `#f9fafb` | Body copy, headings |
| Text secondary | `#6b7280` | `#9ca3af` | Labels, captions |
| Brand primary | `<hex>` | `<hex>` | CTA buttons, links, highlights |
| Brand secondary | `<hex>` | `<hex>` | Secondary accents |
| Success | `#16a34a` | `#22c55e` | Confirmations |
| Warning | `#d97706` | `#f59e0b` | Alerts |
| Error | `#dc2626` | `#ef4444` | Errors, destructive actions |
| Focus ring | `<hex>` | `<hex>` | Keyboard focus indicator |

---

## Typography

**Font stack:** `<e.g. Inter, system-ui, sans-serif>`

| Scale | Size | Weight | Line height | Usage |
|---|---|---|---|---|
| Display | 36px / 2.25rem | 700 | 1.2 | Hero headings |
| H1 | 30px / 1.875rem | 700 | 1.3 | Page titles |
| H2 | 24px / 1.5rem | 600 | 1.35 | Section headings |
| H3 | 20px / 1.25rem | 600 | 1.4 | Subsection headings |
| Body | 16px / 1rem | 400 | 1.6 | Default body text |
| Small | 14px / 0.875rem | 400 | 1.5 | Captions, labels |
| Mono | 14px / 0.875rem | 400 | 1.6 | Code, technical values |

---

## Spacing system

Base unit: `4px`

| Token | Value | Usage |
|---|---|---|
| xs | 4px | Icon padding, tight gaps |
| sm | 8px | Inline element gaps |
| md | 16px | Component internal padding |
| lg | 24px | Between related components |
| xl | 32px | Section spacing |
| 2xl | 48px | Page section breaks |
| 3xl | 64px | Hero / large section gaps |

---

## Component styling guidelines

### Buttons

| Variant | Use case | Style notes |
|---|---|---|
| Primary | Main CTA | Brand primary background, white text, 8px radius |
| Secondary | Secondary actions | Transparent background, brand primary border and text |
| Destructive | Delete / remove | Error color, used only for irreversible actions |
| Ghost | Tertiary actions | No border, no background, subdued text |

All buttons:
- Minimum touch target: 44×44px
- Disabled state: 40% opacity, cursor not-allowed
- Loading state: spinner replaces label, button width preserved

### Form fields

- Label above field (never placeholder-only)
- Error message below field in error color
- Focus ring visible and meets WCAG 3:1 contrast ratio
- Required fields marked with `*` and explained once per form

### Cards / panels

- Surface background color
- 1px border in border color
- Border radius: `<e.g. 8px>`
- Shadow: `<e.g. none / sm / md>`

### Icons

- Library: `<e.g. Lucide / Heroicons / Phosphor / custom>`
- Default size: 20px (inline), 24px (standalone)
- Always paired with a text label or `aria-label` — never icon-only without accessibility annotation

---

## Layout principles

**Max content width:** `<e.g. 1280px>`

**Grid:** `<e.g. 12-column, 24px gutter, 16px margin>`

**Breakpoints:**

| Name | Min width | Layout change |
|---|---|---|
| Mobile | 0px | Single column, stacked nav |
| Tablet | 768px | 2-column layouts, side nav visible |
| Desktop | 1024px | Full layout, multi-column |
| Wide | 1280px | Constrained content width |

---

## Depth system

| Level | Usage | Implementation |
|---|---|---|
| Flat | Inline elements, body content | No shadow |
| Raised | Cards, dropdowns | `box-shadow: 0 1px 3px rgba(0,0,0,0.1)` |
| Overlay | Modals, tooltips, popovers | `box-shadow: 0 8px 24px rgba(0,0,0,0.15)` |
| Sticky | Fixed nav, sidebars | Border-bottom or shadow to separate from scroll content |

---

## Responsive behavior

- Mobile-first: base styles target mobile, `min-width` media queries add complexity
- Navigation collapses to hamburger/bottom bar below tablet breakpoint
- Tables: scroll horizontally on mobile rather than reflowing to cards (unless explicitly designed otherwise)
- Images: always responsive (`max-width: 100%`); specify aspect ratios to prevent layout shift

---

## Accessibility baseline

- WCAG 2.1 AA as the minimum target
- Color contrast: ≥ 4.5:1 for body text, ≥ 3:1 for large text and UI components
- All interactive elements reachable and operable by keyboard
- Focus order follows reading order
- No information conveyed by color alone — always pair with text or icon
- `aria-label` on all icon-only buttons and controls

---

## Animation & motion

**Principle:** Motion communicates state change, not decoration. Less is more.

| Duration | Use case |
|---|---|
| 100ms | Micro-interactions (button press, checkbox toggle) |
| 200ms | Component transitions (dropdown open, tooltip appear) |
| 300ms | Page-level transitions, modals |

- Respect `prefers-reduced-motion` — disable or reduce animations when set
- No animation on initial page load unless it communicates loading state

---

## What is NOT in this document

- Component implementation code — that belongs in the component files
- Page layout code — that belongs in page/route files
- API integration — that belongs in the data layer
- Business logic — that belongs in services or domain modules
