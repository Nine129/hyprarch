#!/bin/bash
# ── CGGX Wlogout Toggle ────────────────
# Opens wlogout if not running, closes it if already open.

WLOGOUT_BIN="/home/nine/.local/bin/wlogout"
WLOGOUT_ARGS="-b 5 -c 0 -r 0 -T 500 -B 500 -L 80 -R 80"

if pgrep -x "wlogout" > /dev/null 2>&1; then
  pkill -x "wlogout"
else
  exec "$WLOGOUT_BIN" $WLOGOUT_ARGS
fi
