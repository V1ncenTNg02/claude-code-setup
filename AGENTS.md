# AGENTS.md — SDLC Workflow for Codex

This file carries the behavioral contract for Codex. It is the condensed equivalent of the
Claude Code plugin's `skills/sdlc-workflow/SKILL.md`. All rules apply to every task.

Skills in `.agents/skills/` are the primary source of detail — this file is the index.

---

## Mandatory first step — classify every request

Before any action, classify and state the category:

| Category | Signal | Skill |
|---|---|---|
| **REVIEW** | Question / explain / audit / read-only | `.agents/skills/review-workflow/SKILL.md` |
| **NEW DEVELOPMENT** | Building something that doesn't exist | `.agents/skills/development-workflow/SKILL.md` |
| **FIX / UPDATE / REFACTOR** | Changing existing code | `.agents/skills/fix-workflow/SKILL.md` |

Output before acting:
```
## Request Classification
**Category:** <REVIEW | NEW DEVELOPMENT | FIX/UPDATE/REFACTOR>
**Rationale:** <one sentence>
```

---

## Behavioral rules (apply to every task)

**Think before coding** — state assumptions explicitly. Ask the single most important clarifying
question if anything is ambiguous. Never pick an interpretation silently.

**Simplicity first** — write the minimum code that solves the stated problem. No speculative
features, no single-use abstractions, no hypothetical flexibility.

**Surgical changes** — touch only what the task requires. Do not reformat, rename, or refactor
adjacent code. Remove only orphans your own changes created.

**Goal-driven execution** — reframe every task as a verifiable outcome. For multi-step tasks,
state the plan and verify each step before moving to the next.

---

## Documentation (mandatory after every code change)

| Document | Location |
|---|---|
| Changelog | `docs/changelog/changelog.md` |
| Decision log | `docs/decisions/decisions.md` |
| Session log | `docs/memory/project-memory.md` |
| API design (before new endpoints) | `docs/design/api-<name>.md` |

Every code change must append a changelog entry. Every architectural choice must append a decision log entry. Write a session log entry at the end of every session.

---

## Testing

- Read `docs/testing/testing-strategy.md` before writing any implementation code.
- Add/update tests for every behavior change.
- Run the full test suite after every change. All tests must pass before declaring done.
- Never mock internal business logic.
- Use TDD (failing test first) for new features.

---

## Security (non-negotiable)

- Never commit secrets, `.env`, or credentials.
- Validate all user input server-side.
- Use parameterized queries only — no string concatenation into SQL.
- Flag auth, payment, and data-deletion changes before editing.

---

## Architecture

- Follow existing folder structure strictly.
- No new abstractions unless used 3+ times.
- Prefer editing existing files over creating new ones.
- Database access only through the repository/ORM layer.
- API schemas must remain backward compatible.
- No breaking changes without a migration path (see `rules/backward-compatibility.md`).

---

## Session start

Before any other action: read `docs/memory/project-memory.md`. Apply all listed special
requirements. Read the last 3 session log entries for context.

---

## Skills index

| Skill | Path | When |
|---|---|---|
| SDLC workflow (this index in skill form) | `.agents/skills/sdlc-workflow/` | Auto |
| Review workflow | `.agents/skills/review-workflow/` | REVIEW requests |
| Development workflow | `.agents/skills/development-workflow/` | NEW DEVELOPMENT |
| Fix / refactor workflow | `.agents/skills/fix-workflow/` | FIX/UPDATE/REFACTOR |
| Debugging | `.agents/skills/debugging/` | Investigating bugs |
| Data model design | `.agents/skills/data-model-design/` | After PRD approval |
| Design patterns | `.agents/skills/design-patterns/` | Recurring design problems |
| SOLID principles | `.agents/skills/solid-principles/` | Class/module design |
| Clean architecture data flow | `.agents/skills/clean-architecture-data-flow/` | Cross-layer data |
| Enterprise patterns | `.agents/skills/enterprise-application-patterns/` | Persistence/domain |
| Software dev principles | `.agents/skills/software-development-principles/` | Design tradeoffs |
| Backend architecture | `.agents/skills/backend-architecture/` | Backend structuring |
| API contract validator | `.agents/skills/api-contract-validator/` | Adding/changing endpoints |
| Migration safety | `.agents/skills/migration-safety/` | Schema migrations |
| Backend security review | `.agents/skills/backend-security-review/` | Auth/payment/data changes |
| Payment webhook safety | `.agents/skills/payment-webhook-safety/` | Payment handlers |
| Prompt contract check | `.agents/skills/prompt-contract-check/` | LLM prompt changes |
| Frontend architecture | `.agents/skills/frontend-architecture/` | Frontend structuring |
| Component contract check | `.agents/skills/component-contract-check/` | Shared components |
| State management | `.agents/skills/state-management/` | Frontend state |
| Deployment workflow | `.agents/skills/deployment/` | Deployment (explicit only) |
| IaC safety | `.agents/skills/iac-safety/` | Terraform / Docker |
| Container deployment security | `.agents/skills/container-deployment-security/` | Container hardening |

---

## Rules reference

Full rule detail lives in `rules/` — consult when a situation needs deeper guidance:

- `rules/karpathy-guidelines.md` — behavioral rules detail
- `rules/request-classification.md` — classification gate detail
- `rules/tdd.md` — TDD workflow
- `rules/testing-enforcement.md` — testing session checklist
- `rules/api-design.md` — API design enforcement
- `rules/backward-compatibility.md` — breaking change process
- `rules/security-baseline.md` — OWASP baseline
- `rules/engineering-principles.md` — SOLID, Clean Architecture
- `rules/changelog.md` — changelog format
- `rules/project-memory.md` — memory read/write protocol
- `rules/database.md` — migration safety
- `rules/dependency-management.md` — dependency review
- `rules/git-workflow.md` — branching and commit format
