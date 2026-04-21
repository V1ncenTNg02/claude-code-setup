# CLAUDE.md

## Project Overview
- Project: <name>
- Purpose: <what this app/service does>
- Primary users: <who uses it>
- Current status: <MVP / production / refactor / migration>
- Key constraints: <performance, security, compliance, etc.>

## Tech Stack
- Language: <TypeScript / Python / Go / etc.>
- Framework: <Next.js / Django / FastAPI / Rails>
- Database: <Postgres / MySQL / MongoDB>
- Infra: <Docker / AWS / Vercel / GCP>
- Package manager: <pnpm / npm / poetry / pip>

## Behavioral Guidelines — Highest Priority
These four rules govern every task, every session, every agent. Read `rules/karpathy-guidelines.md` for full detail.

1. **Think before coding** — state assumptions explicitly before writing a line. If the requirement is ambiguous, ask. Do not pick an interpretation silently.
2. **Simplicity first** — write the minimum code that solves the stated problem. No speculative features, no single-use abstractions, no hypothetical flexibility. If you wrote 200 lines and 50 would do, rewrite it.
3. **Surgical changes** — touch only what the task requires. Do not reformat, rename, or refactor adjacent code. Remove only the orphans YOUR changes created — leave pre-existing dead code alone unless asked.
4. **Goal-driven execution** — reframe every task as a verifiable outcome before starting. For multi-step tasks, state the plan and verify each step before moving to the next.

## Architecture Rules
- Follow existing folder structure strictly
- Do not introduce new abstractions unless repeated 3+ times
- Prefer editing existing files over creating new ones
- Keep business logic in `<service layer>`
- Keep UI components presentational where possible
- Database access only through `<ORM/repository layer>`
- API schemas must remain backward compatible

## Architecture Decisions (ADR / Non-Negotiables)
These are persistent system decisions that must not change unless explicitly requested.

### ADR-001 — Core Data Model
- `<primary identifiers, ownership rules, lifecycle states>`
- Example: soft delete vs hard delete
- Example: UUID vs numeric IDs

### ADR-002 — Security Model
- `<authentication strategy>`
- `<authorization boundary>`
- `<secrets handling rules>`
- `<encryption / hashing constraints>`

### ADR-003 — API Contracts
- Preserve response envelopes
- Preserve error code semantics
- Preserve backward compatibility guarantees
- Do not rename public fields without migration

### ADR-004 — Domain Workflow
- `<business-critical workflow states>`
- `<single-use semantics>`
- `<irreversible transitions>`
- `<validation ordering rules>`

### ADR-005 — Infrastructure Constraints
- `<cloud/runtime assumptions>`
- `<queue/event guarantees>`
- `<database connection policy>`
- `<regional compliance restrictions>`

## Coding Standards
- Match existing code style before introducing changes
- Prefer small pure functions
- Avoid premature optimization
- Use descriptive names over short clever names
- Add comments only for non-obvious reasoning
- Prefer explicit over implicit — types, dependencies, side effects, and control flow should all be visible, not hidden
- Keep files under ~300 lines where practical

## Security Rules
- Never commit secrets or `.env`
- Keep `.env.example` current
- Validate all user input server-side
- Never trust frontend-only validation
- Never log secrets, tokens, or credentials
- Use parameterized queries only
- Flag auth, payment, and data-deletion changes before editing

## Product / Domain Invariants
Business logic that must remain stable:
- `<status transitions>`
- `<error code guarantees>`
- `<localization behavior>`
- `<money / rounding rules>`
- `<single-use constraints>`
- `<idempotency requirements>`

## Testing Rules
- Add/update tests for every behavior change
- Prefer integration tests for workflows
- Prefer unit tests for pure utilities
- Never mock internal business logic unless necessary
- Run the smallest relevant test suite first
- If tests fail, fix root cause instead of snapshot updates

## Common Commands

Fill in the actual commands for this project. Every category below should be defined.

### Development
- Install dependencies: `<install command>`
- Start dev server / run locally: `<dev/run command>`
- Build for production: `<build command>`

### Quality
- Lint: `<lint command>`
- Type / static analysis check: `<typecheck command>` (if the language supports it)
- Run all tests: `<test command>`
- Run a single test file: `<single test command>`

### Database (if applicable)
- Generate ORM / query client: `<generate command>`
- Apply migrations: `<migrate command>`
- Seed development data: `<seed command>`

## Workflow Expectations

### Step -1 — Read project memory (mandatory, every session)
Before any other action, read `docs/memory/project-memory.md`:
- Apply all listed special requirements
- Read the last 3 session log entries for context
- Note any relevant gotchas for the current task
- Check pending work if picking up a deferred task
Full rule: `rules/project-memory.md`

### Step 0 — Classify every request (mandatory)
Before any action, classify the incoming request using `rules/request-classification.md`.
Output the classification block, then follow the corresponding workflow:

| Category | Workflow skill |
|---|---|
| REVIEW | `skills/general/review-workflow/SKILL.md` |
| NEW DEVELOPMENT | `skills/general/development-workflow/SKILL.md` |
| FIX / UPDATE / REFACTOR | `skills/general/fix-workflow/SKILL.md` |

### Before coding (NEW DEVELOPMENT and FIX only):
  1. Read `docs/testing/testing-strategy.md` — confirm testing philosophy and test commands
  2. Create the required PRD / fix brief from the appropriate template in `docs/prd/templates/`
  3. Read related files to understand existing patterns
  4. Reuse conventions already in the repo
  5. Check architecture decisions before structural changes
  6. Run existing tests first — do not start work on top of pre-existing failures

### After coding:
  1. Run lint
  2. Run typecheck
  3. Run the **full** test suite (not just the changed files) — all must pass
  4. Confirm coverage meets thresholds in `docs/testing/testing-strategy.md`
  5. Update changelog immediately (`docs/changelog/changelog.md`)
  6. Update decision log if any architectural choice was made (`docs/decisions/decisions.md`)
  7. Update the PRD / fix brief status to Resolved / Implemented
  8. Write session log entry to `docs/memory/project-memory.md` — record what was completed, decisions made, and any blockers

## Documentation Enforcement
These updates are mandatory and must happen immediately after changes.

### Changelog
- Every code change must append an entry to:
  - `docs/changelog/changelog.md`
- Include:
  - changed files
  - behavior changes
  - migration notes
  - rollback considerations

### Decision Log
- Every architecture, data-flow, security, or infra decision must append:
  - `docs/decisions/decisions.md`
- Do not batch decision updates later
- Record the decision immediately after implementation

### API Design
- Every new or changed API endpoint must have a completed design document at:
  - `docs/design/api-<name>.md` (use template at `docs/design/api-design-template.md`)
- The design file must exist **before** any implementation code is written
- Full enforcement rules: `rules/api-design.md`

### UI Design (frontend sessions)
- At the start of every frontend session, read `docs/design/ui-design.md` in full
- If the file changed since last session, audit all affected components before writing new code
- Template: `docs/design/ui-design-template.md`
- Component-first rule: build shared components before pages — never duplicate a component
- Optional design system: copy a `DESIGN.md` from https://github.com/VoltAgent/awesome-design-md into the project root and record the choice in `docs/design/ui-design.md`
- Full enforcement rules: `rules/frontend-ui-design.md`

### Testing Strategy (all implementation sessions)
- At the start of every implementation session, read `docs/testing/testing-strategy.md`
- If the file does not exist, create it from `docs/testing/testing-strategy-template.md` before writing code
- Run existing tests before starting — do not work on top of pre-existing failures
- Run the full suite after finishing — zero failures required before declaring done
- Test commands must be defined in this file and wired into `.claude/settings.json` hooks
- Full enforcement rules: `rules/testing-enforcement.md`

### Project Memory (every session)
- Read `docs/memory/project-memory.md` before any other action
- Record special requirements immediately when discovered during a session
- Write a session log entry at the end of every session
- Full enforcement rules: `rules/project-memory.md`

## Safe Change Policy
- Never delete large sections without confirming impact
- Never overwrite env/config files without explicit instruction
- Preserve public interfaces unless task requires migration
- Flag risky schema/auth/payment changes before editing
- For destructive operations, propose plan first
- Never alter architecture decisions without ADR update

## PR / Commit Guidance
- Keep changes scoped to one concern
- Mention tradeoffs clearly
- Include rollback path for risky changes
- Note follow-up refactors separately
- Suggested commit style: `<type>: <summary>`

## Repository-Specific Knowledge
### Important Files
- Config: `<path>`
- Main entry: `<path>`
- Core service: `<path>`
- Shared utils: `<path>`
- PRD (project): `docs/prd/PROJECT-NAME-v1.0.0.md`
- PRD (features): `docs/prd/features/FEAT-NNN-*.md`
- Fix briefs: `docs/prd/fixes/FIX-NNN-*.md`
- PRD templates: `docs/prd/templates/`
- Changelog: `docs/changelog/changelog.md`
- Decision log: `docs/decisions/decisions.md`
- Testing strategy: `docs/testing/testing-strategy.md`
- Testing strategy template: `docs/testing/testing-strategy-template.md`
- Project memory: `docs/memory/project-memory.md`

### Known Pitfalls
- `<legacy module has side effects>`
- `<tests require seeded DB>`
- `<auth middleware order matters>`
- `<build breaks if env missing>`
- `<business workflow has irreversible states>`

## Important Gotchas
- `<critical HTTP status semantics>`
- `<timezone/date pitfalls>`
- `<rounding precision edge cases>`
- `<background job retries>`
- `<race-condition sensitive workflows>`

## Preferred Agent Behavior
- **Apply Karpathy guidelines on every task** — state assumptions, write minimum code, make surgical changes, define verifiable goals. Full rules: `rules/karpathy-guidelines.md`
- **Ask clarifying questions one at a time.** If anything about the request is ambiguous, ask the single most important clarifying question first. Wait for the answer before asking the next. Never present a list of questions — one question per message, always.
- Ask before adding dependencies
- Ask before schema migrations
- Ask before renaming public APIs
- Prefer minimal diff solutions — if a change touches more than the task requires, trim it
- Explain why a structural refactor is worth it
- Preserve domain invariants before optimizing
- Check ADR section before system redesign