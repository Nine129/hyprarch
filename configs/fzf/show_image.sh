#!/usr/bin/env bash
set -u

file="${1:-}"
[[ -z "$file" || ! -f "$file" ]] && exit 0
file -b --mime-type "$file" 2>/dev/null | grep -q '^image/' || exit 0

viewer='
clear
kitten icat --stdin=no --transfer-mode=memory --align=center --scale-up --silent "'"$file"'"
echo
echo "[q] close  ·  [any other key] open externally"
while IFS= read -rsn1 k; do
  case "$k" in
    q) break ;;
    *) xdg-open "'"$file"'" >/dev/null 2>&1 & disown; break ;;
  esac
done
clear
'

# ── ghostty ───────────────────────────────────
if command -v ghostty >/dev/null 2>&1; then
  ghostty -e bash -c "$viewer"
  exit 0
fi

# ── kitty ─────────────────────────────────────
if [[ (-n "${KITTY_WINDOW_ID:-}" || "${TERM:-}" == "xterm-kitty") ]] && command -v kitten >/dev/null 2>&1; then
  kitten @ launch --type=window bash -c "$viewer" 2>/dev/null && exit 0
  # remote control not enabled — try inline
  bash -c "$viewer"
  exit 0
fi

# ── fallback: just open in system viewer ──────
xdg-open "$file" >/dev/null 2>&1 & disown
