#!/usr/bin/env bash
# Runs after every Claude response.
# Replace the commands below with the actual test commands for this project.
# See docs/testing/testing-strategy.md — "Test commands summary" table for the values to use.

set -euo pipefail

STRATEGY="docs/testing/testing-strategy.md"

if [ ! -f "$STRATEGY" ]; then
  echo "[memory] docs/testing/testing-strategy.md not found — skipping test run."
  echo "[memory] Create it from docs/testing/testing-strategy-template.md to enable automatic test runs."
  exit 0
fi

# ─── Configure your test commands below ───────────────────────────────────────
# Uncomment and replace with the commands from your testing-strategy.md.
# Run ALL relevant tests (unit + integration for backend; unit + component for frontend).

# echo "[tests] Running full test suite..."

# --- Backend ---
# cd backend && npm test
# pytest
# go test ./...
# make test

# --- Frontend ---
# cd frontend && npm test -- --watchAll=false
# vitest run
# cd frontend && npm run test:unit

# --- Both (monorepo) ---
# npm run test:all
# make test-all

echo "[tests] ⚠ No test command configured."
echo "[tests] Edit .claude/hooks/stop-run-tests.sh and uncomment the command for this project."
echo "[tests] Reference: docs/testing/testing-strategy.md"
