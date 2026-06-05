#!/bin/bash
# Only close the volume popout if it's open
STATE_FILE="/tmp/qs-volume-state"
if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "1" ]; then
    echo "0" > "$STATE_FILE"
fi
