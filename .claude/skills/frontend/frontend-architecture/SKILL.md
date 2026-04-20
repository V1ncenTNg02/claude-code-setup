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

## Performance patterns

- **Lazy load** heavy components and routes — do not bundle everything upfront.
- **Memoize** derived computations that are expensive; do not memoize everything by default.
- **Virtualise** long lists — never render 10,000 DOM nodes.
- **Images**: always specify dimensions to prevent layout shift; use lazy loading for below-the-fold images.
- Measure first — do not apply performance optimisations without profiling data to justify them.

---

## Red flags

- Business logic (pricing, validation rules) inside a component
- Data fetched in a parent and prop-drilled through 3+ levels
- A single component file over 300 lines
- Global state used as a data cache for everything
- No loading or error state handled — assuming data is always available
- Rendering the same data fetch in multiple places without deduplication
