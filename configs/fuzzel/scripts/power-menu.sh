#!/usr/bin/env bash

choice=$(
  printf "  Lock\n󰤄  Sleep\n󰍃  Logout\n󰜉  Reboot\n  Shutdown" \
  | fuzzel --dmenu \
    --lines 5 \
    --width 16 \
    --hide-prompt \
)

case "$choice" in
  *"Lock")     hyprlock ;;
  *"Sleep")    systemctl suspend ;;
  *"Logout")   hyprctl dispatch exit 0 ;;
  *"Reboot")   systemctl reboot ;;
  *"Shutdown") systemctl poweroff ;;
esac
