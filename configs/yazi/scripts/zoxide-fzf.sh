#!/bin/sh
# Zoxide picker using fzf (styled via ~/.local/bin/fzf wrapper)
# Preview visible by default for directory browsing

# yazi may run from environments without the brew prefix on PATH
# (e.g. spawned by Hyprland binds), which would make `ya` 127.
# Guarded on dir existence: with pacman yazi, ya lives in /usr/bin anyway.
case ":$PATH:" in
  *:/home/linuxbrew/.linuxbrew/bin:*) ;;
  *) [ -d /home/linuxbrew/.linuxbrew/bin ] && export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH" ;;
esac

selected=$(zoxide query --list | fzf --no-multi \
  --preview 'eza --tree --level=2 --color=always --icons=always {}' \
  --preview-window=right:35%:wrap:border-left:nohidden)

[ -n "$selected" ] && ya emit cd "$selected"
