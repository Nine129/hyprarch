#!/usr/bin/env bash
# ── CGGX Clipboard Manager ──────────────────────────────
# Rofi wrapper around cliphist for clipboard history
# Bound to SUPER + C
# Requirements: cliphist, rofi, wl-clipboard

set -euo pipefail

entries=$(cliphist list)

if [[ -z "$entries" ]]; then
  rofi -e "Clipboard empty" -theme ~/.config/rofi/config.rasi
  exit 1
fi

selected=$(echo "$entries" | rofi -dmenu \
  -p " Clipboard" \
  -display-columns 2 \
  -theme ~/.config/rofi/config.rasi)

if [[ -z "$selected" ]]; then
  exit 0
fi

echo "$selected" | cliphist decode | wl-copy