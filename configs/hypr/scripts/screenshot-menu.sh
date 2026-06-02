#!/usr/bin/env bash
# ── CGGX Screenshot Menu ────────────────────────────────────────
# Rofi-based screenshot picker — consolidate all capture
# modes into one menu.
# Bound to: SUPER + D
# Theme matches config.rasi palette exactly
# Requires: grimblast, swappy, wl-clipboard, rofi
# ────────────────────────────────────────────────────────

set -euo pipefail

entries="📷  Full → File\n✂️  Region → File\n🖌️  Region → Swappy\n📋  Region → Clipboard\n📋  Full → Clipboard"

theme=(
  -theme-str 'window {
    background-color: rgba(10,10,12,0.70);
    border:           1px;
    border-color:     #2a2a35;
    border-radius:    0;
    width:            280px;
    font:             "Share Tech Mono 10";
  }'
  -theme-str 'mainbox { spacing: 0; padding: 0; }'
  -theme-str 'listview { spacing: 0; padding: 0; scrollbar: false; }'
  -theme-str 'element {
    padding:       5px 12px;
    border:        0px 0px 0px 3px;
    border-color:  transparent;
  }'
  -theme-str 'element normal.normal { text-color: #e8e8f0; }'
  -theme-str 'element selected.normal {
    background-color: rgba(255,45,85,0.15);
    text-color: #e8e8f0;
    border:        0px 0px 0px 3px;
    border-color:  #ff2d55;
  }'
  -theme-str 'element-text {
    font: "Share Tech Mono 10";
    text-color: #e8e8f0;
    vertical-align: 0.5;
    horizontal-align: 0;
    margin: 0 8px;
  }'
  -theme-str 'inputbar { enabled: false; }'
  -theme-str 'prompt { enabled: false; }'
)

selected=$(echo -e "$entries" | rofi -dmenu -p "" "${theme[@]}" -lines 5 -no-custom -i -me-select-entry "" -me-accept-entry MousePrimary)

case "$selected" in
  *"Full → File")
    grimblast save output
    notify-send "Screenshot" "Full screen saved to ~/Pictures/" -t 2000
    ;;
  *"Region → File")
    grimblast save area
    notify-send "Screenshot" "Region saved to ~/Pictures/" -t 2000
    ;;
  *"Region → Swappy")
    grimblast copy area && wl-paste | swappy -f -
    ;;
  *"Region → Clipboard")
    grimblast copy area
    ;;
  *"Full → Clipboard")
    grimblast copy output
    ;;
esac