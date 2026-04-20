# Skill: Development Workflow (New Project / New Feature)

---

## When to invoke

Invoked after the intake agent classifies a request as **NEW DEVELOPMENT**.
Applies to both New Project and New Feature sub-types — the steps are the same,
but the PRD template differs.

---

## PRD templates

| Sub-type | Template |
|---|---|
| New Project | `docs/prd/templates/new-project-prd.md` |
| New Feature | `docs/prd/templates/new-feature-brief.md` |

---

## Workflow steps

### Phase 1 — Discovery & Requirements

**Step 1.1 — Create the PRD document**
- Copy the appropriate template into `docs/prd/`
  - New Project: `docs/prd/PROJECT-NAME-v1.0.0.md`
  - New Feature: `docs/prd/features/FEAT-NNN-feature-name.md`
- Fill in every section. Do not leave placeholders — ask the user for missing information.
- One clarifying question at a time until the PRD is complete.

**Step 1.2 — PRD review gate**
- Present the completed PRD to the user
- Confirm all sections before proceeding
- Record acceptance: `docs/decisions/decisions.md` if the scope involved an architectural choice

**Gate: PRD must be approved before any design or code work begins.**

---

### Phase 2 — Architecture & Design

**Step 2.1 — Architecture review**
- Apply `skills/backend/architecture/SKILL.md` (or equivalent for the domain)
- Identify layers, boundaries, data flow, and integration points
- Check for violations of the Dependency Rule

**Step 2.2 — Record decisions**
- For every non-obvious architectural choice, append an ADR to `docs/decisions/decisions.md`
- Decisions include: data model choices, API design choices, technology selections, security model

**Step 2.3 — API and data contract design (if applicable)**
- Apply `skills/backend/api-contract-validator/SKILL.md`
- Define request/response shapes before writing implementation

---

### Phase 3 — Test-Driven Development

**Step 3.1 — Write failing tests first (RED)**
- Apply `rules/tdd.md`
- Write tests that describe the acceptance criteria from the PRD
- Confirm the tests fail before writing implementation

**Step 3.2 — Write minimum implementation (GREEN)**
- Write only enough code to make the tests pass
- Do not add anything the tests do not cover yet

**Step 3.3 — Refactor (if needed)**
- Improve structure without changing behaviour
- All tests must remain green after every refactor step

---

### Phase 4 — Validation

**Step 4.1 — Run the full quality gate**
- Lint: no lint errors
- Typecheck: no type errors
- Tests: all tests pass, including the new ones
- Security: apply `skills/backend/security-review/SKILL.md` for any API or data change

**Step 4.2 — Review against the PRD acceptance criteria**
- Verify every acceptance criterion in the PRD is met by a passing test
- If a criterion has no test, write one before declaring done

---

### Phase 5 — Documentation

**Step 5.1 — Update changelog**
- Append an entry to `docs/changelog/changelog.md`
- Type: `feat`

**Step 5.2 — Update decision log**
- Append any remaining architectural decisions to `docs/decisions/decisions.md`

**Step 5.3 — Update PRD status**
- Change the PRD document status from `Draft` to `Implemented`
- Add the implementation date to the revision history

---

## Gate summary

| Gate | What must be true | Who confirms |
|---|---|---|
| After Phase 1 | PRD approved, no placeholders | User |
| After Phase 2 | Architecture reviewed, decisions recorded | Agent |
| After Phase 3 | Tests written first, all green | Agent |
| After Phase 4 | All quality checks pass, criteria covered | Agent |
| After Phase 5 | Changelog and decisions updated | Agent |

---

## What NOT to do

- Do not write implementation code before the PRD is approved
- Do not write implementation code before failing tests exist
- Do not mark a feature as done if any PRD acceptance criterion has no test
- Do not skip the changelog entry even for "obvious" changes
