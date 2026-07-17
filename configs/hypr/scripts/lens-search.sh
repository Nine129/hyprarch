#!/usr/bin/env bash
# ── CGGX Lens Search ──────────────────────────
# Captures a region, uploads to catbox.moe, opens Google Lens results.
# Bound to SUPER+ALT+Print in binds.lua
set -euo pipefail

FILE="/tmp/lens-$(date +%s).png"

# Capture region — bail if cancelled (Escape)
grimblast save area "$FILE" || exit 1

notify-send "🔍 Lens" "Uploading…"

# Upload to catbox.moe (no API key, returns raw URL on stdout)
REMOTE_URL=$(curl -sf -F "reqtype=fileupload" -F "fileToUpload=@$FILE" "https://catbox.moe/user/api.php") || {
    notify-send -u critical "🔍 Lens" "Upload to catbox.moe failed"
    exit 2
}

# URL-encode for query parameter
ENCODED=$(python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read().strip()))" <<< "$REMOTE_URL")

xdg-open "https://lens.google.com/uploadbyurl?url=$ENCODED"
