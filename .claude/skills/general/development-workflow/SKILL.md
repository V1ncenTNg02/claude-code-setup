# Skill: Development Workflow (New Project / New Feature)

---

## When to invoke

Invoked after the intake agent classifies a request as **NEW DEVELOPMENT**.
Applies to both New Project and New Feature sub-types — the steps are the same,
but the PRD template differs.

---

## Design hierarchy — enforced by this workflow

```
Data Model & Domain Entities        ← Phase 2: designed first, everything flows from this
        ↓
Architecture & Service Boundaries   ← Phase 3: built on top of the data model
        ↓
API Contracts & Interfaces          ← Phase 3: derived from architecture
        ↓
Implementation (TDD)                ← Phase 4: built on top of all the above
```

**The data model is non-negotiable as the first design artifact.** No architecture,
no API design, and no implementation may begin until the data model is approved by the user.

**Every design artifact requires explicit user approval before the next phase begins.**
The agent must stop, present the document, and wait for a clear "approved" or "looks good"
before proceeding. A non-response or silence is not approval.

---

## PRD templates

| Sub-type | Template |
|---|---|
| New Project | `docs/prd/templates/new-project-prd.md` |
| New Feature | `docs/prd/templates/new-feature-brief.md` |

---

## Workflow steps

---

### Phase 1 — Discovery & Requirements

**Step 1.1 — Create the PRD document**
- Copy the appropriate template into `docs/prd/`
  - New Project: `docs/prd/PROJECT-NAME-v1.0.0.md`
  - New Feature: `docs/prd/features/FEAT-NNN-feature-name.md`
- Fill in every section. Do not leave placeholders — ask the user for missing information.
- One clarifying question at a time until the PRD is complete.

**Step 1.2 — Challenge the PRD**
- Invoke `agents/decision-challenger-agent.md` to review the completed PRD
- The challenger probes for missing considerations, untested assumptions, and scope gaps
- Answer each challenge question before proceeding to the next
- Maximum three challenge rounds; the challenger closes when satisfied

**Step 1.3 — Human review gate: PRD**
- Present the completed PRD (with all challenges resolved) to the user
- State clearly: "The PRD is ready for your review. Please confirm all sections before I begin design work."
- **Do not proceed until the user explicitly approves the PRD.**

**Gate: PRD must be challenged and approved by the user before any design work begins.**

---

### Phase 2 — Data Model Design

> The data model is the center of the system. Every business rule, service boundary,
> API shape, and storage decision is derived from it. It must be designed before anything else.

**Step 2.1 — Apply the data model design skill**
- Invoke `skills/general/data-model-design/SKILL.md`
- Extract domain entities, value objects, and aggregates from the PRD use cases
- Define relationships, ownership boundaries, and lifecycle state machines
- Define key domain decisions: identifiers, timestamps, deletion strategy, money representation

**Step 2.2 — Make storage technology decisions**
- For each aggregate, decide: SQL, document store, key-value store, wide-column, or graph
- Apply the SQL vs NoSQL decision criteria from `skills/general/data-model-design/SKILL.md`
- Record each decision with its rationale in the data model document

**Step 2.3 — Produce the data model document**
- Complete `docs/design/data-model-<name>.md` using the template at `docs/design/data-model-template.md`
- The document must cover: entities, relationships, lifecycle states, attributes, storage decisions

**Step 2.4 — Challenge the data model**
- Invoke `agents/decision-challenger-agent.md` to review the data model document
- The challenger probes for: missing entities, incorrect ownership boundaries, wrong storage choices, unmodelled state transitions, and missing domain invariants
- Answer each challenge question before proceeding
- Maximum three challenge rounds; the challenger closes when satisfied

**Step 2.5 — Record data model decisions**
- Append an ADR to `docs/decisions/decisions.md` for every non-obvious data model choice
- ADR candidates: storage technology per aggregate, identifier strategy, soft vs hard delete, consistency model

**Step 2.6 — Human review gate: Data model**
- Present `docs/design/data-model-<name>.md` to the user
- Summarise: entities, aggregate boundaries, lifecycle states, and storage decisions
- State clearly: "The data model design is ready for your review. Please approve it before I begin architecture design."
- **Do not proceed to Phase 3 until the user explicitly approves the data model.**

**Gate: Data model must be complete, challenged, and approved by the user before architecture or API design begins.**

---

### Phase 3 — Architecture & Design

> Architecture is built on top of the data model. The data model informs every
> boundary, service, and interface defined here.

#### Part A — Backend Architecture

**Step 3.1 — Backend architecture design**
- Apply `skills/backend/architecture/SKILL.md` (or equivalent for the domain)
- Identify layers, service boundaries, and data flow — all derived from the data model
- Map each aggregate to a service or module boundary
- Check for violations of the Dependency Rule
- Produce `docs/design/architecture-backend-<name>.md`

**Step 3.2 — Record and challenge backend architecture decisions**
- For every non-obvious architectural choice, append an ADR to `docs/decisions/decisions.md`
- Decisions include: service boundaries, communication patterns, security model
- Invoke `agents/decision-challenger-agent.md` once per ADR written
- Maximum three challenge rounds per ADR

**Step 3.3 — Human review gate: Backend architecture**
- Present `docs/design/architecture-backend-<name>.md` and all related ADRs to the user
- State clearly: "The backend architecture design is ready for your review. Please approve it before I continue."
- **Do not proceed until the user explicitly approves the backend architecture.**

---

#### Part B — Frontend Architecture (skip if no frontend)

**Step 3.4 — Frontend architecture design**
- Apply `skills/frontend/frontend-architecture/SKILL.md`
- Define component boundaries, state management scope, data fetching placement, and rendering strategy
- Produce `docs/design/architecture-frontend-<name>.md`

**Step 3.5 — Record and challenge frontend architecture decisions**
- Append an ADR to `docs/decisions/decisions.md` for non-obvious frontend choices
- Decisions include: state management library, rendering strategy, routing approach
- Invoke `agents/decision-challenger-agent.md` once per ADR written
- Maximum three challenge rounds per ADR

**Step 3.6 — Human review gate: Frontend architecture**
- Present `docs/design/architecture-frontend-<name>.md` and all related ADRs to the user
- State clearly: "The frontend architecture design is ready for your review. Please approve it before I continue."
- **Do not proceed until the user explicitly approves the frontend architecture.**

---

#### Part C — API Contract Design

**Step 3.7 — API contract design**
- Use the template at `docs/design/api-design-template.md`
- Define request/response shapes — derived from the domain model, not the other way around
- API shapes are projections of domain entities, not the entities themselves
- Define error codes, pagination, versioning strategy, and rate limiting
- Save as `docs/design/api-<name>.md`

**Step 3.8 — Record and challenge API design decisions**
- Append an ADR to `docs/decisions/decisions.md` for non-obvious API choices
- Decisions include: versioning strategy, pagination strategy, breaking change policy
- Invoke `agents/decision-challenger-agent.md` once per ADR written
- Maximum three challenge rounds per ADR

**Step 3.9 — Human review gate: API contracts**
- Present `docs/design/api-<name>.md` and all related ADRs to the user
- State clearly: "The API contract design is ready for your review. Please approve it before I begin implementation."
- **Do not proceed to Phase 4 until the user explicitly approves the API design.**

**Gate: All architecture documents must be challenged and approved by the user before implementation begins.**

---

### Phase 4 — Test-Driven Development

**Step 4.1 — Write failing tests first (RED)**
- Apply `rules/tdd.md`
- Write tests derived from the PRD acceptance criteria
- Tests at the domain level test entities and aggregates directly
- Confirm all tests fail before writing implementation

**Step 4.2 — Write minimum implementation (GREEN)**
- Write only enough code to make the tests pass
- Implementation follows the data model — entity structure, aggregate boundaries, and state machines are already defined
- Do not add anything the tests do not cover yet

**Step 4.3 — Refactor (if needed)**
- Improve structure without changing behaviour
- All tests must remain green after every refactor step

---

### Phase 5 — Validation

**Step 5.1 — Run the full quality gate**
- Lint: no lint errors
- Static analysis / type check: no errors
- Tests: all pass, including new ones
- Security: apply `skills/backend/security-review/SKILL.md` for any API or data change

**Step 5.2 — Review against PRD acceptance criteria**
- Verify every acceptance criterion is met by a passing test
- If a criterion has no test, write one before declaring done

---

### Phase 6 — Documentation

**Step 6.1 — Update changelog**
- Append an entry to `docs/changelog/changelog.md`
- Type: `feat`

**Step 6.2 — Update decision log**
- Append any remaining decisions to `docs/decisions/decisions.md`

**Step 6.3 — Update PRD and data model status**
- Change PRD status from `Draft` to `Implemented`
- Change data model document status from `Draft` to `Final`
- Add implementation date to revision histories

---

## Gate summary

| Gate | What must be true | Who confirms |
|---|---|---|
| After Phase 1, Step 1.2 | PRD challenged, all questions answered | Challenger agent |
| After Phase 1, Step 1.3 | PRD approved, no placeholders | **User** |
| After Phase 2, Step 2.4 | Data model challenged and closed | Challenger agent |
| After Phase 2, Step 2.5 | Storage decisions recorded as ADRs | Agent |
| After Phase 2, Step 2.6 | Data model approved | **User** |
| After Phase 3, Step 3.2 | Backend architecture ADRs challenged | Challenger agent |
| After Phase 3, Step 3.3 | Backend architecture approved | **User** |
| After Phase 3, Step 3.5 | Frontend architecture ADRs challenged | Challenger agent |
| After Phase 3, Step 3.6 | Frontend architecture approved (if applicable) | **User** |
| After Phase 3, Step 3.8 | API design ADRs challenged | Challenger agent |
| After Phase 3, Step 3.9 | API contracts approved | **User** |
| After Phase 4 | All tests written first, all green | Agent |
| After Phase 5 | Quality checks pass, all criteria covered | Agent |
| After Phase 6 | Changelog, decisions, and docs updated | Agent |

---

## What NOT to do

- Do not begin architecture or API design before the data model document is approved by the user
- Do not let API shapes drive the data model — the data model drives the API
- Do not write implementation before failing tests exist
- Do not mark done if any PRD acceptance criterion has no passing test
- Do not skip the changelog entry
- Do not interpret silence as approval — wait for an explicit "approved" or "looks good"
