#!/usr/bin/env bash
# PI-Jarvis Secure Mode — chat with your assistant inside the NVIDIA OpenShell
# sandbox (kernel-enforced filesystem/network policy, credentials never exposed).
set -euo pipefail
SB="${PI_JARVIS_SANDBOX:-pi-jarvis}"
IMAGE="${PI_JARVIS_SANDBOX_IMAGE:-localhost/pi-jarvis-agent:latest}"

command -v openshell >/dev/null || { echo "openshell CLI not installed — see https://github.com/NVIDIA/OpenShell"; exit 1; }

# ensure the sandbox exists and is ready
if ! openshell sandbox list 2>/dev/null | awk '{print $1}' | grep -qx "$SB"; then
  echo "==> Creating OpenShell sandbox '$SB'..."
  openshell sandbox create --name "$SB" --from "$IMAGE" \
    --provider openrouter-jarvis \
    --env PI_CODING_AGENT_DIR=/sandbox/.pi-jarvis \
    --detach
else
  STATE="$(openshell sandbox get "$SB" 2>/dev/null | grep -ioE 'ready|stopped|completed|error' | head -1 || true)"
  if [ "$STATE" != "Ready" ]; then openshell sandbox start "$SB" 2>/dev/null || true; fi
fi

# one-shot mode
if [ $# -gt 0 ]; then
  exec openshell sandbox exec "$SB" -- pi -p "$*"
fi

# interactive chat
exec openshell sandbox exec --tty -- pi
