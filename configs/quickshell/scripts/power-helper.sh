#!/bin/bash
# CGGX PowerPanel — privileged sysfs helper
# Invoked by Power.qml via Process
set -e

case "${1:-}" in
  charge-limit)
    printf '%s' "$2" | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold > /dev/null
    ;;
  *)
    echo "Usage: $0 charge-limit <value>" >&2
    exit 1
    ;;
esac
