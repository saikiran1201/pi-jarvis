#!/usr/bin/env bash
# Install PI-Jarvis as a desktop app on Linux — the PI-Desktop UI running the
# Jarvis personal-assistant brain, fully isolated from your coding setup.
#
# Creates one app-menu entry ("PI-Jarvis") + a desktop shortcut.
# Requirements: PI-Desktop installed (https://pi.dev), python3-PIL for the icon.
# Usage: ./install-desktop.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DATA_DIR="$HOME/.pi-jarvis-desktop"            # agent brain: config, skills, memory
APP_DATA="$HOME/.pi-jarvis-desktop-app"        # desktop-app state (projects, UI)
WORKSPACE="$HOME/Jarvis-Workspace"             # folder the app opens on
KEYFILE="$HOME/.pi-jarvis-desktop.env"         # API keys (never commit)

echo "==> Locating PI-Desktop..."
DESKTOP_BIN="$(command -v pi-desktop || true)"
[ -x "$DESKTOP_BIN" ] || [ -x /opt/PI-Desktop/pi-desktop ] || { echo "PI-Desktop is not installed — get it from https://pi.dev"; exit 1; }
[ -x "$DESKTOP_BIN" ] || DESKTOP_BIN=/opt/PI-Desktop/pi-desktop
# prefer a PI-Jarvis-branded copy if one exists (see guides/native-branding.md)
PATCHED="$HOME/.local/opt/pi-jarvis-desktop/pi-desktop"
if [ -x "$PATCHED" ]; then
  DESKTOP_BIN="$PATCHED"
  # a user-copied chrome-sandbox can't keep root ownership -> Electron aborts.
  # Hiding it makes Electron use the kernel user-namespace sandbox instead.
  # A user-copied chrome-sandbox can't keep root ownership. On Ubuntu 23.10+
  # AppArmor also blocks the userns fallback, so the ONLY working config is a
  # root-owned SUID helper. Try to fix it with sudo (may prompt once):
  SB="$(dirname "$PATCHED")/chrome-sandbox"
  if [ -f "$SB" ] && [ "$(stat -c %U "$SB")" != "root" ]; then
    echo "    Fixing chrome-sandbox ownership (sudo, one-time)..."
    sudo chown root:root "$SB" 2>/dev/null && sudo chmod 4755 "$SB" 2>/dev/null \
      || { mv "$SB" "$SB.bak"; echo "    ! Could not run sudo. Enable the sandbox later with:"; echo "      sudo chown root:root $SB.bak && sudo chmod 4755 $SB.bak && sudo mv $SB.bak $SB"; echo "    ! Until then, GUI launches may fail on Ubuntu 23.10+ (AppArmor userns restriction)."; }
  fi
fi

echo "==> Seeding the Jarvis brain (first install only)..."
if [ ! -f "$DATA_DIR/AGENTS.md" ]; then
  mkdir -p "$DATA_DIR/skills"
  cp "$REPO_DIR/AGENTS.md" "$DATA_DIR/AGENTS.md"
  cp -R "$REPO_DIR/skills/." "$DATA_DIR/skills/"
  echo "    AGENTS.md + skills copied into $DATA_DIR"
fi
mkdir -p "$APP_DATA" "$WORKSPACE"

echo "==> Installing packages into the Jarvis brain..."
if command -v pi >/dev/null; then
  ( export PI_CODING_AGENT_DIR="$DATA_DIR"
    for p in pi-hermes-memory pi-observational-memory @netandreus/pi-auto pi-web-access tau-all-agent; do
      pi install "npm:$p" 2>/dev/null | tail -1 || true
    done )
else
  echo "    ! 'pi' CLI not found — install packages later from inside the app"
fi

echo "==> Creating launcher..."
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
cat > "$BIN_DIR/pi-jarvis-native" <<LAUNCHER
#!/usr/bin/env bash
# Launch PI-Jarvis: PI-Desktop UI + isolated Jarvis brain + own workspace.
mkdir -p "$WORKSPACE"
cd "$WORKSPACE"
exec env \\
  PI_CODING_AGENT_DIR="$DATA_DIR" \\
  PI_DESKTOP_DATA_DIR="$APP_DATA" \\
  "$DESKTOP_BIN" --user-data-dir="$HOME/.pi-desktop-jarvis" "\$@"
LAUNCHER
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
PYICON
gtk-update-icon-cache -f ~/.local/share/icons/hicolor 2>/dev/null || true

echo "==> Creating app-menu entry + desktop shortcut..."
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/pi-jarvis-native.desktop" <<DESKTOPEOF
[Desktop Entry]
Type=Application
Name=PI-Jarvis
Comment=Your personal AI assistant — full desktop UI, isolated brain
Exec=$BIN_DIR/pi-jarvis-native
Terminal=true
Icon=pi-jarvis
Categories=Utility;
Keywords=jarvis;assistant;ai;
DESKTOPEOF
if [ -d "$HOME/Desktop" ]; then
  sed 's/^Name=PI-Jarvis$/Name=PI-Jarvis/' "$HOME/.local/share/applications/pi-jarvis-native.desktop" > "$HOME/Desktop/pi-jarvis.desktop"
  chmod +x "$HOME/Desktop/pi-jarvis.desktop"
fi
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

cat <<'EOF'

==> Done. Launch "PI-Jarvis" from your app menu (or double-click the desktop
    shortcut), or run: pi-jarvis-native

    API keys: echo "OPENROUTER_API_KEY=sk-or-..." > ~/.pi-jarvis-desktop.env
    The app opens on ~/Jarvis-Workspace with its own memory and sessions.
EOF
