#!/usr/bin/env bash
# ── CGGX Screenshot Menu ──────────────────────────
# Fuzzel menu: capture a region, then OCR / translate / lens / save / annotate / QR.
# Bound to SUPER+Print and CTRL+Print in binds.lua.
# Usage: screenshot-menu.sh [action]  (action skips the menu; handy for keybinds/tests)
set -euo pipefail

SAVE_DIR="${SCREENSHOT_DIR:-$HOME/Pictures/Screenshots}"
TARGET_LANG="${TRANSLATE_LANG:-en}"     # Google Translate target language
TESS_LANG="${TESS_LANG:-eng+vie}"   # tesseract packs (eng = tesseract-data-eng, vie = tesseract-data-vie)
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

notify() {
  local title="Screenshot Menu"
  if [[ $# -ge 2 ]]; then
    notify-send -i "$2" "$title" "$1"
  else
    notify-send "$title" "$1"
  fi
}

# Capture a region; silent exit if cancelled (Esc)
capture() {
  if ! grimblast save area "$WORKDIR/shot.png"; then
    exit 1
  fi
}

# All tesseract language packs in $TESS_LANG present?
have_tess() {
  local lang
  for lang in ${TESS_LANG//+/ }; do
    tesseract --list-langs 2>/dev/null | awk 'NF==1 {print $1}' | grep -qx "$lang" || return 1
  done
}

tess_warning() {
  local lang missing=()
  for lang in ${TESS_LANG//+/ }; do
    if ! tesseract --list-langs 2>/dev/null | awk 'NF==1 {print $1}' | grep -qx "$lang"; then
      missing+=("tesseract-data-$lang")
    fi
  done
  notify "OCR needs ${missing[*]} — run: sudo pacman -S ${missing[*]}"
  exit 1
}

ocr_text() {
  local src="$WORKDIR/shot.png"
  # 2x upscale helps tesseract on small UI text; fall back to original if magick fails
  if magick "$src" -resize '200%' "$WORKDIR/ocr.png" 2>/dev/null && [[ -s "$WORKDIR/ocr.png" ]]; then
    src="$WORKDIR/ocr.png"
  fi
  tesseract "$src" stdout -l "$TESS_LANG" 2>/dev/null | sed '/^[[:space:]]*$/d'
}

action_ocr() {
  have_tess || tess_warning
  capture
  local text
  text="$(ocr_text)"
  if [[ -z "$text" ]]; then
    notify "No text found in selection"
    exit 1
  fi
  wl-copy <<<"$text"
  notify "OCR copied: ${text:0:140}"
}

action_translate() {
  have_tess || tess_warning
  capture
  local text encoded resp translation
  text="$(ocr_text)"
  if [[ -z "$text" ]]; then
    notify "No text found in selection"
    exit 1
  fi
  encoded="$(python3 -c 'import urllib.parse,sys; s=sys.stdin.read().strip()[:1500]; print(urllib.parse.quote(s))' <<<"$text")"
  resp="$(curl -fsS --max-time 20 "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=${TARGET_LANG}&dt=t&q=${encoded}")" || {
    notify "Translate failed — no network?"
    exit 1
  }
  translation="$(jq -r '.[0][0][0]' <<<"$resp")"
  if [[ -z "$translation" || "$translation" == "null" ]]; then
    notify "No translation returned"
    exit 1
  fi
  wl-copy <<<"$translation"
  notify "Translated: ${translation:0:140}"
}

action_lens() {
  "$HOME/.config/hypr/scripts/lens-search.sh"
}

action_save() {
  capture
  mkdir -p "$SAVE_DIR"
  local file="$SAVE_DIR/$(date +%Y-%m-%d_%H-%M-%S).png"
  mv "$WORKDIR/shot.png" "$file"
  notify "Saved: $file" "$file"
}

action_save_copy_path() {
  capture
  mkdir -p "$SAVE_DIR"
  local file="$SAVE_DIR/$(date +%Y-%m-%d_%H-%M-%S).png"
  mv "$WORKDIR/shot.png" "$file"
  wl-copy "$file"
  notify "Saved + path copied: $file" "$file"
}

action_save_copy_img() {
  capture
  mkdir -p "$SAVE_DIR"
  local file="$SAVE_DIR/$(date +%Y-%m-%d_%H-%M-%S).png"
  mv "$WORKDIR/shot.png" "$file"
  wl-copy --type image/png < "$file"
  notify "Saved + image copied: $file" "$file"
}

action_swappy() {
  "$HOME/.config/hypr/scripts/screenshot-swappy.sh"
}

action_qr() {
  capture
  local result
  result="$(zbarimg --raw -q "$WORKDIR/shot.png" 2>/dev/null || true)"
  if [[ -z "$result" ]]; then
    notify "No QR code found in selection"
    exit 1
  fi
  wl-copy <<<"$result"
  notify "QR copied: ${result:0:140}"
  if [[ "$result" =~ ^https?:// ]]; then
    xdg-open "$result" &
  fi
}

menu() {
  printf "󰄽  OCR\n󰗙  Translate\n󰍉  Lens\n󰆓  Save\n󰆏  Save and Copy Path\n󰊮  Save and Copy Image\n󰏪  Annotate (Swappy)\n󰊨  Scan QR Code" \
    | fuzzel --dmenu \
      --lines 8 \
      --width 27 \
      --hide-prompt \
      --background-color=151518ff \
      --text-color=e8e8f0ff \
      --match-color=b48cffff \
      --selection-color=b48cffff \
      --selection-text-color=0a0a0cff \
      --selection-match-color=9a6affff \
      --border-color=b48cffff \
      --prompt-color=b48cffff \
      --input-color=b48cffff
}

main() {
  local choice="${1:-}"
  if [[ -z "$choice" ]]; then
    choice="$(menu)"
  fi
  if [[ -z "$choice" ]]; then
    exit 0  # menu cancelled
  fi

  case "$choice" in
    *"Save and Copy Path"*)  action_save_copy_path ;;
    *"Save and Copy Image"*) action_save_copy_img ;;
    *"Save"*)                action_save ;;
    *"Translate"*)          action_translate ;;
    *"OCR"*)                action_ocr ;;
    *"Lens"*)               action_lens ;;
    *"Swappy"*)             action_swappy ;;
    *"QR"*)                 action_qr ;;
    *)                      notify "Unknown action: $choice" ;;
  esac
}

main "$@"
