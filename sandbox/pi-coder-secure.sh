#!/usr/bin/env bash
# PI-Coder Secure Mode — pi in default coding mode, inside its own
# NVIDIA OpenShell sandbox (separate from the jarvis sandbox).
set -euo pipefail
SB="${PI_CODER_SANDBOX:-pi-coder}"
IMAGE="${PI_CODER_SANDBOX_IMAGE:-localhost/pi-coder-agent:latest}"

command -v openshell >/dev/null || { echo "openshell CLI not installed — see https://github.com/NVIDIA/OpenShell"; exit 1; }

if ! openshell sandbox list 2>/dev/null | grep -q "$SB"; then
  echo "==> Creating OpenShell sandbox '$SB'..."
  openshell sandbox create --name "$SB" --from "$IMAGE" \
    --provider openrouter-jarvis \
    --env PI_CODING_AGENT_DIR=/sandbox/.pi-coder \
    --detach
else
  STATE="$(openshell sandbox get "$SB" 2>/dev/null | grep -ioE 'ready|stopped|completed|error' | head -1 || true)"
  if [ "$STATE" != "Ready" ]; then openshell sandbox start "$SB" 2>/dev/null || true; fi
fi

if [ $# -gt 0 ]; then
  exec openshell sandbox exec "$SB" -- pi -p "$*"
fi
exec openshell sandbox exec --tty -- pi
