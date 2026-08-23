#!/bin/bash

# Get current workspace ID
current_id=$(hyprctl activeworkspace -j | jq -r '.id')

if [ -z "$current_id" ]; then
  echo "Error: Could not determine current workspace."
  exit 1
fi

case "$1" in
  left)
    # Calculate target: current - 1
    target=$((current_id - 1))
    hyprctl dispatch "hl.dsp.focus({workspace = $target})"
    ;;
  right)
    # Calculate target: current + 1
    target=$((current_id + 1))
    hyprctl dispatch "hl.dsp.focus({workspace = $target})"
    ;;
  *)
    echo "Usage: $0 {left|right}"
    exit 1
    ;;
esac   
