# Skill: Frontend Architecture

Source: Clean Architecture (Martin), component-driven design principles

---

## When to invoke

Use this skill when:
- Designing or reviewing the structure of a frontend application
- Deciding where data fetching, state, or business logic belongs
- Adding new views, routes, or reusable components
- Evaluating rendering strategy (server, client, static)

---

## Session start — mandatory (applies to every frontend task)

Before writing any component or page code:

1. Read `docs/design/ui-design.md` — full read, not a skim
2. Check git log for recent changes to `docs/design/ui-design.md`; if changed, audit affected components first
3. Confirm whether an awesome-design-md `DESIGN.md` profile exists in the project root
4. If `docs/design/ui-design.md` is still `Draft` or incomplete, ask the user to complete it before writing UI code

Full enforcement details: `rules/frontend-ui-design.md`

---

## Component-first, page-second — the enforced build order

**Never scaffold a page before its components are built.**

```
Step 1 — Identify UI elements the page needs
Step 2 — Search the shared component library for each element
Step 3 — Build missing components in isolation (standalone, no page coupling)
Step 4 — Compose the page from the completed components
```

### Component reuse check (run before creating any new component)

| Situation | Action |
|---|---|
| Exact match found in component library | Reuse it — do not duplicate |
| Partial match found | Extend via props or composition |
| No match found | Build standalone component, then use in page |
| Similar component exists in another page | Extract it to shared library, then use in both |

Duplicating a component that already exists is a defect, not a shortcut.

### Component isolation requirement

A valid shared component:
- Accepts all variable data via props
- Has no direct coupling to a specific page or route
- Can be rendered and tested in isolation (no page context required)
- Has no hardcoded strings or values that belong to one page only

A page fragment (acceptable, but not a shared component):
- Works only in one specific page
- Lives at `<feature>/components/<FragmentName>`, not in the shared component library

---

## Component boundaries

Split components along two axes:

| Axis | Rule |
|---|---|
| **Presentational vs Container** | Presentational components receive data via props and emit events — no data fetching, no global state. Container components own data fetching and state, pass results down. |
| **Single Responsibility** | A component that manages layout, fetches data, handles form validation, and formats display is doing too much. Extract one concern at a time. |

**Checklist:**
- [ ] Does this component fetch its own data AND render output? Split it.
- [ ] Does this component contain business logic (price calculation, validation rules)? Extract to a pure function or service.
- [ ] Can this component be rendered in isolation with just its props? If not, it is too coupled.

---

## State management decision framework

Choose state scope based on who needs it:

```
Local state      → one component, short-lived (form input, toggle, hover)
Shared UI state  → sibling components or a feature subtree (selected tab, modal open)
Server state     → data that lives on the server (user profile, list items)
Global state     → cross-cutting concerns (current user, theme, permissions)
```

Rules:
- Default to **local state**. Only promote state up when a second consumer appears.
- **Server state** (fetched data) should be managed by a dedicated caching/synchronisation layer, not manually stored in global state.
- **Global state** is a code smell if it holds domain data — it usually means a component boundary is wrong.

---

## Data fetching placement

- Fetch data **as close to where it is rendered as possible** — avoid hoisting fetches to a parent just to prop-drill them down.
- Fetching and rendering should be co-located; the component that renders the data should own the fetch.
- Always handle three states explicitly: **loading**, **error**, **data**. Never assume data is always present.
- De-duplicate identical requests within a single render cycle using a caching layer or request deduplication strategy.

---

## Rendering strategy decision

| Scenario | Strategy |
|---|---|
| Content changes frequently, personalised | Client-side render or server render per request |
| Content changes rarely, same for all users | Static generation at build time |
| Content changes on a schedule (e.g., hourly) | Incremental static regeneration |
| Content requires authentication | Server render per request or client render with auth gate |

Do not default to client-side rendering for everything — evaluate per route.

---

## Routing architecture

- Organise routes by **domain/feature**, not by technical layer (prefer `orders/list`, `orders/detail` over `pages/list`, `pages/detail`).
- Route-level code splitting: each route loads only the code it needs.
- Protect authenticated routes at the routing layer, not scattered inside individual components.
- Nested routes share layouts — avoid re-rendering shared UI on every navigation.

---

## File organisation

```
src/
  components/          ← shared component library (reusable across pages)
    ui/                ← primitive UI elements (Button, Input, Card, Badge)
    layout/            ← layout components (Header, Sidebar, PageWrapper)
    <domain>/          ← domain-specific shared components (UserAvatar, OrderBadge)
  <feature>/
    components/        ← page-specific fragments (not in shared library)
    page.<ext>         ← route/page entry point — composes from components above
    hooks.<ext>        ← data fetching and local logic for this feature
```

---

## Performance patterns

- **Lazy load** heavy components and routes — do not bundle everything upfront.
- **Memoize** derived computations that are expensive; do not memoize everything by default.
- **Virtualise** long lists — never render 10,000 DOM nodes.
- **Images**: always specify dimensions to prevent layout shift; use lazy loading for below-the-fold images.
- Measure first — do not apply performance optimisations without profiling data to justify them.

---

## Design system integration (awesome-design-md)

If a `DESIGN.md` profile exists in the project root:
- All component styling decisions must reference it
- When generating component code, include the instruction: "follow the design spec in DESIGN.md"
- Treat `DESIGN.md` as the pixel-perfect style authority for AI-generated UI

To set up: browse https://github.com/VoltAgent/awesome-design-md, choose a profile (69 available across
AI tools, developer tools, SaaS, fintech, e-commerce, and more), copy `DESIGN.md` to project root,
record the choice in `docs/design/ui-design.md`.

---

## Red flags

- Page file built before the shared components it needs
- The same visual element implemented in two different page files
- Business logic (pricing, validation rules) inside a component
- Data fetched in a parent and prop-drilled through 3+ levels
- A single component file over 300 lines
- Global state used as a data cache for everything
- No loading or error state handled — assuming data is always available
- A component that cannot be rendered without a specific page context
