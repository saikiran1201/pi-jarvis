#!/usr/bin/env bash
# Install Pi Jarvis as a podman-powered desktop app on Linux.
# Creates two app-menu entries: "Pi Jarvis" (chat window) and "Pi Jarvis (Terminal)".
# Usage: ./install-desktop.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"   # repo root (one level up from desktop/)
IMAGE="localhost/pi-jarvis"
BIN_DIR="$HOME/.local/bin"
CFG="$HOME/.pi-jarvis-desktop"                 # persistent config on the host

echo "==> Building the pi-jarvis container image (first run takes a few minutes)..."
podman build -t "$IMAGE" -f "$REPO_DIR/desktop/Containerfile" "$REPO_DIR"

echo "==> Creating launchers..."
mkdir -p "$BIN_DIR"

# GUI launcher: start (or reuse) the web server container, open the chat window
cat > "$BIN_DIR/pi-jarvis-gui" <<LAUNCHER
#!/usr/bin/env bash
CFG="\$HOME/.pi-jarvis-desktop"
mkdir -p "\$CFG"
[ -f "\$HOME/.pi-jarvis-desktop.env" ] && . "\$HOME/.pi-jarvis-desktop.env"
if ! podman ps --format '{{.Names}}' | grep -q '^pi-jarvis-ui\$'; then
  podman rm -f pi-jarvis-ui >/dev/null 2>&1 || true
  podman run -d --name pi-jarvis-ui \\
    -v "\$CFG:/home/jarvis/.pi-jarvis" \\
    -e JARVIS_MODE=webui \\
    -e OPENROUTER_API_KEY="\${OPENROUTER_API_KEY:-}" \\
    -e ANTHROPIC_API_KEY="\${ANTHROPIC_API_KEY:-}" \\
    -e GOOGLE_GENERATIVE_AI_API_KEY="\${GOOGLE_GENERATIVE_AI_API_KEY:-}" \\
    -p 127.0.0.1:8799:8799 \\
    $IMAGE >/dev/null
  sleep 2
fi
xdg-open http://localhost:8799 >/dev/null 2>&1 || echo "Open http://localhost:8799 in your browser"
LAUNCHER
chmod +x "$BIN_DIR/pi-jarvis-gui"

# Terminal launcher (chat in a console window)
cat > "$BIN_DIR/pi-jarvis-desktop" <<LAUNCHER
#!/usr/bin/env bash
CFG="\$HOME/.pi-jarvis-desktop"
mkdir -p "\$CFG"
[ -f "\$HOME/.pi-jarvis-desktop.env" ] && . "\$HOME/.pi-jarvis-desktop.env"
exec podman run --rm -it \\
  -v "\$CFG:/home/jarvis/.pi-jarvis" \\
  -e OPENROUTER_API_KEY="\${OPENROUTER_API_KEY:-}" \\
  -e ANTHROPIC_API_KEY="\${ANTHROPIC_API_KEY:-}" \\
  -e GOOGLE_GENERATIVE_AI_API_KEY="\${GOOGLE_GENERATIVE_AI_API_KEY:-}" \\
  $IMAGE "\$@"
LAUNCHER
chmod +x "$BIN_DIR/pi-jarvis-desktop"


# Native-UI launcher: runs PI-Desktop itself with the jarvis config (needs PI-Desktop installed)
cat > "$BIN_DIR/pi-jarvis-native" <<'NATIVELAUNCH'
#!/usr/bin/env bash
# Launch PI-Desktop (the exact desktop UI) with the Pi Jarvis isolated config.
# prefer the patched PI-Jarvis-branded copy, fall back to stock PI-Desktop
PATCHED_BIN="$HOME/.local/opt/pi-jarvis-desktop/pi-desktop"
if [ -x "$PATCHED_BIN" ]; then DESKTOP_BIN="$PATCHED_BIN";
elif command -v pi-desktop >/dev/null; then DESKTOP_BIN="$(command -v pi-desktop)";
elif [ -x /opt/PI-Desktop/pi-desktop ]; then DESKTOP_BIN=/opt/PI-Desktop/pi-desktop;
else echo "PI-Desktop is not installed — get it from https://pi.dev"; exit 1; fi
# dedicated workspace + fully separate app data (projects/sessions/settings)
# PI_DESKTOP_DATA_DIR is PI-Desktop's own supported override for its data dir
mkdir -p "$HOME/Jarvis-Workspace"
cd "$HOME/Jarvis-Workspace"
exec env \
  PI_CODING_AGENT_DIR="$HOME/.pi-jarvis-desktop" \
  PI_DESKTOP_DATA_DIR="$HOME/.pi-jarvis-desktop-app" \
  "$DESKTOP_BIN" --user-data-dir="$HOME/.pi-desktop-jarvis" "$@"
NATIVELAUNCH
chmod +x "$BIN_DIR/pi-jarvis-native"

echo "==> Installing app icon..."
mkdir -p "$HOME/.local/share/icons/hicolor/256x256/apps"
python3 - <<'PYICON' 2>/dev/null || true
from PIL import Image, ImageDraw, ImageFont
img = Image.new("RGBA",(256,256),(0,0,0,0))
d = ImageDraw.Draw(img)
d.rounded_rectangle([8,8,248,248],radius=48,fill=(13,17,23,255),outline=(88,166,255,255),width=8)
try: f = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",120)
except Exception: f = ImageFont.load_default()
d.text((128,128),"J",font=f,fill=(88,166,255,255),anchor="mm")
img.save("$HOME/.local/share/icons/hicolor/256x256/apps/pi-jarvis.png")
img2 = Image.new("RGBA",(256,256),(0,0,0,0))
d2 = ImageDraw.Draw(img2)
d2.rounded_rectangle([8,8,248,208],radius=56,fill=(13,17,23,255),outline=(63,185,80,255),width=8)
d2.polygon([(70,208),(70,246),(112,208)],fill=(13,17,23,255))
d2.text((128,106),"J",font=f,fill=(63,185,80,255),anchor="mm")
img2.save("$HOME/.local/share/icons/hicolor/256x256/apps/pi-jarvis-chat.png")
PYICON
gtk-update-icon-cache -f ~/.local/share/icons/hicolor 2>/dev/null || true

echo "==> Creating app-menu entries..."
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/pi-jarvis.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Pi Jarvis
Comment=Your personal AI assistant — chat window (podman-isolated)
Exec=$BIN_DIR/pi-jarvis-gui
Terminal=false
Categories=Utility;
Icon=pi-jarvis
Keywords=jarvis;assistant;ai;
EOF
cat > "$HOME/.local/share/applications/pi-jarvis-terminal.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Pi Jarvis (Terminal)
Comment=Your personal AI assistant — terminal chat (podman-isolated)
Exec=$BIN_DIR/pi-jarvis-desktop
Terminal=true
Categories=Utility;
Icon=pi-jarvis
Keywords=jarvis;assistant;ai;terminal;
EOF

cat > "$HOME/.local/share/applications/pi-jarvis-native.desktop" <<DESKTOPEOF
[Desktop Entry]
Type=Application
Name=Pi Jarvis (Native UI)
Comment=Your personal AI assistant — full desktop UI via PI-Desktop
Exec=$BIN_DIR/pi-jarvis-native
Terminal=false
Categories=Utility;
Icon=pi-jarvis
Keywords=jarvis;assistant;ai;native;
DESKTOPEOF

cat > "$HOME/.local/share/applications/pi-jarvis-chat.desktop" <<DESKTOPEOF
[Desktop Entry]
Type=Application
Name=PI-Jarvis Chat
Comment=Your personal AI assistant — browser chat window
Exec=$BIN_DIR/pi-jarvis-gui
Terminal=false
Icon=pi-jarvis-chat
Categories=Utility;
Keywords=jarvis;assistant;ai;chat;
DESKTOPEOF

cat <<'EOF'

==> Done. Two entries are in your app menu:
    "Pi Jarvis"             → chat window in your browser (recommended)
    "Pi Jarvis (Native UI)" → full PI-Desktop UI pointed at jarvis (needs PI-Desktop installed)
    "Pi Jarvis (Terminal)"  → terminal chat

    Or from the command line:
    pi-jarvis-gui           chat window
    pi-jarvis-desktop       terminal chat

    API keys live in ~/.pi-jarvis-desktop.env (never in this repo):
    echo "OPENROUTER_API_KEY=sk-or-..." > ~/.pi-jarvis-desktop.env
EOF
