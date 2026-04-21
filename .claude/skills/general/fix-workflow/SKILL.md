# Skill: Fix / Update / Refactor Workflow

---

## When to invoke

Invoked after the intake agent classifies a request as **FIX / UPDATE / REFACTOR**.
Applies to all sub-types: Bug Fix, Update, Refactor, Performance, Security Patch, Dependency Upgrade.

---

## Fix brief requirement

| Sub-type | Fix brief required? |
|---|---|
| Bug Fix | Yes — always (to document root cause) |
| Update | Yes — if the change affects behaviour visible to other code or users |
| Refactor | No — if purely internal with no behaviour change |
| Performance | No — if no API or behaviour change; yes if it changes interfaces |
| Security Patch | Yes — always (for audit trail) |
| Dependency Upgrade | No — unless it introduces breaking changes |

Fix briefs live at `docs/prd/fixes/FIX-NNN-short-description.md`.
Use the template at `docs/prd/templates/fix-update-brief.md`.

---

## Workflow steps

### Phase 1 — Understand Before Touching

**Step 1.1 — Reproduce the problem (for Bug Fix)**
- Identify the exact inputs and conditions that trigger the bug
- Locate the failing code path
- Write a failing test that reproduces the bug **before touching any implementation**

**Step 1.1 — Understand the scope (for Update / Refactor / Performance)**
- Read the existing implementation in full before proposing changes
- Identify every caller, consumer, or dependent of the code being changed
- List what must remain unchanged (interfaces, behaviour, contracts)

**Step 1.2 — Root cause analysis (for Bug Fix)**
- Identify the root cause — not just the symptom
- State the root cause explicitly: "The bug is caused by X at file:line"
- Do not fix a symptom if the root cause is different

**Step 1.3 — Create fix brief (if required)**
- Fill in `docs/prd/templates/fix-update-brief.md`
- Save to `docs/prd/fixes/FIX-NNN-short-description.md`
- The brief must be complete before implementation begins

**Step 1.4 — Challenge the fix brief (if brief was created)**
- Invoke `agents/decision-challenger-agent.md` to review the completed fix brief
- The challenger probes for: root cause misdiagnosis, incomplete risk assessment, missing rollback steps, and unconsidered failure modes
- Answer each challenge question before proceeding
- Maximum three challenge rounds; the challenger closes when satisfied

**Gate: Root cause identified and fix brief challenged before any code changes.**

---

### Phase 2 — Test-Driven Fix

**Step 2.1 — Write a failing test (RED)**
- For Bug Fix: the failing test reproduces the bug exactly
- For Update: the failing test describes the new expected behaviour
- Confirm the test fails before writing any fix

**Step 2.2 — Implement the minimal fix (GREEN)**
- Make only the change necessary to make the test pass
- Do not refactor unrelated code in the same commit
- Do not expand scope during a bug fix

**Step 2.3 — Verify no regressions**
- Run the full test suite, not just the new test
- If any existing test fails, fix the regression before proceeding
- Do not suppress or skip failing tests

---

### Phase 3 — Validation

**Step 3.1 — Quality gate**
- Lint: no lint errors
- Typecheck: no type errors
- Tests: all pass, including new and existing

**Step 3.2 — Risk assessment**
- Identify what this change could break
- State the blast radius explicitly: "This change affects X callers in Y files"
- For high-blast-radius changes, flag for human review before merging

**Step 3.3 — Security check (for Security Patch)**
- Apply `skills/backend/security-review/SKILL.md`
- Verify the vulnerability is fully addressed, not just partially mitigated

---

### Phase 4 — Documentation

**Step 4.1 — Update changelog**
- Append an entry to `docs/changelog/changelog.md`
- Type: `fix` | `refactor` | `chore` (matching the sub-type)

**Step 4.2 — Update decision log (if applicable)**
- If the fix revealed a design problem and a structural decision was made, record it
- Append to `docs/decisions/decisions.md`

**Step 4.3 — Update fix brief status (if brief was created)**
- Change status from `In Progress` to `Resolved`
- Add the resolution date and the test that verified the fix

---

## Gate summary

| Gate | What must be true |
|---|---|
| After Step 1.4 | Fix brief challenged and closed (if brief required) |
| Before implementation | Root cause identified (for bugs); scope bounded (for all) |
| Before implementation | Failing test written and confirmed failing |
| After implementation | All tests pass, no regressions |
| After implementation | Blast radius assessed |
| After completion | Changelog updated; decision log updated if structural change |

---

## What NOT to do

- Do not fix a symptom without identifying the root cause
- Do not expand scope during a fix ("while I'm here I'll also refactor…") — raise a separate task
- Do not skip the failing test step — a fix without a test will regress
- Do not merge if any existing test is failing
- Do not skip the changelog entry
