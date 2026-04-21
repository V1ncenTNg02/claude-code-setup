# Testing Strategy

**Project:** <name>
**Version:** 1.0
**Status:** Draft
**Date:** YYYY-MM-DD
**Author(s):** <name(s)>

> Save as: `docs/testing/testing-strategy.md` (one file per project).
> The agent MUST read this file at the start of any session involving tests or implementation.
> When this file changes, update the test commands in `.claude/settings.json` hooks accordingly.

---

## Testing philosophy

Choose one and delete the other:

- **TDD (Test-Driven Development):** Tests are written before implementation. Every feature starts with a failing test. Follow `rules/tdd.md` strictly.
- **Test-after:** Tests are written immediately after implementation, before the PR is opened. No feature is complete without passing tests covering happy path and at least one error case.

**Coverage policy:**
- Critical paths (auth, payment, data mutations): ≥ **95%** line coverage
- Business logic and domain services: ≥ **80%** line coverage
- UI presentational components: ≥ **70%** line coverage
- Utilities and helpers: ≥ **80%** line coverage
- Overall project minimum: ≥ `<N>`%

---

## Frontend testing

### Unit / logic tests

**Framework:** `<Jest / Vitest / Jasmine / Mocha / other>`

**What to test:**
- Pure functions, hooks, composables, stores — anything with input→output logic
- Validation, formatting, calculation utilities
- State transitions and reducers

**What NOT to test:**
- Framework internals (React rendering, Vue reactivity engine)
- Third-party library behaviour — only how your code uses them
- Implementation details (internal variable names, private methods)

**Test file location:** `<co-located: src/foo/foo.test.ts / separate: __tests__/foo.test.ts>`

**Run command:** `<e.g. vitest run / jest>`

---

### Component tests

**Framework:** `<Testing Library (React/Vue/Svelte) / Enzyme / other>`

**What to test:**
- Rendered output given specific props
- User interaction events (click, input, submit)
- Conditional rendering (loading state, error state, empty state, data state)
- Accessibility: labels, roles, keyboard navigation

**What NOT to test:**
- CSS styles (use visual regression for that)
- Internal component implementation details
- Child component implementation — only that the child is rendered with correct props

**Run command:** `<e.g. vitest run --testNamePattern=component>`

---

### End-to-end tests

**Framework:** `<Playwright / Cypress / Puppeteer / other>`

**Scope:** Critical user journeys only — not every feature. E2E tests are slow and expensive.

**Journeys to cover:**
- `<e.g. User sign-up and first login>`
- `<e.g. Complete checkout flow>`
- `<e.g. Core CRUD workflow for primary entity>`

**What NOT to E2E test:**
- Every UI state — use component tests instead
- API error handling — use API tests instead
- Anything that takes > 30 seconds end-to-end

**Run command:** `<e.g. playwright test / cypress run>`

---

### Visual regression (optional)

**Tool:** `<Storybook + Chromatic / Percy / Playwright screenshots / none>`

**Policy:** `<Run on every PR / run on design-system changes only / not used>`

---

## Backend testing

### Unit tests

**Framework:** `<Jest / Vitest / pytest / Go test / JUnit / other>`

**What to test:**
- Domain entities, value objects, and aggregate logic
- Pure service functions (no I/O)
- Validators, transformers, calculators

**Mocking policy:**
- Mock **only at architectural boundaries**: external HTTP calls, message queues, email/SMS providers
- Never mock the database — use a real test database (see integration tests below)
- Never mock internal business logic

**Run command:** `<e.g. jest --testPathPattern=unit / pytest -m unit>`

---

### Integration tests

**What to test:**
- Repository methods against a real database
- Service methods that orchestrate multiple repositories
- End-to-end request handling (handler → service → repository → DB)

**Database strategy:**
Choose one:
- **Transaction rollback:** each test runs inside a transaction that is rolled back after the test — fast and clean
- **Test containers:** spin up a fresh database container per test suite — slow but production-realistic
- **Shared test DB with fixtures:** reset to known state via seed before each suite — moderate speed, predictable

**Chosen strategy:** `<transaction rollback / test containers / shared test DB>`

**Test database:** `<connection string pattern or env var name>`

**Run command:** `<e.g. jest --testPathPattern=integration / pytest -m integration>`

---

### API / endpoint tests

**What to test:**
- HTTP method and path → expected status code
- Request body validation (valid, missing fields, wrong types)
- Response body shape (fields present, correct types)
- Auth enforcement (authenticated vs unauthenticated requests)
- Error responses (correct code, message structure)

**Tool:** `<Supertest / httpx / net/http/httptest / other>`

**Run command:** `<e.g. jest --testPathPattern=api>`

---

### Contract tests (for services that communicate)

**Tool:** `<Pact / Spring Cloud Contract / none>`

**Policy:** `<Consumer-driven contracts for all inter-service calls / not used>`

**Run command:** `<e.g. pact verify>`

---

## Test commands summary

These values must also be entered in CLAUDE.md Common Commands and in `.claude/settings.json` hooks.

| Scope | Command | When to run |
|---|---|---|
| Frontend unit | `<command>` | After every component or logic change |
| Frontend component | `<command>` | After every component change |
| Frontend E2E | `<command>` | Before PR merge; not on every change |
| Backend unit | `<command>` | After every domain/service change |
| Backend integration | `<command>` | After every repository or DB change |
| Backend API | `<command>` | After every handler change |
| All tests | `<command>` | Before declaring any task done |

---

## Hook configuration

Hooks are defined as shell scripts in `.claude/hooks/` and wired into `.claude/settings.json`.
The scripts are already wired — you only need to edit the scripts to add real commands.

**`.claude/hooks/stop-run-tests.sh`** — runs after every Claude response
- Uncomment the test command that matches your stack
- Should run the full relevant suite: unit + integration (backend) or unit + component (frontend)

**`.claude/hooks/post-edit-run-fast-tests.sh`** — runs after every file edit
- Uncomment the fast unit-test command only (must complete in under 10 seconds)
- Skips docs, config, and non-source files automatically
- Use `jest --findRelatedTests` or `vitest related` to run only the test for the edited file

**Guidance on hook scope:**
- `Stop` hook → full relevant suite (unit + integration for backend; unit + component for frontend)
- `PostToolUse` on Edit/Write → fast unit tests only (< 10 seconds); no E2E, no integration
- Monorepo: run both frontend and backend unit suites in the Stop hook

---

## CI/CD gates

The following must pass before any PR is merged:

- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] All API tests pass
- [ ] Coverage meets the thresholds defined above
- [ ] No tests skipped or commented out
- [ ] E2E tests pass on the target environment (staging / preview)
