#!/usr/bin/env bash
# ── CGGX Power Menu ───────────────────────────────────────────
# Rofi-based power menu: shutdown, reboot, lock, logout, suspend
# Bound to: SUPER + SHIFT + Q
# Theme matches config.rasi palette exactly
# Requires: systemctl, hyprlock, rofi
# ─────────────────────────────────────────────────────────

set -euo pipefail

entries="⏻  Shutdown\n  Reboot\n  Lock\n󰗽  Log Out\n󰤄  Suspend"

theme=(
  -theme-str 'window {
    background-color: rgba(10,10,12,0.70);
    border: 1px solid #2a2a35;
    border-radius: 0;
    width: 240px;
    font: "Share Tech Mono 10";
  }'
  -theme-str 'mainbox { spacing: 0; padding: 0; }'
  -theme-str 'listview { spacing: 0; padding: 0; scrollbar: false; }'
  -theme-str 'element {
    padding: 5px 12px;
    border-left: 3px solid transparent;
  }'
  -theme-str 'element normal.normal { text-color: #e8e8f0; }'
  -theme-str 'element selected.normal {
    background-color: rgba(255,45,85,0.15);
    text-color: #e8e8f0;
    border-left: 3px solid #ff2d55;
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

selected=$(echo -e "$entries" | rofi -dmenu -p "" "${theme[@]}" -lines 5 -no-custom -i)

case "$selected" in
  *Shutdown) systemctl poweroff ;;
  *Reboot)   systemctl reboot ;;
  *Lock)     hyprlock ;;
  *"Log Out") hyprctl dispatch exit ;;
  *Suspend)  systemctl suspend ;;
esac