#!/usr/bin/env sh
TMP_DIR="/tmp/rmpc"
mkdir -p "$TMP_DIR"

# Atomic lock via mkdir — first to grab it wins, no race
LOCKDIR="$TMP_DIR/notify.lock"
if ! mkdir "$LOCKDIR" 2>/dev/null; then
    exit 0
fi
trap 'rmdir "$LOCKDIR" 2>/dev/null' EXIT

ALBUM_ART_PATH="$TMP_DIR/notification_cover"
DEFAULT_ALBUM_ART_PATH="$HOME/.config/rmpc/default_cover.jpg"

if ! rmpc albumart --output "$ALBUM_ART_PATH"; then
    ALBUM_ART_PATH="$DEFAULT_ALBUM_ART_PATH"
fi

notify-send \
    --icon "$ALBUM_ART_PATH" \
    --app-name "MPD" \
    --urgency low \
    --expire-time 3000 \
    "$TITLE" \
    "$ARTIST"
