#!/usr/bin/env bash
# Runs after every file edit (Edit or Write tool call).
# Use ONLY fast tests here — unit tests that complete in under 10 seconds.
# Do NOT run E2E or integration tests here; those belong in stop-run-tests.sh.
# See docs/testing/testing-strategy.md — "Test commands summary" for the fast-test command.

set -euo pipefail

EDITED_FILE="${CLAUDE_TOOL_INPUT_FILE_PATH:-}"

# Skip non-source files — no need to test after editing docs or config
case "$EDITED_FILE" in
  *.md|*.json|*.yaml|*.yml|*.env*|*.gitignore)
    exit 0
    ;;
esac

STRATEGY="docs/testing/testing-strategy.md"

if [ ! -f "$STRATEGY" ]; then
  exit 0
fi

# ─── Configure your fast unit-test command below ───────────────────────────────
# Uncomment and replace with the fast test command from your testing-strategy.md.
# This MUST complete in under 10 seconds. Only unit tests — no DB, no network.

# echo "[tests] Running fast unit tests..."

# --- Backend unit tests only ---
# cd backend && npm run test:unit
# pytest -m unit
# go test ./... -short
# make test-unit

# --- Frontend unit tests only ---
# cd frontend && vitest run --reporter=dot
# cd frontend && jest --passWithNoTests --testPathPattern=unit

# --- Related test file only (fastest possible) ---
# If your framework supports running the test file matching the edited source file:
# vitest related "$EDITED_FILE"
# jest --findRelatedTests "$EDITED_FILE"

: # no-op: remove this line once you uncomment a command above
