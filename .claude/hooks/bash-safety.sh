#!/usr/bin/env bash
# PreToolUse hook: safety net for dangerous Bash commands.
# Triggered by: settings.json hooks.PreToolUse matcher "Bash"
#
# Exit 0  → command is allowed to proceed
# Exit 2  → command is BLOCKED (Claude Code treats this as a hard block)
#
# Claude Code passes the full tool call as JSON on stdin.

set -uo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")

if [ -z "$COMMAND" ]; then
  exit 0
fi

BLOCKED=0
REASON=""

# ── Hard blocks — these must never run unattended ─────────────────────────────

# Recursive force-delete of root, home, or repo root
if echo "$COMMAND" | grep -qE 'rm\s+-[a-z]*r[a-z]*f[a-z]*\s+/[^a-z]|rm\s+-[a-z]*f[a-z]*r[a-z]*\s+/[^a-z]'; then
  BLOCKED=1; REASON="rm -rf targeting root-level path"
fi

# git push --force to main/master (protect shared history)
if echo "$COMMAND" | grep -qE 'git\s+push\s+.*(-f|--force)\s+.*(main|master)'; then
  BLOCKED=1; REASON="force push to main/master is prohibited"
fi

# Pipe arbitrary internet script into shell (supply chain attack vector)
if echo "$COMMAND" | grep -qE '(curl|wget)\s+.*\|\s*(ba)?sh'; then
  BLOCKED=1; REASON="curl/wget piped to shell — review the script before running manually"
fi

# DROP DATABASE or DROP TABLE without a WHERE clause (data loss)
if echo "$COMMAND" | grep -qiE '(DROP\s+DATABASE|DROP\s+TABLE)\s+\S+'; then
  BLOCKED=1; REASON="DROP DATABASE/TABLE detected — run manually after confirming it is intentional"
fi

# git clean -f or -df on . or / (destroys untracked files)
if echo "$COMMAND" | grep -qE 'git\s+clean\s+-[a-z]*f'; then
  BLOCKED=1; REASON="git clean -f destroys untracked files — run manually if intentional"
fi

# ── Warnings — log and allow, but make the risk visible ──────────────────────

WARN=""

# git reset --hard
if echo "$COMMAND" | grep -qE 'git\s+reset\s+--hard'; then
  WARN="⚠  git reset --hard discards uncommitted changes permanently"
fi

# chmod 777
if echo "$COMMAND" | grep -qE 'chmod\s+777'; then
  WARN="⚠  chmod 777 grants world-write permission — consider a narrower mode"
fi

# git push --force (not to main/master — allowed but warned)
if echo "$COMMAND" | grep -qE 'git\s+push\s+.*(-f|--force)' && [ -z "$REASON" ]; then
  WARN="⚠  force push will rewrite remote history for other collaborators"
fi

# ── Output ────────────────────────────────────────────────────────────────────

if [ "$BLOCKED" -eq 1 ]; then
  echo "[bash-safety] BLOCKED: $REASON" >&2
  echo "[bash-safety] Command was: $COMMAND" >&2
  echo "[bash-safety] Run this command manually in your terminal if you are certain it is safe." >&2
  exit 2
fi

if [ -n "$WARN" ]; then
  echo "[bash-safety] $WARN"
  echo "[bash-safety] Proceeding — run manually if you want to cancel."
fi

exit 0
