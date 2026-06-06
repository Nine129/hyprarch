#!/bin/bash
# ── CGGX Tray Width Calculator ────────────────────
# Queries DBus StatusNotifierWatcher for registered
# tray icons and outputs the additional width beyond
# the 0-icon baseline (in px).
#
# Waybar tray module CSS: icon-size=14, spacing=10,
# padding=14 each side → baseline (0 icons) = 28px.
# Delta per icon: 14px icon + 10px spacing (except
# no trailing spacing after last icon).
#
# Formula: delta = N*14 + (N-1)*10   (for N>0)
#           delta = 0               (for N=0)
#
# The panels use: right = 84 + delta
# where 84 = 146 - 62 is the 0-icon baseline,
# and 62 = 3*14 + 2*10 is the delta for 3 icons
# (the tray state when 146 was originally calibrated).
# ────────────────────────────────────────────────────

ITEMS=$(dbus-send --session \
  --dest=org.kde.StatusNotifierWatcher \
  --type=method_call \
  --print-reply \
  /StatusNotifierWatcher \
  org.freedesktop.DBus.Properties.Get \
  string:"org.kde.StatusNotifierWatcher" \
  string:"RegisteredStatusNotifierItems" \
  2>/dev/null)

# Count lines containing a registered item string
COUNT=$(echo "$ITEMS" | grep -c '^\s*string')

if [ "$COUNT" -le 0 ]; then
  echo 0
else
  echo $(( COUNT * 14 + (COUNT - 1) * 10 ))
fi
