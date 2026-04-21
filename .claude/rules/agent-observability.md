# Agent Observability Rule

## Every Agent and Skill call is logged automatically.

The `PreToolUse` hook in `.claude/settings.json` intercepts every call to the `Agent`
and `Skill` tools and appends a timestamped entry to `docs/memory/agent-calls.log`
before the call executes.

No manual action is required — logging is automatic.

---

## Log location and format

**File:** `docs/memory/agent-calls.log`

```
[2026-04-21 14:30:00] AGENT  | type: Explore           | Scan backend for API endpoints
[2026-04-21 14:30:45] SKILL  | superpowers:brainstorming |
[2026-04-21 14:31:02] AGENT  | type: general-purpose   | Research auth patterns for the PRD
[2026-04-21 14:32:10] SKILL  | superpowers:writing-plans | args: implement user auth
```

Each line records:
- Timestamp (local time)
- Tool type: `AGENT` or `SKILL`
- For agents: the `subagent_type` and the `description` field
- For skills: the skill name and any `args` passed

---

## Hook implementation

**Script:** `.claude/hooks/log-agent-skill-call.sh`

The hook reads the full tool call JSON from stdin (provided by Claude Code on every `PreToolUse` event),
extracts the relevant fields with `jq`, and appends the formatted line to the log file.

The `echo "[observability] ..."` line in the script also prints the call to the terminal in real time,
so you can watch agent and skill activity as it happens during a session.

---

## What this enables

- **Audit trail:** see exactly which agents and skills were invoked across all sessions
- **Debugging:** if something went wrong, the log shows the sequence of agent calls that led to it
- **Pattern discovery:** identify which skills are used most often and which are never used
- **Cost awareness:** each `Agent` call spawns a subagent with its own context and token cost

---

## What to do if `jq` is not installed

The hook requires `jq` to parse the JSON tool input. If `jq` is not available:
- macOS: `brew install jq`
- Ubuntu/Debian: `sudo apt-get install jq`
- Windows (Git Bash / WSL): install via package manager or download from https://stedolan.github.io/jq/

Without `jq`, the hook falls back to logging the raw JSON, which is less readable but still captured.

---

## Log maintenance

The log file grows indefinitely. Rotate or truncate it periodically:
```bash
# Keep only the last 500 lines
tail -500 docs/memory/agent-calls.log > /tmp/agent-calls.log.tmp && mv /tmp/agent-calls.log.tmp docs/memory/agent-calls.log
```

Or add log rotation to your CI cleanup step.
