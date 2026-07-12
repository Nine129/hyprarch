#!/usr/bin/env bash
selected=$(cliphist list | fuzzel --dmenu)
[ -z "$selected" ] && exit
decoded=$(echo "$selected" | cliphist decode)
printf '%s' "$decoded" | wl-copy
sleep 0.3
class=$(hyprctl activewindow -j | jq -r ".class" | tr "[:upper:]" "[:lower:]")
if [[ "$class" == "kitty" ]]; then
    # Terminal paste shortcut
    wtype -M ctrl -M shift v -m shift -m ctrl
else
    # GUI paste shortcut
    wtype -M ctrl v -m ctrl
fi
