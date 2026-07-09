#!/usr/bin/env bash
set -u

FILE="$1"
[[ -z "$FILE" || ! -e "$FILE" ]] && exit 0

CACHE_DIR="${FZF_PREVIEW_CACHE:-$HOME/.cache/fzf-preview}"
TMP_IMG="/tmp/fzf-preview-$$"
MAX_SIZE=$((100 * 1024 * 1024))
mkdir -p "$CACHE_DIR"

# ── helpers ───────────────────────────────────
get_file_size() { stat -c%s "$FILE" 2>/dev/null || stat -f%z "$FILE" 2>/dev/null; }

get_cache_key() {
  local mtime size
  mtime=$(stat -c "%Y" "$FILE" 2>/dev/null || stat -f "%m" "$FILE" 2>/dev/null)
  size=$(get_file_size)
  echo "${mtime}_${size}"
}

get_cached() {
  local key="$CACHE_DIR/$(get_cache_key)"
  [[ -f "$key" ]] && { touch "$key"; echo "$key"; return 0; }
  return 1
}

cmd_e() {
  if "$@" 2>/dev/null; then return 0; fi
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "  missing: $1"
  fi
  return 1
}

# ── preview methods ───────────────────────────
kitty_preview() {
  kitten icat --clear --stdin=no --transfer-mode=memory --unicode-placeholder \
    --scale-up --place="${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0" "$1"
}

chafa_preview() {
  chafa -s "${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}" "$1"
}

generic_preview() {
  file "$1" | fold -sw $((FZF_PREVIEW_COLUMNS - 1))
}

# ── pick preview method ───────────────────────
preview_image() {
  if [[ (-n "${KITTY_WINDOW_ID:-}" || "${TERM:-}" == "xterm-kitty") ]] && command -v kitten >/dev/null 2>&1; then
    kitty_preview "$1"
  elif command -v chafa >/dev/null 2>&1; then
    chafa_preview "$1"
  else
    generic_preview "$1"
  fi
}

# ── main ──────────────────────────────────────
# Check cache
cached=$(get_cached) && { preview_image "$cached"; exit 0; }

mime="$(file --dereference -b --mime-type "$FILE")"
IMG=""

case "$mime" in
  inode/directory)
    if command -v eza >/dev/null 2>&1; then
      eza --tree --level=2 --color=always --icons "$FILE" 2>/dev/null | head -200
    else
      ls -lah --color=always "$FILE" | head -200
    fi
    ;;

  image/vnd.djvu)
    if cmd_e ddjvu -format=tiff -size=1920x1080 -page=1 "$FILE" "$TMP_IMG"; then
      IMG="$TMP_IMG"
    fi
    ;;

  image/*)
    if command -v magick >/dev/null 2>&1; then
      if magick "$FILE" -auto-orient -resize x1080 "$TMP_IMG" 2>/dev/null; then
        IMG="$TMP_IMG"
      fi
    fi
    [[ -z "$IMG" ]] && IMG="$FILE"
    ;;

  audio/*)
    if cmd_e ffmpeg -y -i "$FILE" -an -c:v copy "$TMP_IMG.jpg" 2>/dev/null; then
      mv "$TMP_IMG.jpg" "$TMP_IMG"
      IMG="$TMP_IMG"
    else
      cmd_e exiftool "$FILE" 2>/dev/null || generic_preview "$FILE"
    fi
    ;;

  video/*)
    if cmd_e ffmpegthumbnailer -i "$FILE" -o "$TMP_IMG" -s 1080 -m 2>/dev/null; then
      IMG="$TMP_IMG"
    fi
    ;;

  application/pdf)
    if cmd_e pdftoppm -singlefile -jpeg -r 150 "$FILE" "$TMP_IMG" 2>/dev/null; then
      mv "$TMP_IMG.jpg" "$TMP_IMG"
      IMG="$TMP_IMG"
    elif command -v pdftotext >/dev/null 2>&1; then
      pdftotext -l 5 -layout "$FILE" - 2>/dev/null
    fi
    ;;

  *epub*|application/epub*)
    if cmd_e epub-thumbnailer "$FILE" "$TMP_IMG" "1080" 2>/dev/null; then
      IMG="$TMP_IMG"
    fi
    ;;

  application/zip)
    generic_preview "$FILE"
    [[ $(get_file_size) -lt $MAX_SIZE ]] && cmd_e unzip -l "$FILE" 2>/dev/null
    ;;
  application/gzip)
    generic_preview "$FILE"
    [[ $(get_file_size) -lt $MAX_SIZE ]] && cmd_e zcat "$FILE" 2>/dev/null
    ;;
  application/x-bzip2)
    generic_preview "$FILE"
    [[ $(get_file_size) -lt $MAX_SIZE ]] && cmd_e bzcat "$FILE" 2>/dev/null
    ;;
  application/x-xz)
    generic_preview "$FILE"
    [[ $(get_file_size) -lt $MAX_SIZE ]] && cmd_e xzcat "$FILE" 2>/dev/null
    ;;

  application/x-executable|application/x-pie-executable|application/x-sharedlib|application/x-object)
    cmd_e readelf -a "$FILE" 2>/dev/null || generic_preview "$FILE"
    ;;

  application/json)
    if command -v bat >/dev/null 2>&1; then
      bat --color=always --style=numbers "$FILE" 2>/dev/null
    else
      cat "$FILE"
    fi
    ;;

  text/*)
    if [[ "${FILE##*.}" == "md" ]] && command -v glow >/dev/null 2>&1; then
      glow --width $((FZF_PREVIEW_COLUMNS - 1)) "$FILE" 2>/dev/null
    elif command -v bat >/dev/null 2>&1; then
      bat --color=always --style=numbers,changes --line-range :200 "$FILE" 2>/dev/null
    else
      head -200 "$FILE"
    fi
    ;;

  *)
    # Try bat first for unknown types
    if command -v bat >/dev/null 2>&1; then
      bat --color=always --style=numbers,changes --line-range :200 "$FILE" 2>/dev/null || generic_preview "$FILE"
    else
      generic_preview "$FILE"
    fi
    ;;
esac

# ── display image ─────────────────────────────
if [[ -n "$IMG" ]]; then
  # Cache the generated thumbnail
  cache_key="$CACHE_DIR/$(get_cache_key)"
  cp "$IMG" "$cache_key" 2>/dev/null
  preview_image "$IMG"
else
  # Clean up kitty graphics if no image shown
  if [[ (-n "${KITTY_WINDOW_ID:-}" || "${TERM:-}" == "xterm-kitty") ]]; then
    kitten icat --clear --stdin=no --transfer-mode=memory 2>/dev/null
  fi
fi

# Cleanup temp file
[[ -f "$TMP_IMG" ]] && rm -f "$TMP_IMG"
