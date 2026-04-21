# Skill: Systematic Debugging

Source: Scientific method applied to software defects.

---

## When to invoke

Use this skill whenever:
- A test is failing and the cause is not immediately obvious
- A behaviour is wrong but no error is thrown
- An intermittent failure cannot be reliably reproduced
- A fix was applied but the problem persists

Do not skip steps. Every skipped step risks investing an hour chasing a wrong hypothesis.

---

## The five-step method

### Step 1 — Reproduce reliably

A bug you cannot reproduce consistently cannot be safely fixed.

- Identify the exact inputs, state, and conditions that trigger the failure
- Write a minimal reproduction: the smallest code path that shows the wrong behaviour
- If intermittent: add logging and run repeatedly until you capture the failure state
- **Output:** A failing test or a reproducible script that demonstrates the bug

Do not proceed to Step 2 until you have a reliable reproduction.

---

### Step 2 — Narrow the scope

Cut the search space in half with each check.

- Identify the last known good state (last passing commit, last working input)
- Binary search between good and bad: `git bisect` for regression, parameter halving for logic bugs
- Use the stack trace or error message as the starting coordinate — read it fully before searching
- Isolate: can you reproduce in a unit test without the full stack? Without the database? Without the network?
- **Output:** The specific function, module, or line range where the failure originates

---

### Step 3 — State your hypothesis

Before changing any code, write down what you believe is wrong.

Format:
```
Hypothesis: <what I believe is causing the failure>
Evidence for: <why I think this>
Evidence against: <what could disprove this>
Test to falsify: <what I will check to confirm or rule out this hypothesis>
```

A hypothesis that cannot be falsified is not a hypothesis — it is a guess. Do not fix guesses.

---

### Step 4 — Verify the hypothesis

Run the falsification test from Step 3.

- Add targeted logging or assertions at the suspected location
- Use the debugger to inspect state at the suspected line
- Write a unit test that isolates the suspected function and asserts the wrong output

If the test **confirms** the hypothesis → proceed to Step 5.
If the test **refutes** the hypothesis → return to Step 2 with the new evidence. Do not pivot to a new hypothesis without re-narrowing scope.

---

### Step 5 — Fix minimally and verify

Apply the smallest possible change that corrects the root cause.

- Fix the root cause, not the symptom
- Do not fix adjacent issues in the same commit unless they are the same root cause
- Apply `rules/karpathy-guidelines.md` Rule 3 — surgical changes only
- Run the full test suite after the fix — confirm no regressions
- If the fix causes a different test to fail, investigate that failure separately
- **Output:** A passing test suite with the minimal diff that resolves the root cause

---

## Common failure patterns

| Symptom | Where to look first |
|---|---|
| Works locally, fails in CI | Environment differences: env vars, OS, timezone, DB state, file paths |
| Passes in isolation, fails in suite | Test pollution: shared mutable state, missing teardown, ordering dependency |
| Intermittent failure | Race condition, timeout, non-deterministic test data, clock sensitivity |
| Fix applied but bug persists | Wrong layer fixed (symptom not root cause), cache not cleared, wrong environment |
| Regression after refactor | Behaviour assumption changed; test coverage gap revealed by refactor |
| Works for one user, not another | Authorisation, locale, timezone, user-specific state |

---

## Debugging tools to consider

- **Logging**: add structured log statements at suspected entry and exit points; remove after fix
- **Debugger**: attach to the process and step through — faster than print-debugging for complex state
- **git bisect**: binary search through commit history to find the regression commit
- **Diff**: compare working vs broken configuration, input, or environment
- **Isolation**: extract the suspected logic into a pure function and test it in isolation
- **Minimal reproduction**: reduce the failing case to the smallest possible input

---

## Red flags (wrong debugging behaviours)

- Changing code without a hypothesis ("let me try this and see")
- Fixing the assertion instead of the behaviour it tests
- Debugging in production instead of reproducing locally
- Adding `// TODO: fix this properly` and shipping
- Giving up and rewriting the module instead of finding the root cause
- Blaming the framework without ruling out your own code first
