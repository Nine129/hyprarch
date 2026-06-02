#!/usr/bin/env bash
# ── Smart Float Toggle ────────────────────────────
set -euo pipefail

win_json=$(hyprctl -j activewindow 2>/dev/null || echo "{}")
floating=$(echo "$win_json" | python3 -c "import sys,json; print(json.load(sys.stdin).get('floating',False))" 2>/dev/null || echo "False")

if [[ "$floating" == "True" ]]; then
  # Floating → back to tiled
  hyprctl eval "hl.dispatch(hl.dsp.window.float({action='toggle'}))" 2>/dev/null
  exit 0
fi

# Tiled → float it
hyprctl eval "hl.dispatch(hl.dsp.window.float({action='toggle'}))" 2>/dev/null

# Wait for float to settle, then check size and shrink if needed
sleep 0.05

new_json=$(hyprctl -j activewindow 2>/dev/null || echo "{}")
new_w=$(echo "$new_json" | python3 -c "import sys,json; print(json.load(sys.stdin).get('size',[0,0])[0])" 2>/dev/null || echo "0")
new_h=$(echo "$new_json" | python3 -c "import sys,json; print(json.load(sys.stdin).get('size',[0,0])[1])" 2>/dev/null || echo "0")

mon_json=$(hyprctl -j monitors 2>/dev/null || echo "[{}]")
mon_w=$(echo "$mon_json" | python3 -c "import sys,json; print(json.load(sys.stdin)[0].get('width',1920))" 2>/dev/null || echo "1920")
mon_h=$(echo "$mon_json" | python3 -c "import sys,json; print(json.load(sys.stdin)[0].get('height',1080))" 2>/dev/null || echo "1080")

# If window is bigger than 70% of monitor in either dimension, shrink it
big=$(python3 -c "
w, mw, h, mh = $new_w, $mon_w, $new_h, $mon_h
print('true' if (w > 0 and h > 0 and (w/mw > 0.7 or h/mh > 0.7)) else 'false')
" 2>/dev/null || echo "false")

if [[ "$big" == "true" ]]; then
  target_w=$(( mon_w * 80 / 100 ))
  target_h=$(( mon_h * 85 / 100 ))
  delta_w=$(( target_w - new_w ))
  delta_h=$(( target_h - new_h ))
  hyprctl eval "hl.dispatch(hl.dsp.window.resize({x=$delta_w, y=$delta_h, relative=true}))" 2>/dev/null
fi
