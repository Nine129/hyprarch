#!/bin/bash
# ── CGGX Screenshot → Swappy ──────────────────────────
# Region screenshot → swappy editor → save to ~/Pictures/Screenshots
# Bound to SUPER + Print in hyprland binds.lua

notify-send "Screenshot" "Select a region to capture..."
grim -g "$(slurp)" - | swappy -f -
