#!/usr/bin/env bash
# ── CGGX Kitty Float ──────────────────────────────
# Fast single-instance float window with per-window background color +
# opacity. Both are set by a command that runs INSIDE the new window: it
# inherits that instance's KITTY_LISTEN_ON and targets id:-1 (the newest
# OS window = itself), so it can never touch another kitty instance.
# Classes kitty-float and filepicker are excluded from styling and stay
# at kitty's global translucent look (see BOOTSTRAP selection below).
# Usage: kitty-float.sh [kitty options] [-- program args...]
set -euo pipefail

export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"

# Hyprland-spawned processes don't inherit the interactive shell's PATH;
# make brew-installed binaries (e.g. yazi) resolvable inside the float.
# Guarded on dir existence so a pacman-only yazi setup works untouched.
case ":$PATH:" in
  *:/home/linuxbrew/.linuxbrew/bin:*) ;;
  *) [ -d /home/linuxbrew/.linuxbrew/bin ] && export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH" ;;
esac

# env -u SHLVL: the float's kitty env has SHLVL=0; bash bumps it to 1 and
# exec'd zsh to 2, which breaks .zshrc's "[[ $SHLVL -eq 1 ]] && fastfetch".
# Stripping it makes the float's shell identical to a normal terminal window.
# BG_COLOR: per-float solid background, distinct from the global #151518 so
# floats read as a separate surface. OPACITY: 1.0 = opaque; <1.0 blends the
# BG color with whatever is behind the window.
# Override per launch:  BG_COLOR=#0a0a0c OPACITY=0.9 kitty-float.sh
BG_COLOR="${BG_COLOR:-#1d1d20}"
OPACITY="${OPACITY:-1.0}"

FLOAT_SET="kitty @ set-colors --match id:-1 background=${BG_COLOR} >/dev/null 2>&1 || true; kitty @ set-background-opacity --match id:-1 ${OPACITY} >/dev/null 2>&1 || true; exec env -u SHLVL \"\${1:-\$SHELL}\" \"\${@:2}\""

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

# Extract the effective class (default kitty-float) so styling can be
# excluded for the terminal-ish floats.
eff_class=kitty-float
class_given=0
for ((i=0; i<${#opts[@]}; i++)); do
  case "${opts[$i]}" in
    --class=*) eff_class="${opts[$i]#--class=}"; class_given=1; break ;;
    --class|-c) eff_class="${opts[$((i+1))]:-kitty-float}"; class_given=1; break ;;
  esac
done
[ "$class_given" -eq 0 ] && opts=(--class kitty-float "${opts[@]}")

# kitty-float (SUPER+SHIFT+Q) and filepicker (SUPER+SHIFT+E, yazi) keep
# kitty's global translucent look (background_opacity 0.78, #151518) to
# match the main terminal — no color/opacity forcing. All other floats
# (wiremix, wlctl, otter, latuicon, omp) get the styled solid surface.
case " $eff_class " in
  *" kitty-float "*|*" filepicker "*) BOOTSTRAP='exec env -u SHLVL "${1:-$SHELL}" "${@:2}"' ;;
  *) BOOTSTRAP="$FLOAT_SET" ;;
esac

if [ "${#prog[@]}" -eq 0 ]; then
  kitty --single-instance "${opts[@]}" -e bash -c "$BOOTSTRAP"
else
  kitty --single-instance "${opts[@]}" -e bash -c "$BOOTSTRAP" _ "${prog[@]}"
fi
