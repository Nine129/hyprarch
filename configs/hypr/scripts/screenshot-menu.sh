#!/usr/bin/env bash

choice=$(
  printf "Copy to clipboard\nSave + Copy to clipboard\nSave + Copy path to clipboard\nCopy path to clipboard" \
  | fuzzel --dmenu \
    --lines 4 \
    --width 30 \
    --hide-prompt \
)

case "$choice" in
  "Copy to clipboard")
    grimblast copy area
    ;;
  "Save + Copy to clipboard")
    mkdir -p ~/Pictures/Screenshots
    grimblast copysave area ~/Pictures/Screenshots/$(date +%s).png
    ;;
  "Save + Copy path to clipboard")
    FILE=~/Pictures/$(date +%s).png
    grimblast save area "$FILE" && wl-copy "$FILE"
    ;;
  "Copy path to clipboard")
    FILE=/tmp/$(date +%s).png
    grimblast save area "$FILE" && wl-copy "$FILE"
    ;;
esac

 
