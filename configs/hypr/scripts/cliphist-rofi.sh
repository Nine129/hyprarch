#!/usr/bin/env bash
# ── CGGX Clipboard Manager ──────────────────────────────
set -euo pipefail

# Toggle
if pgrep -f "rofi.*cliphist-menu" > /dev/null 2>&1; then
  pkill -f "rofi.*cliphist-menu" 2>/dev/null
  exit 0
fi

entries=$(cliphist list)

if [[ -z "$entries" ]]; then
  rofi -e "Clipboard empty" -theme ~/.config/rofi/config.rasi -window-title "cliphist-menu"
  exit 1
fi

# Strip ID prefix for clean display
clean=$(echo "$entries" | sed 's/^[0-9]*\t//')

# Show in rofi, get selected text
selected=$(echo "$clean" | rofi -dmenu \
  -p " Clipboard" \
  -theme ~/.config/rofi/config.rasi \
  -theme-str 'window{width:500px;} element{children: [element-text];} prompt{enabled:true;}' \
  -steal-focus \
  -window-title "cliphist-menu")

if [[ -z "$selected" ]]; then
  exit 0
fi

# Find the matching entry in the full list (by matching the text after the tab)
matched=$(echo "$entries" | grep -F $'\t'"$selected" | head -1)

if [[ -z "$matched" ]]; then
  # Fallback: try matching the whole line
  matched=$(echo "$entries" | grep -F "$selected" | head -1)
fi

if [[ -n "$matched" ]]; then
  echo "$matched" | cliphist decode | wl-copy
else
  # If no match, just copy the selected text
  echo "$selected" | wl-copy
fi

# Auto-paste
sleep 0.03
wtype -M ctrl v -m ctrl                     # GUI (Ctrl+V)
sleep 0.03
wtype -M ctrl -M shift v -m shift -m ctrl   # Terminal (Ctrl+Shift+V)