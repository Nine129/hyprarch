#!/usr/bin/env bash
# ── CGGX downloads-sorter — Auto-installer ──────────────────────
# Run me:   bash install.sh
# Or:       chmod +x install.sh && ./install.sh
set -euo pipefail

RED='\033[0;31m'
CYAN='\033[0;36m'
LIME='\033[0;32m'
ORANGE='\033[0;33m'
NC='\033[0m'  # no color

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo -e "${CYAN}━━━ CGGX downloads-sorter installer ━━━${NC}"
echo ""

# ── check deps ──────────────────────────────────────────────────
echo -e "  Checking dependencies..."

if ! command -v python3 &>/dev/null; then
    echo -e "  ${RED}✗ python3 not found — install it first${NC}"
    exit 1
fi

if ! python3 -c "import yaml" &>/dev/null; then
    echo -e "  ${ORANGE}! PyYAML not found — installing...${NC}"
    pip install --user pyyaml 2>/dev/null || pip install pyyaml 2>/dev/null || {
        echo -e "  ${ORANGE}! pip failed — try: pacman -S python-pyyaml${NC}"
    }
fi

if ! command -v notify-send &>/dev/null; then
    echo -e "  ${ORANGE}! notify-send not found (libnotify) — notifications disabled${NC}"
fi

echo -e "  ${LIME}✓ dependencies ok${NC}"
echo ""

# ── install files ───────────────────────────────────────────────
echo -e "  Installing files..."

mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config/download-organizer"
mkdir -p "$HOME/.config/systemd/user"
mkdir -p "$HOME/.cache/download-organizer"

install -m 755 "$SCRIPT_DIR/download-organizer" "$HOME/.local/bin/download-organizer"
install -m 644 "$SCRIPT_DIR/config.yaml"       "$HOME/.config/download-organizer/config.yaml"
install -m 644 "$SCRIPT_DIR/download-organizer.service" "$HOME/.config/systemd/user/download-organizer.service"

echo -e "  ${LIME}✓ files installed${NC}"
echo ""

# ── enable service ──────────────────────────────────────────────
echo -e "  Enabling systemd service..."

systemctl --user daemon-reload
systemctl --user enable --now download-organizer.service

sleep 1
if systemctl --user is-active --quiet download-organizer.service; then
    echo -e "  ${LIME}✓ service running${NC}"
else
    echo -e "  ${RED}✗ service failed to start — check: journalctl --user -u download-organizer${NC}"
fi

echo ""
echo -e "${LIME}━━━ Done. ~/Downloads is now being watched. ━━━${NC}"
echo ""
echo "  Try it:  touch ~/Downloads/test-photo.jpg && sleep 3"
echo "  One-shot:  download-organizer --run"
echo "  Dry-run:   download-organizer --dry-run"
echo "  Undo:      download-organizer --undo 5"
echo ""
