#!/usr/bin/env bash
# One-time setup for PI-Jarvis Secure Mode (NVIDIA OpenShell).
# Requires: podman, openshell CLI 0.1.8+, and OPENROUTER_API_KEY.
set -euo pipefail
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Checking prerequisites..."
command -v podman >/dev/null || { echo "podman required (sudo apt install podman)"; exit 1; }
command -v openshell >/dev/null || { echo "openshell CLI required — install from https://github.com/NVIDIA/OpenShell"; exit 1; }

echo "==> Ensuring the local gateway is running..."
systemctl --user enable --now openshell-gateway.service 2>/dev/null || true
sleep 2
if ! openshell status 2>&1 | grep -q "Connected"; then
  openshell gateway remove local >/dev/null 2>&1 || true
  openshell gateway add https://127.0.0.1:17670 --local --name local --gateway-insecure
  openshell status | grep -q "Connected" || { echo "gateway not reachable — check: systemctl --user status openshell-gateway"; exit 1; }
fi
echo "    gateway connected"

echo "==> Importing the OpenRouter provider profile..."
curl -sL "https://raw.githubusercontent.com/NVIDIA/OpenShell/main/providers/openrouter.yaml" \
  | sed 's|binaries: \[/usr/local/bin/opencode\]|binaries: [/usr/local/bin/node, /usr/local/bin/pi, /usr/bin/curl]|' \
  > /tmp/openrouter-jarvis.yaml
openshell profile lint --file /tmp/openrouter-jarvis.yaml
openshell profile import --file /tmp/openrouter-jarvis.yaml 2>/dev/null || echo "    (already imported)"

echo "==> Creating the provider from your OPENROUTER_API_KEY..."
if ! openshell provider list 2>/dev/null | grep -q openrouter-jarvis; then
  : "${OPENROUTER_API_KEY:?export OPENROUTER_API_KEY=sk-or-... first}"
  openshell provider create --name openrouter-jarvis --type openrouter --credential OPENROUTER_API_KEY
else
  echo "    (already exists)"
fi

echo "==> Building the jarvis agent image (podman)..."
podman build -q -t localhost/pi-jarvis-agent:latest -f "$REPO_DIR/sandbox/Containerfile" "$REPO_DIR"

echo "==> Creating the pi-jarvis sandbox..."
if ! openshell sandbox list 2>/dev/null | grep -q "pi-jarvis"; then
  openshell sandbox create --name pi-jarvis \
    --from localhost/pi-jarvis-agent:latest \
    --provider openrouter-jarvis \
    --env PI_CODING_AGENT_DIR=/sandbox/.pi-jarvis \
    --detach
  sleep 5
  echo "==> Seeding the jarvis brain (AGENTS.md + skills)..."
  openshell sandbox upload pi-jarvis "$REPO_DIR/AGENTS.md" :/sandbox/.pi-jarvis/AGENTS.md
  openshell sandbox upload pi-jarvis "$REPO_DIR/skills"
fi

echo "==> Building the coder agent image (podman)..."
podman build -q -t localhost/pi-coder-agent:latest -f "$REPO_DIR/sandbox/coder/Containerfile" "$REPO_DIR"

echo "==> Creating the pi-coder sandbox (coding mode, separate sandbox)..."
if ! openshell sandbox list 2>/dev/null | grep -q "pi-coder"; then
  openshell sandbox create --name pi-coder \
    --from localhost/pi-coder-agent:latest \
    --provider openrouter-jarvis \
    --env PI_CODING_AGENT_DIR=/sandbox/.pi-coder \
    --detach
fi

echo "==> Installing the launchers..."
cp "$REPO_DIR/sandbox/pi-jarvis-secure.sh" "$HOME/.local/bin/pi-jarvis-secure"
cp "$REPO_DIR/sandbox/pi-coder-secure.sh" "$HOME/.local/bin/pi-coder-secure"
chmod +x "$HOME/.local/bin/pi-jarvis-secure" "$HOME/.local/bin/pi-coder-secure"

echo
echo "==> Done. Try:"
echo "    pi-jarvis-secure \"morning brief\"   # personal assistant sandbox"
echo "    pi-coder-secure                    # coding sandbox (default pi)"
