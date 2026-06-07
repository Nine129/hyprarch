#!/usr/bin/env sh
TMP_DIR="/tmp/rmpc"
mkdir -p "$TMP_DIR"
LOCK="$TMP_DIR/notify.lock"

# Kill if already running
[ -f "$LOCK" ] && kill "$(cat $LOCK)" 2>/dev/null
echo $$ > "$LOCK"

# Small delay to let the second fire cancel the first
sleep 0.3

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

rm -f "$LOCK"
