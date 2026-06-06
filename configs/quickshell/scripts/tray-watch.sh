#!/bin/bash
# ── CGGX Tray Width Daemon ─────────────────────────
# Listens for DBus tray icon registration/unregistration
# signals and immediately updates /tmp/qs-tray-width.
# Started from shell.qml and killed on Quickshell exit.
# Fallback: shell.qml polls the file every 200ms.
# ────────────────────────────────────────────────────

SCRIPT="/home/nine/hyprarch/configs/quickshell/scripts/tray-width.sh"

# Write initial value immediately
"$SCRIPT" > /tmp/qs-tray-width

# Monitor for tray icon changes (real-time)
dbus-monitor --session \
  "type='signal',interface='org.kde.StatusNotifierWatcher'" \
  2>/dev/null | while read -r line; do
    # Only re-query on registration/unregistration signals
    case "$line" in
      *StatusNotifierItemRegistered*|*StatusNotifierItemUnregistered*)
        "$SCRIPT" > /tmp/qs-tray-width
        ;;
    esac
done
