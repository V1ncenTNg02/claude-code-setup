# Request Classification — Mandatory First Step

## BEFORE doing any work, you MUST classify the incoming request.

This is a non-negotiable gate. Every request falls into exactly one of three categories.
Identify the category, state it explicitly, then follow the corresponding workflow.

---

## The Three Categories

### Category 1 — REVIEW
A question, explanation, audit, or read-only analysis. No code will be written or changed.

**Signal words / patterns:**
- "What does X do?" / "How does X work?" / "Explain X"
- "Is this correct?" / "Review this" / "Audit this"
- "Show me X" / "Find X" / "List X"
- "Why does X behave this way?"
- "What is the status of X?"

**Decision rule:** If completing the request requires zero file changes → it is a REVIEW.

**Workflow:** → [Review Workflow](../skills/general/review-workflow/SKILL.md)

---

### Category 2 — NEW DEVELOPMENT
Building something that does not yet exist. Requires the full SDLC with documentation.

Sub-types — state which one applies:

| Sub-type | Description |
|---|---|
| **New Project** | A greenfield codebase, service, or product from scratch |
| **New Feature** | A new capability added to an existing project |

**Signal words / patterns:**
- "Build X" / "Create X" / "Add X" / "Implement X"
- "New feature: X" / "I need X to do Y (which it does not do today)"
- The thing described does not yet exist in the codebase

**Decision rule:** If the primary deliverable is code/functionality that does not exist → it is NEW DEVELOPMENT.

**Workflow:** → [Development Workflow](../skills/general/development-workflow/SKILL.md)

---

### Category 3 — FIX / UPDATE / REFACTOR
Changing something that already exists. The scope is bounded by the existing implementation.

Sub-types — state which one applies:

| Sub-type | Description |
|---|---|
| **Bug Fix** | Correcting behaviour that is unintended or broken |
| **Update** | Modifying existing behaviour to meet new requirements |
| **Refactor** | Restructuring internals without changing observable behaviour |
| **Performance** | Improving speed, memory, or resource usage of existing code |
| **Security Patch** | Fixing a vulnerability in existing code |
| **Dependency Upgrade** | Updating a library or tool version |

**Signal words / patterns:**
- "Fix X" / "X is broken" / "X is not working"
- "Update X" / "Change X to do Y instead"
- "Refactor X" / "Clean up X" / "Optimise X"
- "Upgrade X" / "Patch X"

**Decision rule:** If the primary deliverable modifies something that already exists → it is a FIX / UPDATE / REFACTOR.

**Workflow:** → [Fix / Update / Refactor Workflow](../skills/general/fix-workflow/SKILL.md)

---

## Classification Protocol

When a request arrives, output this block **before any other action**:

```
## Request Classification

**Category:** REVIEW | NEW DEVELOPMENT (New Project / New Feature) | FIX/UPDATE/REFACTOR (sub-type)
**Rationale:** <one sentence explaining why this category applies>
**Workflow:** <name of the workflow being followed>
```

If a request spans multiple categories (e.g., "fix the bug AND add a new feature"), split it:
- Classify the fix as Category 3 and complete it first
- Classify the new feature as Category 2 and treat it as a separate task

If the category is ambiguous, ask one clarifying question before proceeding.

---

## Why This Matters

Different categories carry different risk, documentation requirements, and review gates:

| Category | PRD required | Tests required | Changelog entry | Decision log |
|---|---|---|---|---|
| REVIEW | No | No | No | No |
| NEW DEVELOPMENT | Yes | Yes (TDD) | Yes | Yes (if architectural) |
| FIX / UPDATE / REFACTOR | Fix brief for non-trivial | Yes | Yes | Yes (if design changed) |
