#!/usr/bin/env bash
# ── CGGX Rofi Launcher — toggle on/off ──
# If rofi is already running, kill it (close).
# Otherwise, launch it.

if pgrep -x rofi > /dev/null 2>&1; then
  pkill -x rofi
else
  LC_ALL=C.UTF-8 rofi -show drun
fi
