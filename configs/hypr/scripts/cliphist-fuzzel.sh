#!/bin/bash
selected=$(cliphist list | fuzzel --dmenu)
[ -z "$selected" ] && exit
decoded=$(echo "$selected" | cliphist decode)
echo "$decoded" | wl-copy

sleep 0.3
class=$(hyprctl activewindow -j | jq -r ".class" | tr "[:upper:]" "[:lower:]")
if [[ "$class" == "kitty" ]]; then
    KITTY_SOCKET=$(ls /tmp/kitty-socket-* 2>/dev/null | head -1)
    kitty @ --to "unix:$KITTY_SOCKET" send-text "$(wl-paste --no-newline)"
else
    wtype -M ctrl v -m ctrl
fi
