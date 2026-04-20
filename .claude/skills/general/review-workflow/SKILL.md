# Skill: Review Workflow

---

## When to invoke

Invoked after the intake agent classifies a request as **REVIEW**.
Use for questions, explanations, audits, and read-only analysis — no code changes.

---

## Workflow steps

### Step 1 — Understand the question
- Identify exactly what is being asked: explanation, audit, comparison, status check, or trace
- Identify the scope: a single file, a feature, a system boundary, or the whole codebase
- If the scope is unclear, ask one clarifying question before proceeding

### Step 2 — Locate the relevant context
- Read the relevant files, functions, and tests
- Check related documentation (PRD, ADRs, README)
- Trace the data flow or execution path if needed

### Step 3 — Formulate the answer
Structure the response to match the question type:

| Question type | Response structure |
|---|---|
| "What does X do?" | Describe purpose → inputs/outputs → side effects |
| "How does X work?" | Walk through the execution path step by step |
| "Is this correct?" | State verdict → evidence → what is right / wrong |
| "Review this code" | Correctness → security → performance → style (in that priority order) |
| "Why does X behave this way?" | Root cause → code evidence → link to decision log if applicable |

### Step 4 — Reference sources
- Link to specific file paths and line numbers for every claim
- Quote relevant code inline rather than making general statements
- If a decision is explained in `docs/decisions/decisions.md`, reference the ADR

### Step 5 — Flag problems found during review
Even in a REVIEW, if you discover a bug, security issue, or outdated documentation:
- Report it clearly, labelled as **[FINDING]**
- Do NOT fix it silently — the request was read-only
- Suggest raising it as a Category 3 (Fix) task

---

## Output format

```
## Answer

<Direct response to the question>

## Evidence

- `path/to/file.ts:42` — <what this line shows>
- `path/to/other.ts:17` — <what this line shows>

## Findings (if any)
[FINDING] <description of issue found during review>
→ Suggested action: raise as a Fix/Update task
```

---

## What NOT to do

- Do not make file changes, even small ones
- Do not "fix while reviewing" — file a separate task
- Do not summarise without citing the source
- Do not answer from memory alone — always read the current code
