# ── CGGX Zsh ──────────────────────────────────────────
# Place at ~/.zshrc
source ~/zsh-defer/zsh-defer.plugin.zsh
# ── Options ───────────────────────────────────────────
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt EXTENDED_GLOB
setopt NUMERIC_GLOB_SORT
setopt MENU_COMPLETE
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt CORRECT
setopt CORRECT_ALL
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
# Deduplicate PATH (keep first occurrence) — guards against add-ons re-exporting
typeset -U path cdpath fpath

# ── History ────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

# ── Completion ─────────────────────────────────────────
autoload -Uz compinit
if [[ ! -f "${ZDOTDIR:-$HOME}/.zcompdump" ]]; then
  compinit
else
  compinit -C
fi
autoload -Uz bashcompinit && bashcompinit

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "$HOME/.cache/zsh"

# ── Keybindings ───────────────────────────────────────
bindkey -v  # vi mode
bindkey '^R' history-incremental-search-backward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^W' backward-kill-word
bindkey '^U' kill-whole-line
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
if [[ -z "$ZSH_SESSION" ]]; then
  export ZSH_SESSION="started"
fi

# pnpm
export PNPM_HOME="/home/nine/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# ── Starship prompt ───────────────────────────────────
eval "$(starship init zsh)"

# ── Zoxide (smart cd) ───────────────────────────────
eval "$(zoxide init zsh)"
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
zsh-defer -c '
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#9a9ab0"

  if [[ -d "$HOME/.zsh/plugins/zsh-autosuggestions" ]]; then
    source "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
  fi

  if [[ -d "$HOME/.zsh/plugins/zsh-syntax-highlighting" ]]; then
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
    ZSH_HIGHLIGHT_STYLES[comment]="fg=white"
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
'
export NVM_DIR="$HOME/.config/nvm"
zsh-defer '. "$NVM_DIR/nvm.sh"'
zsh-defer '. "$NVM_DIR/bash_completion"'
[[ -f ~/.config/fzf/fzf.zsh ]] && source ~/.config/fzf/fzf.zsh

source <(fzf --zsh)

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
fastfetch
alias inxia='inxi -xxxez -dfiJlmoput'
