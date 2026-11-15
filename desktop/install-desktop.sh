#!/usr/bin/env bash
# Install Pi Jarvis as a podman-powered desktop app on Linux.
# Usage: ./install-desktop.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"   # repo root (one level up from desktop/)
IMAGE="localhost/pi-jarvis"
BIN="$HOME/.local/bin/pi-jarvis-desktop"
CFG="$HOME/.pi-jarvis-desktop"                 # persistent config on the host

echo "==> Building the pi-jarvis container image (first run takes a few minutes)..."
podman build -t "$IMAGE" -f "$REPO_DIR/desktop/Containerfile" "$REPO_DIR"

echo "==> Creating launcher..."
mkdir -p "$HOME/.local/bin"
cat > "$BIN" <<LAUNCHER
#!/usr/bin/env bash
# Pi Jarvis desktop launcher — terminal chat in an isolated container.
# Config/memory persists on the host in $CFG.
CFG="\$HOME/.pi-jarvis-desktop"
mkdir -p "\$CFG"
exec podman run --rm -it \\
  -v "\$CFG:/home/jarvis/.pi-jarvis" \\
  -e OPENROUTER_API_KEY="\${OPENROUTER_API_KEY:-}" \\
  -e ANTHROPIC_API_KEY="\${ANTHROPIC_API_KEY:-}" \\
  -e GOOGLE_GENERATIVE_AI_API_KEY="\${GOOGLE_GENERATIVE_AI_API_KEY:-}" \\
  $IMAGE "\$@"
LAUNCHER
chmod +x "$BIN"

echo "==> Creating app-menu entry..."
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/pi-jarvis.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Pi Jarvis
Comment=Your personal AI assistant (podman-isolated)
Exec=$BIN
Terminal=true
Categories=Utility;Office;
Keywords=jarvis;assistant;ai;
EOF

cat <<'EOF'

==> Done. Launch "Pi Jarvis" from your app menu, or run:
    pi-jarvis-desktop

    First launch seeds the config and installs packages automatically.
    Provide your model API key on first run, e.g.:
    OPENROUTER_API_KEY=sk-or-... pi-jarvis-desktop
EOF
