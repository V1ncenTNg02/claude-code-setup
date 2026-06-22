---
name: sdlc-workflow
description: Core SDLC behavioral rules — request classification gate, Karpathy coding guidelines, documentation enforcement, and agent-team dispatch. Auto-triggered on every task. Apply when: writing any code, reviewing anything, fixing bugs, building features, deploying, or making architectural decisions.
---

# SDLC Workflow — Core Behavioral Rules

This skill activates on every task. It carries the behavioral contract from `CLAUDE.md` and `rules/` as a plugin-native, auto-triggering skill.

---

## Step 0 — Classify first (mandatory, before any other action)

Classify the incoming request into exactly one category and state it before acting:

| Category | Signal | Workflow skill |
|---|---|---|
| **REVIEW** | Question, explanation, audit, read-only | `skills/general/review-workflow` |
| **NEW DEVELOPMENT** | Building something that doesn't exist | `skills/general/development-workflow` |
| **FIX / UPDATE / REFACTOR** | Changing existing code | `skills/general/fix-workflow` |

Output format before acting:
```
## Request Classification
**Category:** <REVIEW | NEW DEVELOPMENT (New Project / New Feature) | FIX/UPDATE/REFACTOR (sub-type)>
**Rationale:** <one sentence>
**Workflow:** <skill name being followed>
```

Full rule: `rules/request-classification.md`

---

## Behavioral rules (Karpathy guidelines — apply to every task)

### Rule 1 — Think before coding
- State assumptions explicitly before writing a line
- If multiple interpretations exist, ask — do not pick silently
- Ask one clarifying question at a time; wait for the answer before asking the next
- Full rule: `rules/karpathy-guidelines.md`

### Rule 2 — Simplicity first
- Write the minimum code that solves the stated problem
- No speculative features, no single-use abstractions, no hypothetical flexibility
- If you wrote 200 lines and 50 would do, rewrite it

### Rule 3 — Surgical changes
- Touch only what the task requires — no reformatting, renaming, or refactoring adjacent code
- Remove only orphans YOUR changes created; leave pre-existing dead code alone unless asked
- Every changed line must trace directly to the user's request

### Rule 4 — Goal-driven execution
- Reframe every task as a verifiable outcome before starting
- For multi-step tasks: state the plan, verify each step before moving to the next

---

## Session start (before any other action)

1. Read `docs/memory/project-memory.md` — apply special requirements, read last 3 session log entries
2. If the file doesn't exist, create it before any other work

---

## Documentation enforcement (mandatory after every code change)

| Document | Location | When |
|---|---|---|
| Changelog entry | `docs/changelog/changelog.md` | After every code change |
| Decision log | `docs/decisions/decisions.md` | After every architectural choice |
| Session log | `docs/memory/project-memory.md` | At end of every session |
| API design doc | `docs/design/api-<name>.md` | Before any new/changed endpoint |

Full rules: `rules/changelog.md`, `rules/api-design.md`, `rules/project-memory.md`

---

## SDLC agent team (dispatch for new features)

For NEW DEVELOPMENT, dispatch the full agent team in order. Parallel dispatch allowed for independent phases.

| Phase | Agent | File |
|---|---|---|
| Intake & classification | Intake Agent | `agents/intake-agent.md` |
| Requirements | Product Manager | `agents/product-manager-agent.md` |
| Business approval | Business Owner | `agents/business-owner-agent.md` |
| Design | Architect | `agents/architect-agent.md` |
| Design challenge | Decision Challenger | `agents/decision-challenger-agent.md` |
| Implementation orchestration | Tech Lead | `agents/tech-lead-agent.md` |
| Backend | Backend Developer | `agents/backend-developer-agent.md` |
| Frontend | Frontend Developer | `agents/frontend-developer-agent.md` |
| QA | QA Validator | `agents/qa-validator-agent.md` |
| Security | Security Reviewer | `agents/security-reviewer-agent.md` |
| Deployment | SRE / DevOps | `agents/sre-devops-agent.md` |

All agents read and write `docs/memory/agent-handoff.md` for inter-agent communication.

---

## Security rules (non-negotiable)

- Never commit secrets, `.env`, or credentials
- Validate all user input server-side; never trust frontend-only validation
- Use parameterized queries only — no string concatenation into SQL
- Flag auth, payment, and data-deletion changes before editing
- Full rule: `rules/security-baseline.md`

---

## Architecture rules

- Follow existing folder structure strictly
- Do not introduce new abstractions unless used 3+ times
- Prefer editing existing files over creating new ones
- Database access only through the ORM/repository layer
- API schemas must remain backward compatible
- Full rules: `rules/engineering-principles.md`, `rules/backward-compatibility.md`

---

## Testing rules

- Read `docs/testing/testing-strategy.md` at the start of every implementation session
- Add/update tests for every behavior change
- Run the full test suite after changes — all must pass before declaring done
- Never mock internal business logic
- Full rules: `rules/tdd.md`, `rules/testing-enforcement.md`
