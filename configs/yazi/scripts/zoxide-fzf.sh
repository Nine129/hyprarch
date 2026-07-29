#!/bin/sh
# Zoxide picker using fzf (styled via ~/.local/bin/fzf wrapper)
# Preview visible by default for directory browsing

selected=$(zoxide query --list | fzf --no-multi \
  --preview 'eza --tree --level=2 --color=always --icons=always {}' \
  --preview-window=right:35%:wrap:border-left:nohidden)

[ -n "$selected" ] && ya emit cd "$selected"
