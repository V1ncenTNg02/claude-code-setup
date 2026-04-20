# Test-Driven Development (TDD) Enforcement

## MANDATORY: Write Tests Before Implementation

**All features must follow Red-Green-Refactor. No exceptions.**

You are NOT allowed to write implementation code for a new feature unless a failing
test for that feature already exists in the repository.

## The Required Workflow

### Step 1 — Red: Write a Failing Test
1. Read the requirement or acceptance criterion
2. Create or open the test file for the feature
3. Write one or more tests that describe the expected behaviour
4. Verify the tests fail (because the implementation does not exist yet)
5. **Commit:** `test: write failing tests for <feature>`

### Step 2 — Green: Write Minimum Implementation
1. Write the smallest amount of code that makes the tests pass
2. Do not add anything beyond what the tests require
3. Run the tests — confirm they all pass
4. **Commit:** `feat: implement <feature> to pass tests`

### Step 3 — Refactor: Clean Up (if needed)
1. Improve code quality without changing behaviour
2. Re-run tests after every refactor step — all must remain green
3. **Commit:** `refactor: clean up <feature>` (only if the refactor was non-trivial)

## What Counts as a "Test"

Tests must verify **behaviour at boundaries**, not implementation details. Every test suite must cover:

- **Happy path**: the primary success scenario
- **Error/edge cases**: at least one failure, boundary value, or invalid input scenario
- **Side effects**: verify that state changes, persisted records, or emitted events occurred as expected

### Backend tests
- API endpoint tests: verify HTTP method, path, request body → expected status code and response shape
- Persistence tests: verify the data store contains the correct values after an operation
- Unit tests for pure business logic (calculations, validation, transformations)

### Frontend tests
- Component tests: render the component, assert visible output matches expected state
- Logic/composable tests: pure logic, input → output, no DOM dependency
- API layer tests: mock the network boundary, assert correct requests and response handling

## Test File Naming & Location

- Mirror the source file structure: a test for `src/orders/create.ts` lives at `src/orders/create.test.ts` (or `__tests__/create.test.ts`)
- One test file per feature or module — do not merge unrelated concerns
- Use the project's established convention; do not introduce a new one

## What NOT to Do

- Do NOT write any implementation code before a failing test exists
- Do NOT write "happy path only" — each suite must include at least one error or edge case
- Do NOT mock internal business logic — only mock external boundaries (network, file system, external services)
- Do NOT skip or comment out failing tests to make the suite green
- Do NOT test third-party library internals — only test how your code uses them
