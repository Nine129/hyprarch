# CGGX FZF wrapper — injects the same opts as fzf.zsh for non-zsh contexts (Yazi etc.)
# Must stay in sync with ~/.config/fzf/fzf.zsh

# ── Colors ──
_CGGX_FZF_COLORS="--color=bg:-1,bg+:-1,gutter:#151518 \
--color=fg:#ffffff,fg+:#c8ff00,hl:#c8ff00,hl+:#00e5ff \
--color=border:#c8ff00,separator:#3d1a00 \
--color=spinner:#00e5ff,info:#00e5ff,header:#FF6B00 \
--color=pointer:#ff2d55,marker:#c8ff00,prompt:#FF6B00,scrollbar:#FF6B00 \
--color=label:#c8ff00,preview-label:#00e5ff,query:#ffffff"

# ── Base options — matches _FZF_BASE_OPTS in fzf.zsh ──
_CGGX_FZF_BASE="\
  --multi \
  --layout=reverse \
  --height=88% \
  --border=rounded \
  --border-label=' ⟡  FUZZY FINDER  ⟡ ' \
  --border-label-pos=center \
  --margin=1,2 \
  --padding=0,2 \
  --preview=~/.config/fzf/preview.sh\ {} \
  --preview-window=right:58%:wrap:border-left:hidden \
  --info=right \
  --separator='╌' \
  --scrollbar='▏' \
  --prompt='⌕  ' \
  --pointer='❯' \
  --marker='◆' \
  --bind='ctrl-/:toggle-preview' \
  --bind='ctrl-u:preview-half-page-up' \
  --bind='ctrl-d:preview-half-page-down' \
  --bind='ctrl-f:preview-page-down' \
  --bind='ctrl-b:preview-page-up' \
  --bind='alt-i:reload(fd --type f --hidden --follow --exclude .git --extension jpg --extension jpeg --extension png --extension gif --extension webp --extension bmp --extension tiff --extension svg)+change-border-label( ⟡  IMAGES  ⟡ )' \
  --bind='alt-m:reload(fd --type f --hidden --follow --exclude .git --extension mp4 --extension mov --extension mkv --extension webm --extension avi --extension m4v --extension flv --extension wmv)+change-border-label( ⟡  VIDEOS  ⟡ )' \
  --bind='alt-a:reload(fd --type f --hidden --follow --exclude .git)+change-border-label( ⟡  ALL FILES  ⟡ )' \
  --bind='tab:toggle+down' \
  --bind='btab:toggle+up' \
  --bind='ctrl-a:select-all' \
  --bind='ctrl-x:deselect-all' \
  --bind='shift-up:preview-up' \
  --bind='shift-down:preview-down' \
  --bind='esc:abort' \
  --header='  CTRL-Y copy path  |  ESC quit  ' \
  --header-first"

# ── Copy path bind ──
_CGGX_FZF_COPY_BIND="--bind='ctrl-y:execute-silent(printf \"%s\\n\" {+} | wl-copy)'"
# Note: enter:execute(open_file.sh) NOT included here — Yazi handles Enter itself.
# Generic header works for both Yazi's file picker and zoxide.

export FZF_DEFAULT_OPTS="$_CGGX_FZF_BASE $_CGGX_FZF_COPY_BIND $_CGGX_FZF_COLORS"

