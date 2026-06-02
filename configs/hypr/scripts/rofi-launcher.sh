#!/usr/bin/env bash
# ── CGGX Cyberpunk Launcher ─────────────
# Custom Rofi launcher that color-codes app
# entries by FreeDesktop category.
#
# Category → Color  → Nerd Font Icon
# ───────────────────────────────────
# Development  #bd00ff (purple)    
# Game         #ff007f (pink)      
# Network      #00e5ff (cyan)      
# Graphics     #ff2d55 (red)       
# System       #ff6b00 (orange)    
# Office       #ffcc00 (gold)      
# AudioVideo   #ff2d55 (red)       
# Utility      #c8ff00 (lime)      
# Education    #00e5ff (cyan)      
# (default)    #e8e8f0 (silver)    
#
# Requires: rofi, gtk-launch (glib2)
# Font:     JetBrainsMonoNL Nerd Font Mono
# Bound:    SUPER + SPACE
# ──────────────────────────────────────────

set -euo pipefail

# ── Toggle ──────────────────────────────
pgrep -x rofi > /dev/null && { pkill -x rofi; exit 0; }

# ── Category maps ───────────────────────
declare -A COL
COL[Development]="#bd00ff"; COL[Game]="#ff007f"; COL[Network]="#00e5ff"
COL[Graphics]="#ff2d55";   COL[System]="#ff6b00"; COL[Office]="#ffcc00"
COL[AudioVideo]="#ff2d55"; COL[Audio]="#ff2d55";  COL[Video]="#ff2d55"
COL[Utility]="#c8ff00";    COL[Education]="#00e5ff"
COL[Settings]="#ff6b00";   COL[Science]="#00e5ff"
COL[GNOME]="#00e5ff";      COL[Qt]="#bd00ff"
COL[XFCE]="#ff6b00";       COL[Application]="#e8e8f0"
COL[FileTransfer]="#00e5ff"
COL[Maps]="#00e5ff"
COL_DEFAULT="#e8e8f0"

declare -A ICO
ICO[Development]=""; ICO[Game]=""; ICO[Network]=""
ICO[Graphics]="";    ICO[System]=""; ICO[Office]=""
ICO[AudioVideo]="";  ICO[Audio]="";  ICO[Video]=""
ICO[Utility]="";     ICO[Education]=""
ICO[Settings]="";    ICO[Science]=""
ICO[GNOME]="";       ICO[Qt]=""
ICO[XFCE]="";        ICO[Application]=""
ICO[FileTransfer]=""
ICO[Maps]=""
ICO_DEFAULT=""

# ── Helpers ──────────────────────────────
resolve_cat() {
  local cats="$1"
  [[ -z "$cats" ]] && echo "" && return
  while IFS=';' read -ra parts; do
    for p in "${parts[@]}"; do
      p="${p## }"; p="${p%% }"
      [[ -z "$p" ]] && continue
      [[ "$p" == X-* ]] && continue
      [[ "$p" == "GTK" ]] && continue
      [[ "$p" == "Application" ]] && continue
      echo "$p"; return
    done
  done <<< "$cats"
  echo ""
}

escape() {
  local s="$1"
  s="${s//&/&amp;}"; s="${s//</&lt;}"; s="${s//>/&gt;}"
  s="${s//\'/&apos;}"; s="${s//\"/&quot;}"
  echo "$s"
}

# ── Cache paths ─────────────────────────
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/cggx"
CACHE="$CACHE_DIR/launcher-entries.txt"
mkdir -p "$CACHE_DIR"

# ── Rebuild cache ───────────────────────
rebuild_cache() {
  declare -A SEEN
  for dir in \
    /usr/share/applications /usr/local/share/applications \
    /var/lib/flatpak/exports/share/applications \
    "$HOME/.local/share/applications" \
    "$HOME/.local/share/flatpak/exports/share/applications"; do
    [[ -d "$dir" ]] || continue
    while IFS= read -r -d '' file; do
      SEEN["$(basename "$file")"]="$file"
    done < <(find "$dir" -maxdepth 1 -name '*.desktop' -type f -print0 2>/dev/null)
  done

  (
    for bn in "${!SEEN[@]}"; do
      file="${SEEN[$bn]}"
      grep -qis '^NoDisplay=true' "$file" && continue
      name=$(grep -m1 '^Name=' "$file" | sed 's/^Name=//') || true
      categories=$(grep -m1 '^Categories=' "$file" | sed 's/^Categories=//') || true
      [[ -z "$name" ]] && continue

      cat=$(resolve_cat "$categories")
      # Fallback for apps with no/incomplete categories
      if [[ -z "$cat" || -z "${COL[$cat]:-}" ]]; then
        case "$bn" in
          rofi*|rofi-theme*) cat="System" ;;     # Rofi is a system tool
          *) cat="" ;;
        esac
      fi

      if [[ -n "$cat" ]]; then
        color="${COL[$cat]:-$COL_DEFAULT}"
        icon="${ICO[$cat]:-$ICO_DEFAULT}"
      else
        color="$COL_DEFAULT"; icon="$ICO_DEFAULT"
      fi
      # Prepend sort key (name) with @@@ delimiter, strip after sort
      echo "$(escape "$name")@@@<span foreground='$color'>$icon  $(escape "$name")</span>|$bn"
    done | sort -t'@' -k1 | cut -d'@' -f4-
  ) > "$CACHE"
}

# ── Check freshness (fast: dir mtime) ──
rebuild_needed=false
if [[ ! -f "$CACHE" ]]; then
  rebuild_needed=true
else
  cache_mtime=$(stat -c '%Y' "$CACHE")
  for dir in \
    /usr/share/applications /usr/local/share/applications \
    /var/lib/flatpak/exports/share/applications \
    "$HOME/.local/share/applications" \
    "$HOME/.local/share/flatpak/exports/share/applications"; do
    [[ -d "$dir" ]] || continue
    [[ "$(stat -c '%Y' "$dir")" -gt "$cache_mtime" ]] && { rebuild_needed=true; break; }
  done
fi

$rebuild_needed && rebuild_cache

# ── Quick empty check ───────────────────
if [[ ! -s "$CACHE" ]]; then
  rofi -e "No applications found" -theme "$HOME/.config/rofi/config.rasi"
  exit 1
fi

# ── Launch Rofi (pipe cache directly) ──
selected_idx=$(cut -d'|' -f1 "$CACHE" | \
  LC_ALL=C.UTF-8 rofi -dmenu -markup-rows -p "" \
    -theme "$HOME/.config/rofi/config.rasi" \
    -format 'i' -i -window-title "cggx-launcher")

[[ -z "$selected_idx" ]] && exit 0

# ── Launch app ──────────────────────────
desktop_bn=$(sed -n "$((selected_idx + 1))p" "$CACHE" | cut -d'|' -f2)
gtk-launch "${desktop_bn%.desktop}" &
