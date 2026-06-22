#!/usr/bin/env bash
# sync-skills.sh — keeps .agents/skills/ in sync with skills/
# Run after adding or editing any skill: bash scripts/sync-skills.sh
# Also wired as a pre-commit hook (see scripts/install-hooks.sh).

set -euo pipefail

SRC="skills"
DST=".agents/skills"

if [ ! -d "$SRC" ]; then
  echo "[sync-skills] ERROR: $SRC not found. Run from repo root." >&2
  exit 1
fi

echo "[sync-skills] Syncing $SRC → $DST ..."
rm -rf "$DST"
mkdir -p "$(dirname "$DST")"
cp -r "$SRC" "$DST"

COUNT=$(find "$DST" -name SKILL.md | wc -l | tr -d ' ')
echo "[sync-skills] Done — $COUNT skills in $DST"
