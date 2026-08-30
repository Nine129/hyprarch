# ── CGGX Zsh ──────────────────────────────────────────
# Place at ~/.zshrc
source ~/zsh-defer/zsh-defer.plugin.zsh

# ── Plugin loader (houssamouhra) ───────────────────────
export ZSH_PLUGIN_DIR="$HOME/.zsh/plugins"
export ZSH_PATINA_PATH="$ZSH_PLUGIN_DIR/zsh-patina/target/release/zsh-patina"
# zsh-patina loader (Rust highlighter, 10x faster than zsh-syntax-highlighting, same CGGX styles)
# also handles AUR install at /usr/bin/zsh-patina (zsh-patina-bin / zsh-patina-git)
_zsh_patina_bin() {
  if [[ -x "$ZSH_PATINA_PATH" ]]; then print -r -- "$ZSH_PATINA_PATH"; return 0; fi
  if [[ -x "/usr/bin/zsh-patina" ]]; then print -r -- "/usr/bin/zsh-patina"; return 0; fi
  if (( $+commands[zsh-patina] )); then print -r -- "${commands[zsh-patina]}"; return 0; fi
  return 1
}
load-zsh-patina() {
  emulate -L zsh
  local bin; bin="$(_zsh_patina_bin 2>/dev/null)" || bin=""
  if [[ -n "$bin" && -x "$bin" ]]; then
    ZSH_PATINA_PATH="$bin"
    if ! typeset -f _zsh_patina_activate >/dev/null 2>&1; then
      _zsh_patina_activate() { unfunction _zsh_patina_activate; add-zsh-hook -d precmd _zsh_patina_activate; eval "$("$ZSH_PATINA_PATH" activate)"; }
      add-zsh-hook precmd _zsh_patina_activate
    fi
    return 0
  fi
  local dir="$ZSH_PLUGIN_DIR/zsh-patina"
  if [[ ! -d "$dir" ]]; then
    print -u2 -P "==> Installing %F{cyan}zsh-patina%f..."
    if ! git clone --depth=1 --quiet https://github.com/michel-kraemer/zsh-patina.git "$dir"; then rm -rf "$dir"; print -u2 -P "%F{red}✗ Failed zsh-patina%f"; return 1; fi
    print -u2 -P "%F{green}✓ Cloned zsh-patina%f"
  fi
  if [[ ! -x $ZSH_PATINA_PATH ]]; then
    if ! (( $+commands[cargo] )); then print -u2 -P "%F{red}zsh-patina needs cargo%f (rustup)"; return 1; fi
    print -u2 -P "==> Building %F{cyan}zsh-patina%f..."
    if ! (cd "$dir" && cargo build --release --quiet); then print -u2 -P "%F{red}✗ Build failed%f"; return 1; fi
    print -u2 -P "%F{green}✓ Built zsh-patina%f"
  fi
  if [[ ! -x $ZSH_PATINA_PATH ]]; then print -u2 -P "%F{red}not found $ZSH_PATINA_PATH%f"; return 1; fi
  if ! typeset -f _zsh_patina_activate >/dev/null 2>&1; then
    _zsh_patina_activate() { unfunction _zsh_patina_activate; add-zsh-hook -d precmd _zsh_patina_activate; eval "$("$ZSH_PATINA_PATH" activate)"; }
    add-zsh-hook precmd _zsh_patina_activate
  fi
}
plugin-path() {
  emulate -L zsh
  (($# >= 2)) || { print -u2 -P "%F{red}usage: plugin-path <owner> <repo> %f"; return 1; }
  local owner=$1
  local repo=$2
  local dir="$ZSH_PLUGIN_DIR/$repo"
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$ZSH_PLUGIN_DIR" || return 1
    print -u2 -P "==> Installing %F{cyan}$repo%f..."
    if ! git clone --depth=1 --quiet "https://github.com/$owner/$repo" "$dir"; then
      rm -rf "$dir"; print -u2 -P "%F{red}✗ Failed $repo%f"; return 1
    fi
    print -u2 -P "%F{green}✓ Installed $repo%f"
  fi
  local entry
  for entry in "$dir/$repo.plugin.zsh" "$dir"/*.plugin.zsh(N) "$dir/$repo.zsh"; do
    [[ -r $entry ]] && { print -r -- $entry; return 0; }
  done
  local -a candidates=("$dir"/*.zsh(N))
  if (( $#candidates == 1 )) && [[ -r $candidates[1] ]]; then print -r -- $candidates[1]; return 0; fi
  print -u2 -P "%F{red}Missing entry:%f $dir"; return 1
}
# ── Options ───────────────────────────────────────────
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt EXTENDED_GLOB
setopt NUMERIC_GLOB_SORT
setopt MENU_COMPLETE
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt INTERACTIVE_COMMENTS
setopt CORRECT
setopt CORRECT_ALL
# Let ^Q reach zle (else the TTY eats it as XON flow control)
setopt NO_FLOW_CONTROL
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
# Deduplicate PATH (keep first occurrence) — guards against add-ons re-exporting
typeset -U path cdpath fpath

# ── History ────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=$HISTSIZE

# ── Completion ─────────────────────────────────────────
zmodload zsh/complist
autoload -Uz bashcompinit && bashcompinit
# ensure completion plugins are present (auto-clone on first use)
plugin-path mattmc3 ez-compinit >/dev/null
plugin-path zsh-users zsh-completions >/dev/null
if [[ -r "$ZSH_PLUGIN_DIR/ez-compinit/ez-compinit.plugin.zsh" ]]; then
  source "$ZSH_PLUGIN_DIR/ez-compinit/ez-compinit.plugin.zsh"
else
  autoload -Uz compinit
  if [[ ! -f "${ZDOTDIR:-$HOME}/.zcompdump" ]]; then compinit; else compinit -C; fi
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}" 'ma=01;30;48;5;190'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "$HOME/.cache/zsh"
# ── CGGX completion styling: per-tag match colors, no headers ──
# group-name must be empty for tag-specific list-colors to apply (zshcompsys)
zstyle ':completion:*' group-name ''
# CGGX roles via kitty ANSI palette:
#   36 cyan #00e5ff = info/action (commands)   32 lime #c8ff00 = active (functions, pkgs)
#   33 orange #ff6b00 = attention (options)    35 purple #b48cff = premium (users, hosts)
#   31 red #ff2d55 = danger (signals, jobs)    37 silver #e8e8f0 = neutral (values)
# Files/dirs stay on LS_COLORS above.
zstyle ':completion:*:commands' list-colors '=*=32' 'ma=01;30;48;5;190'
zstyle ':completion:*:builtins' list-colors '=*=32' 'ma=01;30;48;5;190'
zstyle ':completion:*:functions' list-colors '=*=36' 'ma=01;30;48;5;190'
zstyle ':completion:*:aliases' list-colors '=*=178' 'ma=01;30;48;5;190'
zstyle ':completion:*:options' list-colors '=*=01;33' 'ma=01;30;48;5;190'
zstyle ':completion:*:users' list-colors '=*=35' 'ma=01;30;48;5;190'
zstyle ':completion:*:hosts' list-colors '=*=35' 'ma=01;30;48;5;190'
zstyle ':completion:*:keys' list-colors '=*=35' 'ma=01;30;48;5;190'
zstyle ':completion:*:signals' list-colors '=*=31' 'ma=01;30;48;5;190'
zstyle ':completion:*:jobs' list-colors '=*=31' 'ma=01;30;48;5;190'
zstyle ':completion:*:pids' list-colors '=*=31' 'ma=01;30;48;5;190'
zstyle ':completion:*:parameters' list-colors '=*=36' 'ma=01;30;48;5;190'
zstyle ':completion:*:environments' list-colors '=*=36' 'ma=01;30;48;5;190'
zstyle ':completion:*:variables' list-colors '=*=37' 'ma=01;30;48;5;190'
zstyle ':completion:*:values' list-colors '=*=37' 'ma=01;30;48;5;190'
zstyle ':completion:*:arguments' list-colors '=*=37' 'ma=01;30;48;5;190'
zstyle ':completion:*:packages' list-colors '=*=36' 'ma=01;30;48;5;190'
zstyle ':completion:*:services' list-colors '=*=33' 'ma=01;30;48;5;190'
zstyle ':completion:*:mounts' list-colors '=*=32' 'ma=01;30;48;5;190'
zstyle ':completion:*:devices' list-colors '=*=32' 'ma=01;30;48;5;190'

# ── Keybindings ───────────────────────────────────────
bindkey -v  # vi mode
export KEYTIMEOUT=1
bindkey '^R' history-incremental-search-backward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^W' kill-whole-line
bindkey '^H' backward-kill-word
bindkey '^Z' undo
bindkey '^X^Z' suspend
bindkey -M viins '^[[1;5D' backward-word
bindkey -M viins '^[[1;5C' forward-word
# ── Edit command line in $EDITOR (Esc then v) ──────
if [[ -o interactive ]]; then
  if [[ -z ${widgets[edit-command-line]} ]]; then
    edit-command-line() {
      local tmp="${TMPPREFIX:-/tmp/zsh}ecmd.$$"
      print -r -- "$BUFFER" > "$tmp"
      ${VISUAL:-${EDITOR:-vi}} "$tmp" < /dev/tty
      BUFFER="$(<"$tmp")"
      CURSOR=$#BUFFER
      rm -f "$tmp"
    }
    zle -N edit-command-line
  fi
  bindkey -M vicmd v edit-command-line
fi
bindkey '^U' kill-whole-line
bindkey '^Q' clear-screen
bindkey '^L' clear-screen

# ── Dir colors ────────────────────────────────────────
# CGGX LS_COLORS — 256-color codes matched to yazi theme
# 45=cyan, 129=hot-purple, 141=lavender, 178=amber, 190=lime, 197=red, 202=orange, 242=muted, 255=silver
export LS_COLORS="di=00;38;5;45:fi=00;38;5;255:ln=00;38;5;197:ex=00;38;5;45:*.md=00;38;5;190:*.txt=00;38;5;190:*.gz=00;38;5;45:*.zip=00;38;5;45:*.tar=00;38;5;45:*.zst=00;38;5;45:*.png=00;38;5;129:*.jpg=00;38;5;129:*.mp4=00;38;5;129:*.mp3=00;38;5;197:*.lua=00;38;5;202:*.rs=00;38;5;178:*.toml=00;38;5;202:*.json=00;38;5;202:*.yaml=00;38;5;202:*.html=00;38;5;202:*.css=00;38;5;202:*.js=00;38;5;178:*.ts=00;38;5;178:*.py=00;38;5;178:*.go=00;38;5;178:*.c=00;38;5;178:*.h=00;38;5;178:*.cpp=00;38;5;178:*.cfg=00;38;5;242:*.conf=00;38;5;242:*.rasi=00;38;5;202:*.sh=00;38;5;141:*.bash=00;38;5;141:*.zsh=00;38;5;141:*.ttf=00;38;5;255:*.otf=00;38;5;255:*.pdf=00;38;5;190:*.log=00;38;5;242"

# ── Aliases ────────────────────────────────────────────
# System
alias free='free -h'
# Confirm before overwriting
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Hyprland
alias hrc='hyprctl reload config'
alias hw='hyprctl workspaces'
alias hm='hyprctl monitors'
alias hk='hyprctl keyword'
alias hd='hyprctl dispatch'
alias hb='hyprctl hyprpaper'

# Waybar
alias wbr='killall waybar && waybar &> /dev/null &disown'

# Kitty
alias k='kitty'
alias kssh='kitty +kitten ssh'

# Neovim
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# Git
alias git='nocorrect git'
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph'
alias gs='git status'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gpl='git pull'
alias gf='git fetch'

# Systemd
alias sc='systemctl'
alias scu='systemctl --user'
alias jc='journalctl'
alias jcu='journalctl --user'

# Yay (AUR helper)
alias y='yay'
alias ys='yay -S'
alias yr='yay -Rns'
alias yq='yay -Q'
alias yu='yay -Syu'
alias rg='rg --smart-case'
# Gparted
alias gparted='sudo -E gparted'
# ── Autostart (first shell only) ──────────────────────
# SHLVL=1 means this is the top-level shell in a new terminal session
[[ "$SHLVL" -eq 1 ]] && fastfetch

# pnpm
export PNPM_HOME="/home/nine/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# ── Starship prompt ───────────────────────────────────
# Cache init script so we don't run `starship` on every shell start
local _starship_cache="$HOME/.cache/starship-init.zsh"
if [[ ! -f "$_starship_cache" ]] || [[ "$(command -v starship)" -nt "$_starship_cache" ]]; then
  starship init zsh >| "$_starship_cache"
fi
source "$_starship_cache"
unset _starship_cache

# ── Transient prompt (zsh) ────────────────────────────
# Starship has no native zsh transient prompt (docs cover fish/bash/pwsh/cmd
# only), so collapse each accepted line to the character-only profile via the
# zsh-transient-prompt widget plugin (cloned by apply.sh). Full prompt still
# renders on the next line; only past prompts shrink to "❯".
if [[ -r "$ZSH_PLUGIN_DIR/zsh-transient-prompt/transient-prompt.plugin.zsh" ]]; then
  typeset -g TRANSIENT_PROMPT_PROMPT="$PROMPT"
  typeset -g TRANSIENT_PROMPT_RPROMPT="$RPROMPT"
  typeset -g TRANSIENT_PROMPT_TRANSIENT_PROMPT='$('/usr/bin/starship' prompt --profile transient --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="${STARSHIP_CMD_STATUS:-}" --pipestatus="${STARSHIP_PIPE_STATUS[*]:-}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="${STARSHIP_JOBS_COUNT:-0}")'
  typeset -g TRANSIENT_PROMPT_TRANSIENT_RPROMPT=''
  source "$ZSH_PLUGIN_DIR/zsh-transient-prompt/transient-prompt.plugin.zsh"
fi

# ── Zoxide (smart cd) ───────────────────────────────
# Cache init script so we don't run `zoxide` on every shell start
local _zoxide_cache="$HOME/.cache/zoxide-init.zsh"
if [[ ! -f "$_zoxide_cache" ]] || [[ "$(command -v zoxide)" -nt "$_zoxide_cache" ]]; then
  zoxide init zsh >| "$_zoxide_cache"
fi
source "$_zoxide_cache"
unset _zoxide_cache
alias cd="z"

# FastFetch
alias ff="fastfetch"
# xdg-open
 open() { xdg-open "$@" > /dev/null 2>&1 & disown }

# reload audio
alias rd="systemctl --user restart pipewire pipewire-pulse wireplumber"
# Eza
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --git --group-directories-first"
# Dust
alias du="dust"
# duf
alias df="duf"
# fd
alias find="fd"
# tty clock
alias clock="tty-clock -b -s -S -c"
# others i will stop tagging 
alias path='echo $PATH | tr ":" "\n"'
alias reload='source ~/.zshrc'
alias mkdir='mkdir -p'
alias lsgrub="grep -oP \"(?<=menuentry ')[^']+\" /boot/grub/grub.cfg"
alias zathura="zathura --fork"

function z() {
    __zoxide_z "$@" && eza --icons --group-directories-first
}
bat() {
    local has_md=0
    for f in "$@"; do
        [[ "$f" == *.md ]] && has_md=1 && break
    done
    if [[ $has_md -eq 1 ]]; then
        mdterm "$@"
    else
        command bat "$@"
    fi
}




# Local bin overrides (fzf wrapper for Yazi etc.)
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# Pi
case ":$PATH:" in
  *":/home/nine/.local/share/pi-node/node-v22.22.3-linux-x64/bin:"*) ;;
  *) export PATH="/home/nine/.local/share/pi-node/node-v22.22.3-linux-x64/bin:$PATH" ;;
esac
# ── Zsh plugins (deferred — runs after first prompt) ──
_cggx_deferred_plugins() {
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#9a9ab0"
  # clear suggestion on accept + fzf to prevent ghost text (time → time zsh...)
  ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(fzf-completion accept-line accept-and-hold accept-and-infer-next-history complete-word expand-or-complete menu-complete accept-and-menu-complete)

  # fzf environment/config; keybindings are sourced synchronously above
  [[ -f ~/.config/fzf/fzf.zsh ]] && source ~/.config/fzf/fzf.zsh

  # perf: ignore all widgets except those that must trigger autosuggest
  # keep accept-line etc. so `time` → enter clears `postdisplay`
  local -a _as_keep_widgets=(
    fzf-completion
    self-insert self-insert-unmeta quoted-insert vi-quoted-insert
    backward-delete-char delete-char
    kill-line kill-whole-line backward-kill-word backward-kill-line
    kill-word kill-region
    accept-line accept-and-hold accept-and-infer-next-history
    accept-line-and-down-history
    forward-char backward-char forward-word backward-word
    vi-forward-char vi-backward-char vi-forward-word vi-backward-word
    vi-forward-word-end vi-backward-word-end
    vi-forward-blank-word vi-backward-blank-word
    vi-backward-delete-char vi-delete-char vi-delete
    vi-change vi-change-eol vi-change-whole-line vi-substitute
    vi-replace vi-replace-chars vi-put-after vi-put-before
    clear-screen magic-space
    complete-word expand-or-complete menu-complete accept-and-menu-complete
    menu-expand complete-word-expand
  )
  local _w
  ZSH_AUTOSUGGEST_IGNORE_WIDGETS=()
  for _w in ${(k)widgets}; do
    (( $_as_keep_widgets[(Ie)$_w] )) || ZSH_AUTOSUGGEST_IGNORE_WIDGETS+=($_w)
  done
  unset _as_keep_widgets _w
  # safety: ensure accept-line always clears if widget list was incomplete
  (( ${ZSH_AUTOSUGGEST_CLEAR_WIDGETS[(Ie)accept-line]} )) || ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(accept-line)

  # zsh-bd (Tarrasch) — sourced with aliases off so its internal `cd`
  # doesn't expand to the `cd`→`z` alias; wrapped to list after a jump
  if [[ -d "$HOME/.zsh/plugins/zsh-bd" ]]; then
    () {
      setopt localoptions no_aliases
      source "$HOME/.zsh/plugins/zsh-bd/bd.zsh"
      functions[bd_plugin]=$functions[bd]
      unfunction bd
      bd() {
        local before="$PWD"
        bd_plugin "$@" || return $?
        [[ "$PWD" != "$before" ]] && command eza --icons --group-directories-first "$PWD"
      }
    }
  fi

  if [[ -d "$HOME/.zsh/plugins/zsh-autosuggestions" ]]; then
    source "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
  fi

  if [[ -d "$HOME/.zsh/plugins/zsh-history-substring-search" ]]; then
    # Rolling highlight: orange → lime → cyan → purple (no red), black text
    _cggx_history_colors=( '#ff6b00' '#c8ff00' '#00e5ff' '#b48cff' )
    _cggx_history_color_idx=0
    source "$HOME/.zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"

    # Rotate the highlight bg on each ↑/↓ press, then run the real search
    _cggx_history_rotate() {
      (( _cggx_history_color_idx = _cggx_history_color_idx % ${#_cggx_history_colors} + 1 ))
      local _c="${_cggx_history_colors[_cggx_history_color_idx]}"
      HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="fg=#000000,bg=${_c},bold"
      HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND="fg=#000000,bg=${_c},bold"
    }
    function _cggx-history-substring-search-up() {
      _cggx_history_rotate; zle history-substring-search-up
    }
    function _cggx-history-substring-search-down() {
      _cggx_history_rotate; zle history-substring-search-down
    }
    zle -N _cggx-history-substring-search-up
    zle -N _cggx-history-substring-search-down
    # ↑/↓ page history matching the typed substring (insert mode only —
    # normal-mode arrows keep their default behavior)
    bindkey -M viins '^[[A' _cggx-history-substring-search-up
    bindkey -M viins '^[[B' _cggx-history-substring-search-down
  fi

  # Skip highlighting for very long lines (performance guard)
  ZSH_HIGHLIGHT_MAXLENGTH=512

  # Prefer zsh-patina (Rust, ~10x faster) if built / AUR, else fallback to zsh-syntax-highlighting — same CGGX styles
  local _patina_bin; _patina_bin="$(_zsh_patina_bin 2>/dev/null)" || _patina_bin=""
  if [[ -n "$_patina_bin" && -x "$_patina_bin" ]]; then
    ZSH_PATINA_PATH="$_patina_bin"
    load-zsh-patina
    unset _patina_bin
  elif [[ -d "$HOME/.zsh/plugins/zsh-syntax-highlighting" ]]; then
    unset _patina_bin
    source "$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

    # ── CGGX syntax highlighting ─────────────────────────
    # Terminal palette: green = #c8ff00 (lime), white = #e8e8f0 (silver)
    #                   yellow = #ff6b00 (orange), cyan = #00e5ff
    #                   magenta = #b48cff (purple), red = #ff2d55
    #
    # Commands & executables
    ZSH_HIGHLIGHT_STYLES[command]="fg=green,bold"
    ZSH_HIGHLIGHT_STYLES[builtin]="fg=green"
    ZSH_HIGHLIGHT_STYLES[alias]="fg=green"
    ZSH_HIGHLIGHT_STYLES[suffix-alias]="fg=green,underline"
    ZSH_HIGHLIGHT_STYLES[function]="fg=green"
    ZSH_HIGHLIGHT_STYLES[precommand]="fg=green,underline"
    ZSH_HIGHLIGHT_STYLES[hashed]="fg=green"
    ZSH_HIGHLIGHT_STYLES[arg0]="fg=green"
    ZSH_HIGHLIGHT_STYLES[global-alias]="fg=green"

    # Paths
    ZSH_HIGHLIGHT_STYLES[path]="fg=white,underline"
    ZSH_HIGHLIGHT_STYLES[path_prefix]="none"
    ZSH_HIGHLIGHT_STYLES[path_pathseparator]="fg=white"
    ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]="fg=white"

    # Strings & quotes
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=yellow"
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=yellow"
    ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=yellow"
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument]="none"
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]="fg=magenta"
    ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]="fg=cyan"
    ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]="fg=cyan"
    ZSH_HIGHLIGHT_STYLES[rc-quote]="fg=cyan"

    # Options & flags
    ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=white"
    ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=white,bold"

    # Operators & redirections
    ZSH_HIGHLIGHT_STYLES[redirection]="fg=yellow"
    ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=red"

    # Reserved words & control flow
    ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=yellow,bold"

    # Assignments & expansions
    ZSH_HIGHLIGHT_STYLES[assign]="fg=white"
    ZSH_HIGHLIGHT_STYLES[globbing]="fg=magenta"
    ZSH_HIGHLIGHT_STYLES[history-expansion]="fg=magenta"
    ZSH_HIGHLIGHT_STYLES[process-substitution]="none"
    ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]="fg=magenta"
    ZSH_HIGHLIGHT_STYLES[command-substitution]="none"
    ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]="fg=magenta"

    # Misc
    ZSH_HIGHLIGHT_STYLES[comment]="fg=#6a6a80"
    ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=red,bold"
    ZSH_HIGHLIGHT_STYLES[autodirectory]="fg=green,underline"
    ZSH_HIGHLIGHT_STYLES[named-fd]="fg=cyan"
    ZSH_HIGHLIGHT_STYLES[numeric-fd]="fg=yellow"
    ZSH_HIGHLIGHT_STYLES[default]="none"

    # Brackets
    ZSH_HIGHLIGHT_STYLES[bracket-level-1]="fg=cyan,bold"
    ZSH_HIGHLIGHT_STYLES[bracket-level-2]="fg=green,bold"
    ZSH_HIGHLIGHT_STYLES[bracket-level-3]="fg=magenta,bold"
    ZSH_HIGHLIGHT_STYLES[bracket-level-4]="fg=yellow,bold"
    ZSH_HIGHLIGHT_STYLES[bracket-level-5]="fg=white,bold"
    ZSH_HIGHLIGHT_STYLES[bracket-error]="fg=red,bold"

    # Cursor
    ZSH_HIGHLIGHT_STYLES[cursor]="standout"
    ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]="standout"
  fi

  # ── Extra completions + colored man (houssamouhra, no UX change) ──
  [[ -r "$ZSH_PLUGIN_DIR/zsh-completions/zsh-completions.plugin.zsh" ]] && source "$ZSH_PLUGIN_DIR/zsh-completions/zsh-completions.plugin.zsh"
  plugin-path houssamouhra colored-man-pages >/dev/null
  [[ -r "$ZSH_PLUGIN_DIR/colored-man-pages/colored-man-pages.plugin.zsh" ]] && source "$ZSH_PLUGIN_DIR/colored-man-pages/colored-man-pages.plugin.zsh"
}
# batch non-critical defers (single schedule)
zsh-defer _cggx_deferred_plugins

# ── Lazy fzf — only init on first Ctrl+R/T or Alt+C (houssamouhra)
# keeps same CGGX FZF_DEFAULT_OPTS from ~/.config/fzf/fzf.zsh, but defers `fzf --zsh` widget creation
_fzf_init() {
  emulate -L zsh
  (( $+commands[fzf] )) || return
  local init; init="$(fzf --zsh)" || return
  eval "$init" || return
  unfunction _fzf_init
}
_fzf_history_lazy() { _fzf_init; zle fzf-history-widget; }
_fzf_file_lazy() { _fzf_init; zle fzf-file-widget; }
_fzf_cd_lazy() { _fzf_init; zle fzf-cd-widget; }
zle -N _fzf_history_lazy; bindkey '^R' _fzf_history_lazy
zle -N _fzf_file_lazy; bindkey '^T' _fzf_file_lazy
zle -N _fzf_cd_lazy; bindkey '^[c' _fzf_cd_lazy

 qr() {
    local result
    result=$(grim -g "$(slurp)" - | zbarimg --raw -q -)
    if [ -n "$result" ]; then
        notify-send "QR Scanned" "$result"
        xdg-open "$result"
    else
        notify-send "QR Scan" "No QR code found"
    fi
}
function pacs {
  local repo_cmd="pacman -Sl | awk '{print \$2 (\$4==\"\" ? \"\" : \" *\")}'"
  local aur_cmd="yay -Sl aur | awk '{print \$2 (\$4==\"\" ? \"\" : \" *\")}'"
  local inst_cmd="yay -Qq | awk '{print \$1 \" *\"}'"
  local cmd
  cmd=$(pacman -Sl | awk '{print $2 ($4=="" ? "" : " *")}' | fzf \
    --bind 'enter:accept' \
    --border-label ' Packages ' \
    --prompt 'repo> ' \
    --header 'Install/Uninstall packages. CTRL+(Repo/AUR/Installed)' \
    --bind "ctrl-p:change-prompt(repo> )+reload($repo_cmd)" \
    --bind "ctrl-a:change-prompt(aur> )+reload($aur_cmd)" \
    --bind "ctrl-i:change-prompt(inst> )+reload($inst_cmd)" \
    --multi \
    --preview 'yay -Qil {1} | bat -fpl yml 2>/dev/null'
  )

  [[ -z "$cmd" ]] && return

  local install_list remove_list
  install_list=$(echo "$cmd" | awk 'NF==1 {print $1}' | tr '\n' ' ')
  remove_list=$(echo "$cmd" | awk 'NF==2 {print $1}' | tr '\n' ' ')

  if [[ -n "$install_list" && -n "$remove_list" ]]; then
    print -z "yay -S $install_list && yay -Rns $remove_list"
  elif [[ -n "$remove_list" ]]; then
    print -z "yay -Rns $remove_list"
  else
    print -z "yay -S $install_list"
  fi
}

extract() {
    [[ $# -eq 0 ]] && { echo "usage: extract <file> [file2 ...]"; return 1; }

    local status=0
    for f in "$@"; do
        if [[ ! -f "$f" ]]; then
            echo "✗ not a file: $f"
            status=1
            continue
        fi

        local lower
        lower=$(printf '%s' "$f" | tr '[:upper:]' '[:lower:]')
        local tool=""
        local pkg=""
        local cmd=()

        case "$lower" in
            *.tar.zst)        tool=unzstd;  pkg=zstd;    cmd=(tar --use-compress-program=unzstd -xf "$f") ;;
            *.zst)            tool=zstd;    pkg=zstd;    cmd=(zstd -d "$f") ;;
            *.tar.gz|*.tgz)   tool=tar;     pkg=tar;     cmd=(tar xzf "$f") ;;
            *.tar.bz2|*.tbz2) tool=tar;     pkg=tar;     cmd=(tar xjf "$f") ;;
            *.tar.xz|*.txz)   tool=tar;     pkg=tar;     cmd=(tar xJf "$f") ;;
            *.tar.lz4)        tool=lz4;     pkg=lz4;     cmd=(tar --use-compress-program=lz4 -xf "$f") ;;
            *.tar)            tool=tar;     pkg=tar;     cmd=(tar xf "$f") ;;
            *.zip)            tool=unzip;   pkg=unzip;   cmd=(unzip -o "$f") ;;
            *.rar)            tool=unrar;   pkg=unrar;   cmd=(unrar x -o+ "$f") ;;
            *.7z)             tool=7z;      pkg=p7zip;   cmd=(7z x -y "$f") ;;
            *.gz)             tool=gunzip;  pkg=gzip;    cmd=(gunzip -k "$f") ;;
            *.bz2)            tool=bunzip2; pkg=bzip2;   cmd=(bunzip2 -k "$f") ;;
            *.xz)             tool=unxz;    pkg=xz;      cmd=(unxz -k "$f") ;;
            *.lz4)            tool=lz4;     pkg=lz4;     cmd=(lz4 -d "$f") ;;
            *) echo "✗ unsupported: $f"; status=1; continue ;;
        esac

        if ! command -v "$tool" &>/dev/null; then
            echo "✗ missing binary '$tool' for: $f (install it: pacman -S $pkg)"
            status=1
            continue
        fi

        if [[ "$lower" == *.tar.* || "$lower" == *.tar ]] && ! tar tf "$f" &>/dev/null; then
            echo "✗ archive appears corrupted or unreadable: $f"
            status=1
            continue
        fi

        if "${cmd[@]}"; then
            echo "✓ extracted: $f"
        else
            echo "✗ extraction FAILED: $f (corrupted archive or disk full — check exit code)"
            status=1
        fi
    done
    return $status
}
alias inxia='inxi -xxxez -dfiJlmoput'

. "$HOME/.local/share/../bin/env"

# Compile .zshrc to bytecode for faster next startup
if [[ ! -f "$HOME/.zshrc.zwc" ]] || [[ "$HOME/.zshrc" -nt "$HOME/.zshrc.zwc" ]]; then
  zcompile "$HOME/.zshrc"
fi
eval "$(direnv hook zsh)"
# silence + fast-path: only run direnv if .envrc/.env in parent chain (DIRENV_LOG_FORMAT ignored in 2.37)
# still runs when leaving a direnv dir (DIRENV_DIR set) to allow unload
_direnv_hook() {
  if [[ -z "$DIRENV_DIR" ]]; then
    local d="$PWD"
    while true; do
      [[ -e "$d/.envrc" || -e "$d/.env" ]] && break
      [[ "$d" == "/" ]] && return
      d="${d:h}"
    done
  fi
  trap -- '' SIGINT
  eval "$("/usr/bin/direnv" export zsh 2>/dev/null)"
  trap - SIGINT
}

# Cache brew shellenv like starship/zoxide (was ~15-30ms every start)
local _brew_cache="$HOME/.cache/brew-init.zsh"
if [[ ! -f "$_brew_cache" ]] || [[ "/home/linuxbrew/.linuxbrew/bin/brew" -nt "$_brew_cache" ]]; then
  /home/linuxbrew/.linuxbrew/bin/brew shellenv zsh >| "$_brew_cache"
fi
source "$_brew_cache"
unset _brew_cache
