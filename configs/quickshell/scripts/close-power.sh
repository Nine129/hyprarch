#!/bin/bash
# Only close the PowerPanel popout if it's open
STATE_FILE="/tmp/qs-power-state"
if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "1" ]; then
    echo "0" > "$STATE_FILE"
fi
