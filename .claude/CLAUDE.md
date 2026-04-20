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
- Prefer explicit types over inferred complex types
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
### Development
- Install: `pnpm install`
- Start: `pnpm dev`
- Build: `pnpm build`

### Quality
- Lint: `pnpm lint`
- Typecheck: `pnpm typecheck`
- Test: `pnpm test`
- Single test: `pnpm test -- <file>`

### Database
- Generate: `pnpm prisma generate`
- Migrate: `pnpm prisma migrate dev`
- Seed: `pnpm db:seed`

## Workflow Expectations
- Before coding:
  1. Read related files first
  2. Understand existing patterns
  3. Reuse conventions already in repo
  4. Check architecture decisions before structural changes
- After coding:
  1. Run lint
  2. Run typecheck
  3. Run affected tests
  4. Update changelog immediately
  5. Update ADRs if architecture changed
  6. Summarize changed files + risks

## Documentation Enforcement
These updates are mandatory and must happen immediately after changes.

### Changelog
- Every code change must append an entry to:
  - `.claude/changelog/changelog.md`
- Include:
  - changed files
  - behavior changes
  - migration notes
  - rollback considerations

### Decision Log
- Every architecture, data-flow, security, or infra decision must append:
  - `.claude/changelog/decisions.md`
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
- ADRs: `.claude/changelog/decisions.md`
- Changelog: `.claude/changelog/changelog.md`

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