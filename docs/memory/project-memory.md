# Project Memory

> This file is the AI agent's persistent memory for this project.
> It is read at the start of every session and updated before every session ends.
> It is NOT a substitute for code comments, changelog entries, or ADRs.
> It captures what those documents cannot: non-obvious constraints, failed attempts,
> discovered gotchas, and a running summary of what each session accomplished.

---

## Special requirements

> Non-obvious constraints, rules, and decisions that are not derivable from the code itself.
> Add entries here when something would surprise a future agent working on this project.
> Each entry must explain the WHY — not just the what.

<!--
Format per entry:
### REQ-NNN — <short title>
**Discovered:** YYYY-MM-DD
**Area:** <backend / frontend / infra / data model / testing / all>
**Requirement:** <what the constraint or rule is>
**Why:** <the reason — stakeholder request, past incident, compliance, architectural decision>
**How to apply:** <when this kicks in, what to do or avoid>
-->

*(No special requirements recorded yet. Add the first one when discovered.)*

---

## Session log

> A reverse-chronological log of what each agent session accomplished, decided, or attempted.
> The most recent session appears first.
> Each entry is a summary — not a full transcript. Focus on outcomes, decisions, and blockers.

<!--
Format per entry:
### YYYY-MM-DD — <session topic>
**Completed:**
- <what was built or fixed>

**Decisions made:**
- <any non-obvious choice made during the session and why>

**Blockers / open questions:**
- <anything that was blocked, unclear, or left for the next session>

**Files changed:** <comma-separated list of the key files modified>
-->

*(No sessions recorded yet.)*

---

## Known gotchas

> Things that went wrong, caused confusion, or required a non-obvious fix.
> Add here so the next session does not repeat the same mistake.

<!--
Format per entry:
### <short description of the gotcha>
**Area:** <file path, module, or domain>
**What happened:** <what the surprising behaviour or failure was>
**Root cause:** <why it happened>
**Fix / workaround:** <what to do when you encounter this>
-->

*(No gotchas recorded yet.)*

---

## Pending work from previous sessions

> Tasks explicitly deferred to a future session. Remove entries when the work is done.

<!--
Format per entry:
- [ ] <task description> — deferred from YYYY-MM-DD session, reason: <why it was deferred>
-->

*(Nothing pending.)*
