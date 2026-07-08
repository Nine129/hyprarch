#!/usr/bin/env bash
# ── CGGX Power Profile Switcher ────────────────────────────────
# Rofi-based ACPI platform profile picker.
# Close: ESC, click battery again, or cursor leaves modal.
# ───────────────────────────────────────────────────────────────

set -euo pipefail

PIDFILE="/tmp/cggx-power-profile.pid"
ROFI_OUTPUT="/tmp/cggx-power-profile-out.txt"
PROFILE_FILE="/sys/firmware/acpi/platform_profile"
THEME_FILE="/tmp/cggx-power-profile-theme.rasi"

# ── Toggle ─────────────────────────────────────────────────────
if [[ -f "$PIDFILE" ]]; then
  old_pid=$(cat "$PIDFILE" 2>/dev/null || echo "")
  if [[ -n "$old_pid" ]] && kill -0 "$old_pid" 2>/dev/null; then
    kill "$old_pid" 2>/dev/null || true
    rm -f "$PIDFILE"
    exit 0
  fi
  rm -f "$PIDFILE"
fi

# ── Read current ──────────────────────────────────────────────
current=$(cat "$PROFILE_FILE" 2>/dev/null || echo "balanced")

# ── Profile data ──────────────────────────────────────────────
profiles=("low-power" "balanced" "performance")
colors=("#00e5ff" "#c8ff00" "#ff6b00")
icons=("󰌪" "" "")

# ── Build entries ──────────────────────────────────────────────
entries=""
for i in "${!profiles[@]}"; do
  entries+="<span foreground=\"${colors[$i]}\">${icons[$i]}  ${profiles[$i]}</span>\n"
done

# ── Find current index ────────────────────────────────────────
sel=0
for i in "${!profiles[@]}"; do
  [[ "${profiles[$i]}" == "$current" ]] && { sel=$i; break; }
done

# ── Highlight color matches current profile ───────────────────
hl_color="${colors[$sel]}"

# ── Write theme file ───────────────────────────────────────────
cat > "$THEME_FILE" << THEME
* {
  background-color: #1a1a20;
  text-color:       #e8e8f0;
  border-radius:    0;
  spacing:          0;
  padding:          0;
  margin:           0;
}

window {
  background-color: #1a1a20;
  border: 0;
  border-radius: 0;
  width: 220px;
  font: "MonaspiceNe Nerd Font Mono 13";
  location: northeast;
  x-offset: -60;
  y-offset: 0;
  padding: 0;
}

mainbox {
  spacing: 0;
  padding: 0;
  border: 0;
  children: [ listview ];
}

listview {
  spacing: 0;
  padding: 0;
  border: 0;
  scrollbar: false;
  lines: 3;
}

element {
  padding: 10px 14px;
  cursor: pointer;
  children: [ element-text ];
  orientation: horizontal;
}

element normal.normal { text-color: inherit; border: 0; }
element alternate.normal { border: 0; }
element selected.normal {
  border: 0px 0px 0px 4px;
  border-color: $hl_color;
  text-color: inherit;
}
element selected.urgent { }
element selected.active { }

element-text {
  padding: 0;
  margin: 0;
  vertical-align: 0.5;
  horizontal-align: 0;
  highlight: inherit;
}

inputbar { enabled: false; }
prompt { enabled: false; }
entry { enabled: false; }
case-indicator { enabled: false; }
message { enabled: false; }
separator { enabled: false; }
THEME

# ── Launch ─────────────────────────────────────────────────────
rm -f "$ROFI_OUTPUT"
echo -e "$entries" > /tmp/cggx-power-profile-in.txt
rofi -dmenu -p "" -theme "$THEME_FILE" -normal-window -click-to-exit -no-custom \
  -lines 3 -selected-row "$sel" -markup-rows \
  -me-select-entry "" -me-accept-entry MousePrimary \
  < /tmp/cggx-power-profile-in.txt > "$ROFI_OUTPUT" 2>/dev/null &
ROFI_PID=$!

echo "$ROFI_PID" > "$PIDFILE"

# ── Cursor monitor ─────────────────────────────────────────────
(
  sleep 0.4
  geo=$(hyprctl layers -j 2>/dev/null | \
    jq 'to_entries[].value.levels."3"[] | select(.namespace=="rofi")|{x,y,w,h}')
  rx=$(echo "$geo"|jq -r '.x//0'); ry=$(echo "$geo"|jq -r '.y//0')
  rw=$(echo "$geo"|jq -r '.w//220'); rh=$(echo "$geo"|jq -r '.h//100')
  stem=$((rx+rw+80))

  while kill -0 "$ROFI_PID" 2>/dev/null; do
    c=$(hyprctl cursorpos 2>/dev/null || echo "0,0")
    cx="${c%%,*}"; cy="${c#*, }"
    if (( cx < rx || cx > rx+rw || cy < ry || cy > ry+rh )); then
      if (( cy >= 0 && cy < ry && cx >= rx && cx <= stem )); then
        sleep 0.1; continue
      fi
      kill "$ROFI_PID" 2>/dev/null || true; break
    fi
    sleep 0.1
  done
  rm -f "$PIDFILE" 2>/dev/null || true
) &
MON=$!

wait "$ROFI_PID" 2>/dev/null || true
kill "$MON" 2>/dev/null || true
rm -f "$PIDFILE" "$THEME_FILE"

# ── Match & switch ──────────────────────────────────────────────
selected=$(cat "$ROFI_OUTPUT" 2>/dev/null || echo "")
rm -f "$ROFI_OUTPUT" /tmp/cggx-power-profile-in.txt

for i in "${!profiles[@]}"; do
  if echo "$selected" | grep -qi "${profiles[$i]}"; then
    chosen="${profiles[$i]}"
    if [[ "$chosen" != "$current" ]]; then
      echo "$chosen" | sudo tee "$PROFILE_FILE" > /dev/null
      color="${colors[$i]}"
      notify-send -u low "Power Profile" \
        "Switched to <span foreground=\"$color\">$chosen</span>" \
        -a "Power Profile"
    fi
    break
  fi
done
