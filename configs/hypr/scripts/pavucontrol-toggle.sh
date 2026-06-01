#!/usr/bin/env bash
# ── CGGX Pavucontrol Toggle ──
# Click once to open, click again to close.

if pgrep -x pavucontrol > /dev/null 2>&1; then
  pkill -x pavucontrol
else
  pavucontrol &
fi
