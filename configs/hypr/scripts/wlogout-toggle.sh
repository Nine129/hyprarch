#!/bin/bash
# ── CGGX Wlogout Toggle ────────────────
# Opens wlogout if not running, closes it if already open.

WLOGOUT_BIN="/home/nine/.local/bin/wlogout"
WLOGOUT_ARGS="-b 5 -c 10 -r 0 -T 400 -B 400 -L 70 -R 70"

if pgrep -x "wlogout" > /dev/null 2>&1; then
  pkill -x "wlogout"
else
  exec "$WLOGOUT_BIN" $WLOGOUT_ARGS
fi
