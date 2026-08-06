#!/usr/bin/env bash
# ── CGGX Kitty Float ──────────────────────────────
# Fast single-instance float window (class kitty-float) with per-window
# background opacity 0.94. The opacity is set by a command that runs
# INSIDE the new window: it inherits that instance's KITTY_LISTEN_ON and
# targets id:-1 (the newest OS window = itself), so it can never touch
# another kitty instance.
# Usage: kitty-float.sh [kitty options] [-- program args...]
set -euo pipefail

export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"

# env -u SHLVL: the float's kitty env has SHLVL=0; bash bumps it to 1 and
# exec'd zsh to 2, which breaks .zshrc's "[[ $SHLVL -eq 1 ]] && fastfetch".
# Stripping it makes the float's shell identical to a normal terminal window.
OPACITY_SET='kitty @ set-background-opacity --match id:-1 0.94 >/dev/null 2>&1 || true; exec env -u SHLVL "${1:-$SHELL}" "${@:2}"'

opts=()
prog=()
in_prog=0
for a in "$@"; do
  if [ "$in_prog" -eq 1 ]; then
    prog+=("$a")
  elif [ "$a" = "--" ]; then
    in_prog=1
  else
    opts+=("$a")
  fi
done

# Default to the kitty-float class unless the bind passes one
class_given=0
for a in "${opts[@]}"; do
  case "$a" in --class|-c) class_given=1; break;; esac
done
[ "$class_given" -eq 0 ] && opts=(--class kitty-float "${opts[@]}")

if [ "${#prog[@]}" -eq 0 ]; then
  kitty --single-instance "${opts[@]}" -e bash -c "$OPACITY_SET"
else
  kitty --single-instance "${opts[@]}" -e bash -c "$OPACITY_SET" _ "${prog[@]}"
fi
