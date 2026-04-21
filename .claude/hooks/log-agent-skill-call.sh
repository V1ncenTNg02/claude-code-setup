#!/usr/bin/env bash
# PreToolUse hook: logs every Agent and Skill invocation for observability.
# Triggered by: settings.json hooks.PreToolUse matcher "Agent|Skill"
#
# Claude Code passes the full tool call as JSON on stdin:
#   { "tool_name": "Agent", "tool_input": { "description": "...", ... } }
#
# Output goes to: docs/memory/agent-calls.log

set -uo pipefail

LOG_FILE="docs/memory/agent-calls.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

mkdir -p "$(dirname "$LOG_FILE")"

# Read the full tool call JSON from stdin
INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null || echo "unknown")

case "$TOOL_NAME" in
  Agent)
    DESCRIPTION=$(echo "$INPUT" | jq -r '.tool_input.description // "no description"' 2>/dev/null || echo "no description")
    SUBAGENT_TYPE=$(echo "$INPUT" | jq -r '.tool_input.subagent_type // "general-purpose"' 2>/dev/null || echo "general-purpose")
    echo "[$TIMESTAMP] AGENT  | type: $SUBAGENT_TYPE | $DESCRIPTION" >> "$LOG_FILE"
    echo "[observability] Agent → $SUBAGENT_TYPE: $DESCRIPTION"
    ;;
  Skill)
    SKILL=$(echo "$INPUT" | jq -r '.tool_input.skill // "unknown"' 2>/dev/null || echo "unknown")
    ARGS=$(echo "$INPUT" | jq -r '.tool_input.args // ""' 2>/dev/null || echo "")
    if [ -n "$ARGS" ]; then
      echo "[$TIMESTAMP] SKILL  | $SKILL | args: $ARGS" >> "$LOG_FILE"
      echo "[observability] Skill → $SKILL (args: $ARGS)"
    else
      echo "[$TIMESTAMP] SKILL  | $SKILL" >> "$LOG_FILE"
      echo "[observability] Skill → $SKILL"
    fi
    ;;
  *)
    # Fallback: log whatever tool was matched but not recognised
    echo "[$TIMESTAMP] TOOL   | $TOOL_NAME | raw: $(echo "$INPUT" | jq -c '.tool_input' 2>/dev/null || echo "$INPUT")" >> "$LOG_FILE"
    ;;
esac
