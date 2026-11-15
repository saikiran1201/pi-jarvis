#!/bin/sh
# Container entrypoint: seed config on first launch, then start pi or the web UI.
set -e
CFG="$PI_CODING_AGENT_DIR"

if [ ! -f "$CFG/AGENTS.md" ]; then
  echo "==> First launch: seeding pi-jarvis config..."
  mkdir -p "$CFG/skills"
  cp /opt/jarvis-seed/AGENTS.md "$CFG/AGENTS.md"
  cp -R /opt/jarvis-seed/skills/. "$CFG/skills/"
  echo "==> Installing assistant packages..."
  pi install npm:pi-hermes-memory || true
  pi install npm:pi-observational-memory || true
  pi install npm:@netandreus/pi-auto || true
  pi install npm:pi-web-access || true
  echo "==> Seeded."
fi

if [ "$JARVIS_MODE" = "webui" ]; then
  exec node /opt/jarvis-webui/server.js
fi

exec pi "$@"
