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

### Step 0 — Classify every request (mandatory)
Before any action, classify the incoming request using `rules/request-classification.md`.
Output the classification block, then follow the corresponding workflow:

| Category | Workflow skill |
|---|---|
| REVIEW | `skills/general/review-workflow/SKILL.md` |
| NEW DEVELOPMENT | `skills/general/development-workflow/SKILL.md` |
| FIX / UPDATE / REFACTOR | `skills/general/fix-workflow/SKILL.md` |

### Before coding (NEW DEVELOPMENT and FIX only):
  1. Create the required PRD / fix brief from the appropriate template in `docs/prd/templates/`
  2. Read related files to understand existing patterns
  3. Reuse conventions already in the repo
  4. Check architecture decisions before structural changes

### After coding:
  1. Run lint
  2. Run typecheck
  3. Run affected tests
  4. Update changelog immediately (`docs/changelog/changelog.md`)
  5. Update decision log if any architectural choice was made (`docs/decisions/decisions.md`)
  6. Update the PRD / fix brief status to Resolved / Implemented

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
- Ask before adding dependencies
- Ask before schema migrations
- Ask before renaming public APIs
- Prefer minimal diff solutions
- Explain why a structural refactor is worth it
- Preserve domain invariants before optimizing
- Check ADR section before system redesign