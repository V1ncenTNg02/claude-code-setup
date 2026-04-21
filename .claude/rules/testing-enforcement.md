# Testing Enforcement Rule

## MANDATORY: Read the testing strategy at the start of every implementation session.

Before writing any implementation or test code, read `docs/testing/testing-strategy.md` in full.

**This rule is non-negotiable. It applies to all sessions involving feature work, bug fixes, refactors, or test authoring.**

---

## Session start checklist (run before any implementation)

1. **Read `docs/testing/testing-strategy.md`** — confirm the testing philosophy (TDD or test-after), frameworks, and test commands for this project. If the file does not exist, ask the user to create it from `docs/testing/testing-strategy-template.md` before proceeding.

2. **Confirm test commands are configured** — check that the "Test commands summary" table in `docs/testing/testing-strategy.md` has no placeholders. If any command is missing, ask the user to fill it in. Do not guess test commands.

3. **Confirm hooks are wired** — verify `.claude/settings.json` contains the `Stop` and `PostToolUse` hooks with real commands (not the placeholder text). Remind the user to configure them if not done.

4. **Check for failing tests before starting** — run the fast unit test suite. If pre-existing tests are failing, surface them to the user before writing new code. Do not add new features on top of failing tests.

---

## Enforcement by testing philosophy

### If philosophy is TDD

Follow `rules/tdd.md` exactly:
- Write the failing test first — no exceptions
- Confirm the test fails before writing any implementation
- Write only enough implementation to make the test pass
- Do not proceed to refactor until the test is green

### If philosophy is test-after

- Write implementation
- Write tests **immediately after**, before moving to the next file or task
- Tests must cover: happy path, at least one error case, at least one edge case
- Do not move to the next task until tests for the current task are written and green

---

## Frontend testing rules

**What must be tested:**
- Every component: rendered output, user interactions, conditional states (loading / error / data / empty)
- Every custom hook or composable: input → output logic
- Every utility function: pure logic, edge cases

**What must NOT be tested:**
- Framework internals (React reconciler, Vue reactivity)
- CSS or visual layout — use visual regression for that
- Third-party library internals

**Component isolation requirement:**
- Each component test must render the component in isolation
- Do not test the component by navigating to a page — use the test harness directly
- Mock only external boundaries (API calls), never internal logic

**Running frontend tests:**
Use the commands defined in `docs/testing/testing-strategy.md`.
After every component or logic file change, run the fast unit/component suite before moving on.

---

## Backend testing rules

**What must be tested:**
- Every domain entity, aggregate, and value object: state transitions, invariants, guard conditions
- Every service method: success path, validation errors, not-found errors
- Every API endpoint: valid request, invalid request (schema), unauthorized request, error response shape

**Database tests use a real database — never mock the DB layer:**
- Use the strategy defined in `docs/testing/testing-strategy.md` (transaction rollback / test containers / fixtures)
- A test that mocks the database is unreliable — it will not catch migration failures or query errors

**Running backend tests:**
Use the commands defined in `docs/testing/testing-strategy.md`.
After every service or handler change, run unit + integration suites before moving on.

---

## After every implementation task

Before reporting a task complete:

1. Run the full test suite (all tests, not just the new ones)
2. Confirm zero failing tests — if any fail, fix them before declaring done
3. Confirm coverage meets the thresholds in `docs/testing/testing-strategy.md`
4. If a test was skipped or commented out to make the suite green, revert that and fix the test instead

**Do not declare a task done if any test is failing.**

---

## When tests fail unexpectedly

1. Do not suppress or skip the failing test
2. Do not amend the assertion to match the wrong output
3. Identify whether it is a test bug (wrong assertion) or an implementation bug (wrong behaviour)
4. Fix the root cause — never the symptom
5. Apply `skills/general/fix-workflow/SKILL.md` if the failure reveals a real bug

---

## What NOT to do

- Do not skip writing tests because "it's a small change" — small changes regress too
- Do not mock the database in integration tests — use a real DB per the testing strategy
- Do not write only happy-path tests — error and edge cases are mandatory
- Do not leave commented-out tests — delete them or fix them
- Do not run only the new test file — always run the full suite before finishing
