# Project Memory Rule

## MANDATORY: Read and update project memory every session.

`docs/memory/project-memory.md` is the agent's persistent memory for this project.
It stores non-obvious requirements and session summaries that are not derivable from code or other docs.

**This rule applies to every session — review, development, fix, and refactor alike.**

---

## At session start — read first

Before taking any action, read `docs/memory/project-memory.md` completely.

Check each section:

1. **Special requirements** — apply every listed requirement during the session. Do not proceed if a requirement conflicts with the user's request; surface the conflict and resolve it first.
2. **Session log** — read the last 3 entries to understand recent context: what was built, what decisions were made, what was left unresolved.
3. **Known gotchas** — note anything relevant to the current task so you do not repeat a known mistake.
4. **Pending work** — if the current session picks up a deferred task, confirm with the user before starting.

If the file does not exist, create it from the template structure in `docs/memory/project-memory.md` before doing any other work.

---

## During the session — record special requirements immediately

When you discover a non-obvious constraint, rule, or stakeholder requirement that is not in the code or other docs, add a **Special Requirements** entry immediately — not at the end of the session.

A requirement belongs here if:
- It would surprise a future agent seeing this codebase for the first time
- It explains a decision that looks wrong without context (e.g. "we intentionally do X even though Y is the convention, because Z")
- It is a constraint from a stakeholder, compliance team, or past incident that is not documented elsewhere
- It affects multiple sessions or multiple areas of the codebase

A requirement does NOT belong here if:
- It is already explained by a code comment, ADR, PRD, or changelog entry
- It is a general engineering principle (those live in `rules/engineering-principles.md`)
- It is a one-off task detail relevant only to the current session

**Entry format:**
```markdown
### REQ-NNN — <short title>
**Discovered:** YYYY-MM-DD
**Area:** <backend / frontend / infra / data model / testing / all>
**Requirement:** <what the constraint or rule is>
**Why:** <the reason — stakeholder request, past incident, compliance, architectural decision>
**How to apply:** <when this kicks in, what to do or avoid>
```

Increment the `REQ-NNN` number from the last entry. Use the current date.

---

## During the session — record gotchas immediately

When something goes wrong unexpectedly or a non-obvious fix is required, add a **Known Gotchas** entry before continuing.

A gotcha belongs here if:
- It would cause the same failure again if a future agent encounters it without this knowledge
- The root cause is not obvious from the error or the code
- The fix or workaround is non-standard

---

## At session end — write a session log entry

Before finishing, append a new entry to the **Session log** section (newest first).

**Entry format:**
```markdown
### YYYY-MM-DD — <session topic in 5–10 words>
**Completed:**
- <bullet per deliverable — be specific, name files>

**Decisions made:**
- <any non-obvious choice and its rationale>

**Blockers / open questions:**
- <anything unresolved, unclear, or blocked — or "None">

**Files changed:** <comma-separated list of key files>
```

Rules for the session log:
- Keep each entry under 20 lines — it is a summary, not a transcript
- If a task was attempted but failed, record that too (what was tried, why it failed)
- Deferred tasks must be added to the **Pending work** section with a reason

---

## Memory vs other documents

| Content type | Where it lives |
|---|---|
| Non-obvious project constraints | `docs/memory/project-memory.md` — Special requirements |
| What was built each session | `docs/memory/project-memory.md` — Session log |
| Architectural decisions | `docs/decisions/decisions.md` |
| Feature requirements | `docs/prd/` |
| Bug details and root causes | `docs/prd/fixes/` |
| Code behavior changes | `docs/changelog/changelog.md` |
| Code comments | Source files — only for non-obvious WHY |

Do not duplicate content between these. If something belongs in the changelog or an ADR, put it there — not in memory. Memory captures what the other documents cannot.

---

## Keeping memory healthy

- Remove **Pending work** entries when the work is done
- If a **Special requirement** is later superseded or removed, strike it out and note the date: `~~REQ-001~~  — removed YYYY-MM-DD, reason: <why>`
- Do not let the session log grow beyond 20 entries — summarise older entries into a single "Prior history" paragraph if needed
- Do not copy-paste code snippets into memory — reference the file and line instead
