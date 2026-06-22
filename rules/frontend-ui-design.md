# Frontend UI Design Enforcement Rule

## MANDATORY: Read the UI design document at the start of every frontend session.

Before writing, editing, or reviewing any component or page, you MUST read
`docs/design/ui-design.md` in full.

**This check is non-negotiable and applies to every frontend task without exception.**

## Session start checklist (run before touching any frontend code)

1. **Read `docs/design/ui-design.md`** — check the Status field and the date. If it is `Draft`
   or has no date, ask the user to review and complete it before proceeding.
2. **Check for recent changes** — scan git log for modifications to `docs/design/ui-design.md`
   since the last session. If the file changed, identify which color, typography, spacing, or
   component guidelines were updated and audit all affected components before writing new code.
3. **Confirm design source** — if the file references an awesome-design-md profile
   (see `docs/design/ui-design.md` Design source section), check that `DESIGN.md` exists in
   the project root. If not, remind the user to copy it from the repo.

## Component-first, page-second — enforced

**Never build a page before its components exist.**

The required build order is:
```
1. Identify all UI elements the page needs
2. Check the component library — does each element already exist?
3. Build any missing components in isolation (no page dependency)
4. Compose the page from the completed components
```

Rationale: A component built inside a page is coupled to that page. The same element built
as a standalone component is reusable across any page. Building components first prevents
duplication and enforces the single-responsibility principle.

### Before building any new component

Search the existing component library for a component that already covers the need:
- If an exact match exists → reuse it
- If a partial match exists → extend via props or composition, do not duplicate
- If no match exists → build the component standalone, then use it in the page

Never build the same visual element twice. Duplication of components is a defect.

### Component isolation requirement

Every component must be buildable and testable without a page:
- Props-only input — no direct store access inside presentational components
- No hardcoded page-specific data inside a shared component
- A component that only works on one specific page is not a component — it is a page fragment
  and should live in that page's directory, not the shared component library

## Naming

- Shared components: `components/<category>/<ComponentName>`
- Page-specific fragments: `<feature>/components/<FragmentName>` (not in shared library)
- Page/route files: `<feature>/page` or equivalent for the framework

## When the UI design document changes

Whenever `docs/design/ui-design.md` is modified:
1. Identify every component that uses the changed token (color, spacing, typography, radius)
2. Update those components before adding new ones
3. Do not leave components in an inconsistent state with the current design spec
4. Append a `chore` entry to `docs/changelog/changelog.md` noting which components were updated

## Design system options — awesome-design-md

To adopt a proven, AI-optimised design system:

1. Browse the collection at: https://github.com/VoltAgent/awesome-design-md
2. Choose a design profile (Stripe, Linear, Notion, Vercel, Supabase, etc.)
3. Copy the chosen `DESIGN.md` file into the project root
4. Record the choice in `docs/design/ui-design.md` under "Design source"
5. When prompting for component generation, reference `DESIGN.md`:
   > "Build this component following the design spec in DESIGN.md"

Available categories: AI & LLM platforms, developer tools, backend & DevOps, productivity & SaaS,
design & creative tools, fintech, e-commerce, media, automotive. 69 profiles total.
Each profile includes visual theme, color palette, typography, component styling, layout principles,
depth system, responsive behavior, and agent prompt guidance.

The `DESIGN.md` in the project root is the pixel-perfect style authority. It overrides generic
preferences but is subordinate to explicit decisions in `docs/design/ui-design.md`.
