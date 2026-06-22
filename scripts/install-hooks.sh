#!/usr/bin/env bash
# install-hooks.sh — installs a pre-commit hook that syncs .agents/skills/ before every commit.
# Run once after cloning: bash scripts/install-hooks.sh

set -euo pipefail

HOOK=".git/hooks/pre-commit"

cat > "$HOOK" <<'EOF'
#!/usr/bin/env bash
# Auto-syncs .agents/skills/ from skills/ before every commit.
if [ -f scripts/sync-skills.sh ]; then
  bash scripts/sync-skills.sh
  git add .agents/skills/
fi
EOF

chmod +x "$HOOK"
echo "[install-hooks] pre-commit hook installed at $HOOK"
