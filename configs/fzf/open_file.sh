#!/usr/bin/env bash
set -u
[[ $# -eq 0 ]] && exit 0

pick_one() {
  local label="$1"; shift
  local out key raw

  out="$(FZF_DEFAULT_OPTS="" printf '%s\n' "$@" | fzf \
    --ansi \
    --no-multi \
    --marker='' \
    --pointer='' \
    --cycle \
    --height=40% \
    --layout=reverse \
    --border=rounded \
    --border-label="$label" \
    --prompt='   ' \
    --info=right \
    --color='fg:#cdd6f4,fg+:#c8ff00,hl:#89b4fa,hl+:#b4befe,pointer:#f38ba8' \
    --header='  ↵ open   ESC cancel  ' \
    --header-first \
    --expect=enter,esc)"

  key="$(printf '%s\n' "$out" | sed -n '1p')"
  raw="$(printf '%s\n' "$out" | sed -n '2p')"

  [[ "$key" == "esc" || -z "$raw" ]] && return 1
  printf '%s' "$raw"
  return 0
}

# Classify a file by type
classify() {
  local f="$1" mime ext
  mime="$(file -b --mime-type "$f" 2>/dev/null || true)"
  ext="${f##*.}"
  ext="$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')"

  if [[ "$ext" == "svg" || "$mime" == "image/svg+xml" ]]; then
    printf 'svg'; return
  fi
  if [[ "$mime" == image/* ]]; then
    printf 'image'; return
  fi
  if [[ "$mime" == video/* ]]; then
    printf 'video'; return
  fi
  if [[ "$mime" == audio/* ]]; then
    printf 'audio'; return
  fi
  printf 'text'
}

# Sort files into buckets
declare -a images=() videos=() audios=() svgs=() texts=()
for f in "$@"; do
  case "$(classify "$f")" in
    image) images+=("$f") ;;
    video) videos+=("$f") ;;
    audio) audios+=("$f") ;;
    svg)   svgs+=("$f") ;;
  esac
done

# ── Images: open in imv ───────────────────────
for f in "${images[@]}"; do
  imv "$f" >/dev/null 2>&1 & disown
done

# ── SVGs: open in system handler ──────────────
for f in "${svgs[@]}"; do
  xdg-open "$f" >/dev/null 2>&1 & disown
done

# ── Videos: pick once, apply to all ───────────
if [[ ${#videos[@]} -gt 0 ]]; then
  vchoices=()
  command -v mpv >/dev/null 2>&1  && vchoices+=("mpv")
  command -v vlc >/dev/null 2>&1  && vchoices+=("vlc")
  command -v celluloid >/dev/null 2>&1 && vchoices+=("celluloid")

  if [[ ${#vchoices[@]} -gt 0 ]]; then
    vchoice="$(pick_one $' \033[1;38;5;111m✦\033[0m  \033[1;38;5;189mOPEN VIDEO WITH\033[0m  \033[1;38;5;111m✦\033[0m ' "${vchoices[@]}")" || vchoice=""
  else
    vchoice=""
  fi

  if [[ -n "${vchoice:-}" ]]; then
    for f in "${videos[@]}"; do
      case "${vchoice:-}" in
        mpv)       mpv "$f" >/dev/null 2>&1 & disown ;;
        vlc)       vlc "$f" >/dev/null 2>&1 & disown ;;
        celluloid) celluloid "$f" >/dev/null 2>&1 & disown ;;
        *)         xdg-open "$f" >/dev/null 2>&1 & disown ;;
      esac
    done
  fi
fi

# ── Audio: pick player, apply to all ──────────
if [[ ${#audios[@]} -gt 0 ]]; then
  achoices=()
  command -v mpv >/dev/null 2>&1 && achoices+=("mpv")
  achoices+=("rmpc")
  command -v xdg-open >/dev/null 2>&1 && achoices+=("xdg-open")

  if [[ ${#achoices[@]} -gt 0 ]]; then
    achoice="$(pick_one $' \033[1;38;5;111m✦\033[0m  \033[1;38;5;189mOPEN AUDIO WITH\033[0m  \033[1;38;5;111m✦\033[0m ' "${achoices[@]}")" || achoice=""
  else
    achoice=""
  fi

  if [[ -n "${achoice:-}" ]]; then
    for f in "${audios[@]}"; do
      case "${achoice:-}" in
        mpv)      mpv "$f" >/dev/null 2>&1 & disown ;;
        rmpc)     f_abs="$(realpath "$f" 2>/dev/null || echo "$f")"; rmpc clear 2>/dev/null; rmpc add "$f_abs" 2>/dev/null; rmpc play 2>/dev/null ;;
        xdg-open) xdg-open "$f" >/dev/null 2>&1 & disown ;;
        *)        xdg-open "$f" >/dev/null 2>&1 & disown ;;
      esac
    done
  fi
fi

# ── Text/other: editor pick once, apply to all ─
if [[ ${#texts[@]} -gt 0 ]]; then
  choices=()
  command -v nvim  >/dev/null 2>&1 && choices+=("nvim")
  command -v helix >/dev/null 2>&1 && choices+=("helix")
  command -v code  >/dev/null 2>&1 && choices+=("vscode")
  command -v nano  >/dev/null 2>&1 && choices+=("nano")
  command -v xdg-open >/dev/null 2>&1 && choices+=("xdg-open")
  [[ ${#choices[@]} -eq 0 ]] && exit 0

  choice="$(pick_one $' \033[1;38;5;111m✦\033[0m  \033[1;38;5;189mOPEN WITH\033[0m  \033[1;38;5;111m✦\033[0m ' "${choices[@]}")" || exit 0

  case "$choice" in
    nvim)     exec nvim "${texts[@]}" ;;
    helix)    exec helix "${texts[@]}" ;;
    vscode)   for f in "${texts[@]}"; do code -g "$f" >/dev/null 2>&1 & disown; done ;;
    nano)     exec nano "${texts[@]}" ;;
    xdg-open) for f in "${texts[@]}"; do xdg-open "$f" >/dev/null 2>&1 & disown; done ;;
  esac
fi
