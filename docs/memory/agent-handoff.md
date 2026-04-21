# Agent Handoff Log

> Shared communication channel between SDLC agents.
> Every agent writes here when it completes a task that another agent depends on.
> Entries are reverse-chronological (newest first).
> The tech-lead agent reads this to synthesize parallel workstreams.
> Do not delete entries — strike them out when the downstream agent has consumed them.

---

## Format

```markdown
### [YYYY-MM-DD HH:MM] AGENT: <role> | TASK: <short description> | STATUS: complete | ready-for: <next agent or "all">

**Completed:**
- <bullet per deliverable, name specific files and endpoints>

**Decisions made:**
- <non-obvious choices and rationale>

**What downstream agents must know:**
- <API contracts, type names, shared state, integration points>

**Files changed:**
- <comma-separated file paths>
```

---

*(No entries yet — first agent to complete a task writes here.)*
