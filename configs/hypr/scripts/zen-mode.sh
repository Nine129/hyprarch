#!/bin/bash
# ── CGGX Rice — Zen Mode ──────────────────────────────────
# SUPER+P: toggle waybar + gaps + borders (runtime only, no config file write)
# State file keeps toggle across presses; hyprctl reload restores defaults.
set -euo pipefail

STATE="/tmp/cggx-zen-mode.active"
LOCK="/tmp/cggx-zen-mode.lock"

# Prevent spamming SUPER+P from racing waybar (systemd ExecStartPre sleep 1)
exec 200>"$LOCK"
flock -n 200 || exit 0

if [ -f "$STATE" ]; then
  # ── Restore ──
  # Preserve layout that is current *inside* zen (user may have swapped via SUPER+Y while in zen)
  # Must capture before reload, since reload resets to dwindle from settings.lua:22
  cur_layout=$(hyprctl getoption general:layout -j 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('str','dwindle'))" 2>/dev/null || echo "dwindle")
  case "$cur_layout" in
    dwindle|scrolling) ;;
    *) cur_layout="dwindle" ;;
  esac
  hyprctl reload
  if [ "$cur_layout" = "scrolling" ]; then
    hyprctl eval 'hl.config({general={layout="scrolling"}})' >/dev/null 2>&1 || true
  fi
  # waybar was stopped on enable; restart it instantly (systemd has ExecStartPre sleep 1 → slow)
  pkill waybar 2>/dev/null || true
  systemctl --user reset-failed waybar 2>/dev/null || true
  # Close lock FD for waybar child only (otherwise waybar inherits lock and blocks next toggle)
  200>&- waybar &>/dev/null & disown
  rm -f "$STATE"
else
  # ── Enable zen mode ──
  # Use systemd stop (SIGUSR1 duplicates when spammed — see 8 stacked bars)
  systemctl --user stop waybar 2>/dev/null || true
  pkill waybar 2>/dev/null || true
  touch "$STATE"
  # Lua config (hyprland.lua) requires `hyprctl eval` not `keyword` (see `hyprctl --help`)
  hyprctl eval 'hl.config({general={gaps_in=0, gaps_out=0, border_size=0}, decoration={rounding=0, shadow={enabled=false}}})' >/dev/null
  # Override rules.lua:22 which forces border_size 3 on single-window workspaces (float=false)
  # This runtime rule is appended last, so it wins until `hyprctl reload` clears it
  hyprctl eval 'hl.window_rule({ match = { float = false }, border_size = 0, no_shadow = true })' >/dev/null
fi
