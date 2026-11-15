#!/usr/bin/env bash
# Install the personal AI assistant layer into your existing PI-Desktop setup.
# Usage: ./install.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
PI_AGENT="${HOME}/.pi/agent"

echo "==> Installing personal AI assistant from ${REPO_DIR}"

# 1. Agent rules
mkdir -p "${PI_AGENT}"
ln -sf "${REPO_DIR}/AGENTS.md" "${PI_AGENT}/AGENTS.md"
echo "    ✓ AGENTS.md linked"

# 2. Skills
mkdir -p "${PI_AGENT}/skills"
for skill_dir in "${REPO_DIR}"/skills/*/; do
  name="$(basename "${skill_dir}")"
  ln -sfn "${skill_dir%/}" "${PI_AGENT}/skills/${name}"
  echo "    ✓ skill: ${name}"
done

# 3. Backup settings.json before touching it
if [ -f "${PI_AGENT}/settings.json" ] && [ ! -f "${PI_AGENT}/settings.json.bak" ]; then
  cp "${PI_AGENT}/settings.json" "${PI_AGENT}/settings.json.bak"
  echo "    ✓ settings.json backed up"
fi

cat <<'EOF'

==> Done. Restart PI-Desktop, then try:

    "morning brief"      → your daily-brief skill
    "remember this: ..." → stores a fact in long-term memory
    "research X"         → web research with cited sources
    "end of day"         → summary + commits + tomorrow's first task

Optional: install the 5 recommended packages (see guides/pi-packages.md).
EOF
