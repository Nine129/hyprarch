#!/usr/bin/env bash
# ── Latuicon Emoji/Icon Picker ──────────────────
# Opens latuicon in a floating terminal, pipes selection to clipboard + auto-paste.
# Bound to SUPER+SPACE in binds.lua

OUTFILE="/tmp/latuicon-$$.out"
trap 'rm -f "$OUTFILE"' EXIT

# Fast float via kitty-float.sh (single-instance + per-window opacity);
# the inner bash -c keeps the latuicon output redirect intact.
bash ~/hyprarch/configs/hypr/scripts/kitty-float.sh --class kitty-float-latuicon \
  -- bash -c "latuicon --theme cggx > '$OUTFILE'"

# Client returns immediately — poll for output
while [ ! -s "$OUTFILE" ] && [ "$SECONDS" -lt 20 ]; do
    sleep 0.05
done

ICON=$(cat "$OUTFILE" 2>/dev/null || true)
[ -z "$ICON" ] && exit

printf '%s' "$ICON" | wl-copy

# Auto-paste into focused window (cliphist-style)
sleep 0.3
class=$(hyprctl activewindow -j | jq -r '.class' | tr '[:upper:]' '[:lower:]')
if [[ "$class" == "kitty" ]]; then
    wtype -M ctrl -M shift v -m shift -m ctrl
else
    wtype -M ctrl v -m ctrl
fi
