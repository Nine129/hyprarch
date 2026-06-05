#!/bin/bash
# Toggle QuickShell volume popout
STATE_FILE="/tmp/qs-volume-state"
if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "1" ]; then
    echo "0" > "$STATE_FILE"
else
    echo "1" > "$STATE_FILE"
fi
