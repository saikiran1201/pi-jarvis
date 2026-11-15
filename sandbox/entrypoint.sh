#!/bin/sh
# Seed the jarvis brain on first run, then exec the main process.
set -e
CFG="$PI_CODING_AGENT_DIR"
if [ ! -f "$CFG/AGENTS.md" ]; then
  echo "[jarvis-init] seeding agent config..."
  mkdir -p "$CFG/skills"
  cp /opt/jarvis-seed/AGENTS.md "$CFG/AGENTS.md"
  cp -R /opt/jarvis-seed/skills/. "$CFG/skills/"
  chown -R 1000:1000 "$CFG" 2>/dev/null || true
  echo "[jarvis-init] seeded."
fi
exec "$@"
