# ── CGGX Zsh — Environment ────────────────────────────
# Place at ~/.zshenv

# ── Path ──────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:$HOME/.local/share/pi-node/node-v22.22.3-linux-x64/bin:$PATH"

# ── Default editor ────────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"

# ── Pager ─────────────────────────────────────────────
export PAGER="less"
export LESS="-RFi"
export LESSOPEN="| lesspipe %s"

# ── Terminal ──────────────────────────────────────────
# Kitty sets TERM=xterm-kitty automatically — do NOT override

# ── Language ──────────────────────────────────────────
# en_US.UTF-8 not generated on this system; use C.UTF-8 instead
export LANG="C.UTF-8"
export LC_ALL="C.UTF-8"

# ── XDG paths ─────────────────────────────────────────
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# ── Hyprland / Wayland ────────────────────────────────
export XDG_CURRENT_DESKTOP="Hyprland"
export XDG_SESSION_TYPE="wayland"
export XDG_SESSION_DESKTOP="Hyprland"
export GDK_BACKEND="wayland"
export QT_QPA_PLATFORM="wayland;xcb"
export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
export SDL_VIDEODRIVER="wayland"
export _JAVA_AWT_WM_NONREPARENTING="1"
export MOZ_ENABLE_WAYLAND="1"
# Intel GPU only — no NVIDIA workarounds

# ── Cursor ────────────────────────────────────────────
export XCURSOR_THEME="Bibata-Modern-Ice"
export XCURSOR_SIZE="24"
