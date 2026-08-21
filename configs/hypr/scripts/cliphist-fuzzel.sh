#!/usr/bin/env bash
selected=$(cliphist list | fuzzel --dmenu \
  --background-color=1d1d20ff \
  --text-color=e8e8f0ff \
  --match-color=00E5FFff \
  --selection-color=00E5FFff \
  --selection-text-color=0a0a0cff \
  --border-color=00E5FFff \
  --border-width=3 \
  --prompt-color=00E5FFff \
  --lines=12 \
  --font="MonaspiceNe Nerd Font Bold:size=10" \
  --width=50 \
)
[ -z "$selected" ] && exit
echo "$selected" | cliphist decode | wl-copy
sleep 0.3
class=$(hyprctl activewindow -j | jq -r ".class" | tr "[:upper:]" "[:lower:]")
if [[ "$class" == "kitty" ]]; then
    # Terminal paste shortcut
    wtype -M ctrl -M shift v -m shift -m ctrl
else
    # GUI paste shortcut
    wtype -M ctrl v -m ctrl
fi
