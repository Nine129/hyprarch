# ============================================
# FZF Configuration — CGGX Kinetic Brutalism
# ============================================

_CGGX_COLORS="--color=bg:-1,bg+:-1,gutter:#151518
--color=fg:#ffffff,fg+:#c8ff00,hl:#c8ff00,hl+:#00e5ff
--color=border:#c8ff00,separator:#3d1a00
--color=spinner:#00e5ff,info:#00e5ff,header:#FF6B00
--color=pointer:#ff2d55,marker:#c8ff00,prompt:#FF6B00,scrollbar:#FF6B00
--color=label:#c8ff00,preview-label:#00e5ff,query:#ffffff"

# ── Base Options (no color) ─────────────────

_FZF_BASE_OPTS="
  --multi
  --layout=reverse
  --height=88%
  --border=rounded
  --border-label=' ⟡  FUZZY FINDER  ⟡ '
  --border-label-pos=center
  --margin=1,2
  --padding=0,2

  --preview='~/.config/fzf/preview.sh {}'
  --preview-window=right:58%:wrap:border-left:hidden

  --info=right
  --separator='╌'
  --scrollbar='▏'

  --prompt='⌕  '
  --pointer='❯'
  --marker='◆'

  --header='  ↵ open   ALT-I images   ALT-M videos   ALT-A all   CTRL-/ preview   CTRL-Y copy path   SPC select   ESC quit  '
  --header-first

  --bind='enter:execute(~/.config/fzf/open_file.sh {+})'
  --bind='ctrl-/:toggle-preview'
  --bind='ctrl-u:preview-half-page-up'
  --bind='ctrl-d:preview-half-page-down'
  --bind='ctrl-f:preview-page-down'
  --bind='ctrl-b:preview-page-up'

  --bind='alt-i:reload(fd --type f --hidden --follow --exclude .git --extension jpg --extension jpeg --extension png --extension gif --extension webp --extension bmp --extension tiff --extension svg)+change-border-label( ⟡  IMAGES  ⟡ )'
  --bind='alt-m:reload(fd --type f --hidden --follow --exclude .git --extension mp4 --extension mov --extension mkv --extension webm --extension avi --extension m4v --extension flv --extension wmv)+change-border-label( ⟡  VIDEOS  ⟡ )'
  --bind='alt-a:reload(fd --type f --hidden --follow --exclude .git)+change-border-label( ⟡  ALL FILES  ⟡ )'

  --bind='tab:toggle+down'
  --bind='btab:toggle+up'
  --bind='space:toggle'
  --bind='ctrl-a:select-all'
  --bind='ctrl-x:deselect-all'
  --bind='shift-up:preview-up'
  --bind='shift-down:preview-down'
  --bind='esc:abort'
"



# ── Copy path bind (wl-copy for Wayland/Hyprland) ──
_FZF_COPY_BIND=$'--bind=\'ctrl-y:execute-silent(printf "%s\\n" {+} | wl-copy; count=$(printf "%s\\n" {+} | wc -l | tr -d " "); msg="  ✔  ${count} path(s) copied  "; { printf "\\033[s\\033[999;1H\\033[K\\033[1;38;2;200;255;0m${msg}\\033[0m" >/dev/tty; sleep 0.5; printf "\\033[999;1H\\033[K\\033[u" >/dev/tty; } &)+bell\''
export FZF_DEFAULT_OPTS="$_FZF_BASE_OPTS $_FZF_COPY_BIND $_CGGX_COLORS"

# ── Remaining exports ────────────────────────

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_CTRL_T_OPTS="
  --border-label=' ⟡  FILES  ⟡ '
  --border-label-pos=center
  --preview='~/.config/fzf/preview.sh {}'
  --preview-window=right:58%:wrap:border-left
"

export FZF_CTRL_R_OPTS="
  --scheme=history
  --border-label=' ⟡  HISTORY  ⟡ '
  --border-label-pos=center
  --preview='echo {}'
  --preview-window=down:4:wrap:border-top
  --bind='enter:accept'
  --bind='ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'
  --header='  CTRL-Y copy  |  CTRL-R toggle sort  '
"

export FZF_ALT_C_OPTS="
  --border-label=' ⟡  DIRECTORIES  ⟡ '
  --border-label-pos=center
  --preview='eza --tree --level=2 --color=always --icons {} | head -200'
  --preview-window=right:58%:wrap:border-left
"

fzf_with_preview() {
  fzf "$@"
  if [[ -n "${KITTY_WINDOW_ID:-}" || "${TERM:-}" == "xterm-kitty" ]]; then
    printf '\033_Ga=d,d=A\033\\' >/dev/tty 2>/dev/null
    kitten icat --clear --stdin=no --silent 2>/dev/null
  fi
}

alias fzfp='fzf_with_preview --preview "~/.config/fzf/preview.sh {}"'
alias fzfd='fd --type d --hidden --follow --exclude .git | fzf_with_preview --border-label=" ⟡  DIRECTORIES  ⟡ " --preview "eza --tree --level=2 --color=always --icons {} | head -200"'
alias fzfg='echo "" | fzf_with_preview --disabled --ansi \
  --border-label=" ⟡  GREP  ⟡ " \
  --bind "change:reload: rg --line-number --no-heading --color=always --smart-case --hidden --follow --glob \"!.git/*\" --glob \"!node_modules/*\" --glob \"!Library/*\" {q} || true" \
  --delimiter ":" \
  --preview "bat --color=always --style=numbers,changes --highlight-line {2} {1} 2>/dev/null" \
  --preview-window "right:58%:wrap:border-left:+{2}-5" \
  --prompt "⌕  Search  " \
  --bind "ctrl-y:execute-silent(echo {} | wl-copy)"'
