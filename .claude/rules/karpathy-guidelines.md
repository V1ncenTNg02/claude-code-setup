# Karpathy Guidelines
# Behavioral rules to reduce common LLM coding mistakes.
# Source: Andrej Karpathy's observations on LLM coding pitfalls. License: MIT.
#
# These rules govern HOW to think and act — they apply to every task,
# every session, every category (review, development, fix, refactor).
# They are not optional. They are not skipped for "simple" tasks.

---

## Rule 1 — Think before coding

**Do not start writing code until you have stated your understanding of the task.**

Before any implementation:

1. **State your assumptions explicitly.** If you are assuming something about the requirement, say it out loud. Do not silently pick an interpretation.
2. **If multiple interpretations exist, present them.** Ask which one the user intends — do not pick silently.
3. **If a simpler approach exists, say so.** Push back when a request is more complex than it needs to be. The user may not know a simpler path exists.
4. **If something is unclear, stop and name it.** Do not proceed through confusion. Ask the single most important clarifying question.

**The test:** Could a future reader tell exactly what you assumed before you started? If not, surface those assumptions first.

---

## Rule 2 — Simplicity first

**Write the minimum code that solves the stated problem. Nothing more.**

- No features beyond what was explicitly asked for
- No abstractions for code used in only one place
- No "flexibility" or "configurability" that was not requested
- No error handling for scenarios that cannot actually happen
- No premature generalization — three similar cases before an abstraction

**The 200-line test:** If you wrote 200 lines and it could be 50, rewrite it before delivering. Ask: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

**The YAGNI test:** For every class, parameter, and abstraction you add, ask: "Was this explicitly requested or is it for a hypothetical future use?" If the latter, remove it.

---

## Rule 3 — Surgical changes

**Touch only what the task requires. Do not improve adjacent code.**

When editing existing code:
- Do not reformat code you are not changing
- Do not rename things that are not part of the task
- Do not refactor adjacent functions because they "could be cleaner"
- Do not add comments to code you are not modifying
- Match the existing style exactly, even if you would do it differently

**When your changes create orphans** (imports, variables, functions that YOUR edit made unused):
- Remove them — you created the orphan, you clean it up
- Do not remove pre-existing dead code that existed before your change unless the task explicitly asks for it

**The diff test:** Every changed line must trace directly to the user's request. If a changed line cannot be explained by the task, revert it.

---

## Rule 4 — Goal-driven execution

**Transform every task into a verifiable goal before starting.**

Reframe the task as a testable outcome:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces the bug, then make it pass"
- "Refactor X" → "Confirm tests pass before touching anything, then confirm they still pass after"
- "Add feature Y" → "Write the acceptance criteria as failing tests, then implement until green"

**For multi-step tasks, state the plan before executing:**

```
Plan:
1. [What] → verified by: [how you will confirm it worked]
2. [What] → verified by: [how you will confirm it worked]
3. [What] → verified by: [how you will confirm it worked]
```

Do not start step 2 until step 1's verification passes.

**Weak success criteria** ("make it work", "improve performance") require constant clarification.
**Strong success criteria** (a failing test, a specific metric, a measurable outcome) let you loop independently and stop when done.

---

## Application

These rules apply in order of precedence when they conflict with speed:
1. A task with unclear requirements is not started until assumptions are stated (Rule 1)
2. A solution that passes tests but is 4× more complex than needed is not delivered (Rule 2)
3. A PR that touches 20 files for a 2-line bug fix is sent back for revision (Rule 3)
4. A task without a verifiable success criterion is reframed before execution (Rule 4)

Tradeoff: these rules bias toward caution over speed. For a genuinely trivial one-liner,
use judgment. But "this seems simple" is never sufficient justification for skipping Rule 1.
