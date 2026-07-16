#!/bin/bash
# ── CGGX Rice — Apply Configs ──────────────────────────
# One-shot deploy: takes a fresh Arch + packages install to running CGGX desktop.
#
# What it does:
#   1. Copies all configs to ~/.config/, fixes hardcoded paths
#   2. Symlinks shell dotfiles (.zshenv, .zshrc)
#   3. Deploys wallpaper, desktop entries, mime associations
#   4. Sets up fontconfig, bat cache
#   5. Enables systemd user services
#   6. (Optional) System services, sudoers, chsh
#
# Usage: ./scripts/apply.sh [options]
#   --dry-run    Print what would be done, make no changes
#   --diff       Show differences between current configs and repo
#   --no-system  Skip system-level changes (sudoers, system services, chsh)
#   --no-user    Skip systemd --user enable operations
#   --backup     Backup existing configs before overwriting
#   --help       Show this help

set -euo pipefail

# ── Colors ─────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
MUTED='\033[0;90m'
NC='\033[0m' # No Color

ok()   { echo -e " ${GREEN}✓${NC} $1"; }
warn() { echo -e " ${YELLOW}⚠${NC} $1"; }
fail() { echo -e " ${RED}✗${NC} $1"; }
info() { echo -e " ${CYAN}→${NC} $1"; }
muted(){ echo -e "  ${MUTED}$1${NC}"; }


usage() {
  cat <<'EOF'
CGGX Rice — Apply Configs

One-shot deploy: takes a fresh Arch + packages install to running CGGX desktop.

Phases:  config files → shell dotfiles → XDG assets → fonts and caches →
         systemd user services → system-level changes

Usage: ./scripts/apply.sh [flags]

Flags:
  --dry-run    Print what would be done, make no changes
  --diff       Show differences between current configs and repo, then exit
  --no-system  Skip system-level changes (sudoers, system services, chsh)
  --no-user    Skip systemd --user enable operations
  --backup     Backup existing ~/.config/* before overwriting
  --help       Show this message
EOF
}
# ── Arg parsing ────────────────────────────────────────
DRY_RUN=false
DIFF_ONLY=false
NO_SYSTEM=false
NO_USER=false
DO_BACKUP=false

# $HOME is used as sed replacement text. Must not contain
# delimiters (|), backreferences (&), or escapes (\).
case "$HOME" in
  *\|*|*\\*|*\&*)
    fail "HOME path '${HOME}' contains special characters that would corrupt sed substitution."
    fail "Cannot safely deploy configs. Fix HOME path and re-run."
    exit 1
    ;;
esac

for arg in "$@"; do

  case "$arg" in
    --dry-run)  DRY_RUN=true ;;
    --diff)     DIFF_ONLY=true ;;
    --no-system) NO_SYSTEM=true ;;
    --no-user)  NO_USER=true ;;
    --backup)   DO_BACKUP=true ;;
    --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      echo "Usage: $0 [--dry-run] [--diff] [--no-system] [--no-user] [--backup] [--help]"
      exit 1
      ;;
  esac
done


# ── Paths ──────────────────────────────────────────────
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_SRC="$REPO_DIR/configs"
SCRIPTS_SRC="$REPO_DIR/scripts"
WALLPAPER_SRC="$REPO_DIR/wallpapers"
APPLICATIONS_SRC="$REPO_DIR/applications"
DOWNLOADS_SORTER_SRC="$REPO_DIR/downloads-sorter"

if [ "$DIFF_ONLY" = true ]; then
  if [ ! -d "$HOME/.config" ]; then
    echo "No ~/.config exists yet — nothing to diff against."
    exit 1
  fi
  echo "=== Configs different between repo and ~/.config ==="
  diff -rq "$CONFIG_SRC" "$HOME/.config" 2>/dev/null || true
  echo ""
  echo "=== Only in repo (not yet deployed) ==="
  diff -rq "$CONFIG_SRC" "$HOME/.config" 2>/dev/null \
    | grep "^Only in $CONFIG_SRC" || echo "(none — all deployed)"
  exit 0
fi

echo "══════════════════════════════════════════════════"
echo "  CGGX Rice — Apply Configs"
echo "  Repo: $REPO_DIR"
echo "  User: $USER  Home: $HOME"
echo "══════════════════════════════════════════════════"
echo ""

# ── Run helper ─────────────────────────────────────────
run() {
  if [ "$DRY_RUN" = true ]; then
    muted "[DRY-RUN] $*"
  else
    "$@"
  fi
}

# ── Checks ─────────────────────────────────────────────
if [ "$DRY_RUN" = false ] && [ "$HOME" = "/home/nine" ]; then
  warn "Running as user 'nine' — paths will be substituted for /home/nine"
  warn "    This is correct if you ARE user 'nine'."
  echo ""
fi

# Verify repo structure
if [ ! -d "$CONFIG_SRC/hypr" ]; then
  fail "Can't find configs/hypr/ — run this script from the hyprarch repo root!"
  exit 1
fi

# ───────────────────────────────────────────────────────
#  Pre-Apply: Backup
# ───────────────────────────────────────────────────────
BACKUP_DIR=""
if [ "$DO_BACKUP" = true ] && [ "$DRY_RUN" = false ]; then
  BACKUP_DIR="$HOME/.config/backups/hyprarch-$(date +%Y%m%d-%H%M%S)"
  info "Backing up existing ~/.config/* to $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
  for dir in "$CONFIG_SRC"/*/; do
    name="$(basename "$dir")"
    if [ -d "$HOME/.config/$name" ]; then
      cp -r "$HOME/.config/$name" "$BACKUP_DIR/"
    fi
  done
  # Also back up .zshenv / .zshrc
  for f in .zshenv .zshrc .zprofile; do
    [ -f "$HOME/$f" ] && cp "$HOME/$f" "$BACKUP_DIR/"
  done
  ok "Backed up to $BACKUP_DIR"
fi

# ───────────────────────────────────────────────────────
#  Phase 1: Deploy config files
# ───────────────────────────────────────────────────────

# Strip stale systemd wants/ dirs before copy — cp -r carries over broken
# absolute symlinks from the repo that point to /home/nine/.config/... on a
# different system. Phase 5's enable commands recreate them correctly.
run rm -rf "$HOME/.config/systemd/user/default.target.wants" \
            "$HOME/.config/systemd/user/graphical-session.target.wants" 2>/dev/null || true

echo ""
echo "── Phase 1: Config Files ────────────────────────"

# Copy everything from configs/ to ~/.config/
# (shell/ and atuin/ excluded — not used or handled separately)
info "Copying configs/* to ~/.config/ ..."
run mkdir -p "$HOME/.config"
for item in "$CONFIG_SRC"/*/ "$CONFIG_SRC"/starship.toml; do
  name="$(basename "$item")"
  case "$name" in shell|atuin) continue ;; esac
  target="$HOME/.config/$name"
  run cp -r "$item" "$target" 2>/dev/null || true
done
ok "Configs copied"

# ── Path substitution ────────────────────────────────────
# Fix hardcoded /home/nine paths in copied configs.
# grep flags: -r = recursive (no symlinks), --binary-files=without-match
# to skip pyc/so.  || true guards against set -e when no matches.
info "Fixing hardcoded paths in configs ..."
if [ "$DRY_RUN" = false ]; then
  # /home/nine/hyprarch/configs/ → $HOME/.config/ (paths referencing the repo configs dir)
  grep -rl --binary-files=without-match "/home/nine/hyprarch/configs/" "$HOME/.config/" 2>/dev/null \
    | while IFS= read -r f; do
      sed -i "s|/home/nine/hyprarch/configs/|$HOME/.config/|g" "$f"
    done || true

  # /home/nine/hyprarch/packages_list → $REPO_DIR/packages_list
  grep -rl --binary-files=without-match "/home/nine/hyprarch/packages_list" \
    "$HOME/.config/" "$SCRIPTS_SRC/" 2>/dev/null \
    | while IFS= read -r f; do
      sed -i "s|/home/nine/hyprarch/packages_list|$REPO_DIR/packages_list|g" "$f"
    done || true

  # /home/nine/ → $HOME/ (catch-all for remaining hardcoded paths)
  grep -rl --binary-files=without-match "/home/nine/" "$HOME/.config/" 2>/dev/null \
    | while IFS= read -r f; do
      sed -i "s|/home/nine/|$HOME/|g" "$f"
    done || true
fi
ok "Paths fixed"
# ───────────────────────────────────────────────────────
#  Phase 2: Shell dotfiles
# ───────────────────────────────────────────────────────
echo ""
echo "── Phase 2: Shell Dotfiles ──────────────────────"

info "Symlinking shell dotfiles ..."
run ln -sf "$CONFIG_SRC/shell/.zshenv" "$HOME/.zshenv"
run ln -sf "$CONFIG_SRC/shell/.zshrc" "$HOME/.zshrc"

# The shell files are symlinked (not copied), so Phase 1's sed pass never
# touched them. Apply path substitution directly on the repo files.
if [ "$DRY_RUN" = false ]; then
  for f in "$CONFIG_SRC/shell/.zshenv" "$CONFIG_SRC/shell/.zshrc"; do
    [ -f "$f" ] || continue
    sed -i "s|/home/nine/hyprarch/configs/|$HOME/.config/|g" "$f"
    sed -i "s|/home/nine/|$HOME/|g" "$f"
  done
fi

# .zprofile is NOT deployed by default (user has SDDM)
# If you want TTY auto-login, uncomment:
#   ln -sf "$CONFIG_SRC/shell/.zprofile" "$HOME/.zprofile"
muted "(.zprofile skipped — SDDM handles session start)"
muted "  To enable TTY auto-start, run:"
muted "    ln -sf $CONFIG_SRC/shell/.zprofile \$HOME/.zprofile"
ok "Shell symlinks created"

# ───────────────────────────────────────────────────────
#  Phase 3: XDG Assets
# ───────────────────────────────────────────────────────
echo ""
echo "── Phase 3: Wallpapers, Desktop Entries, MIME ───"

# Wallpaper
info "Copying wallpaper to ~/.local/share/wallpapers/ ..."
run mkdir -p "$HOME/.local/share/wallpapers"
for img in "$WALLPAPER_SRC"/*; do
  run cp "$img" "$HOME/.local/share/wallpapers/"
done
ok "Wallpapers deployed"

# Desktop entries
info "Copying .desktop files to ~/.local/share/applications/ ..."
run mkdir -p "$HOME/.local/share/applications"
run cp "$APPLICATIONS_SRC"/*.desktop "$HOME/.local/share/applications/"
run chmod +x "$HOME/.local/share/applications/yazi.desktop"
run chmod +x "$HOME/.local/share/applications/vivaldi-window.desktop"
muted "  (steam.desktop was already +x)"
ok "Desktop entries deployed"

# MIME associations — copy to XDG path, then symlink as fallback
info "Setting up MIME associations ..."
run mkdir -p "$HOME/.config/xdg"
run cp "$CONFIG_SRC/xdg/mimeapps.list" "$HOME/.config/xdg/mimeapps.list"
run ln -sf "$CONFIG_SRC/xdg/mimeapps.list" "$HOME/.config/mimeapps.list"
ok "MIME associations set"

# xdg-desktop-portal-termfilechooser config
# (config is already in ~/.config via the copy in Phase 1,
#  but the wrapper path was fixed by sed. Verify it exists.)
info "Verifying xdg-desktop-portal-termfilechooser config ..."
if [ ! -f "$HOME/.config/xdg-desktop-portal-termfilechooser/config" ]; then
  run mkdir -p "$HOME/.config/xdg-desktop-portal-termfilechooser"
  run cp "$CONFIG_SRC/xdg-desktop-portal-termfilechooser/config" \
       "$HOME/.config/xdg-desktop-portal-termfilechooser/config"
fi
ok "Portal config in place"

# Download-organizer
info "Deploying download-organizer ..."
run mkdir -p "$HOME/.local/bin"
run cp "$DOWNLOADS_SORTER_SRC/download-organizer" "$HOME/.local/bin/download-organizer"
run chmod +x "$HOME/.local/bin/download-organizer"
run mkdir -p "$HOME/.config/download-organizer"
run cp "$DOWNLOADS_SORTER_SRC/config.yaml" "$HOME/.config/download-organizer/config.yaml"
run mkdir -p "$HOME/.config/systemd/user"
run cp "$DOWNLOADS_SORTER_SRC/download-organizer.service" \
     "$HOME/.config/systemd/user/download-organizer.service"
ok "Download-organizer deployed"

# Ensure scripts in hypr configs are executable
info "Setting executable bits on hypr scripts ..."
run chmod +x "$HOME/.config/hypr/scripts/"*.sh 2>/dev/null || true
run chmod +x "$HOME/.config/waybar/scripts/"*.sh 2>/dev/null || true
run chmod +x "$HOME/.config/fuzzel/scripts/"*.sh 2>/dev/null || true
# osd-notify is referenced from binds.lua via absolute path to the repo
run chmod +x "$SCRIPTS_SRC/osd-notify.sh"
run chmod +x "$SCRIPTS_SRC/termfilechooser-wrapper.sh"
run chmod +x "$SCRIPTS_SRC/sync-packages-list"
run chmod +x "$DOWNLOADS_SORTER_SRC/download-organizer"
ok "Executable bits set"

# ───────────────────────────────────────────────────────
#  Phase 4: Fonts & Caches
# ───────────────────────────────────────────────────────
echo ""
echo "── Phase 4: Fonts & Caches ──────────────────────"

info "Setting up fontconfig ..."
run cp "$CONFIG_SRC/fontconfig/fonts.conf" "$HOME/.config/fontconfig/fonts.conf" 2>/dev/null \
  || warn "fontconfig already deployed (or error — check permissions)"
ok "Fontconfig in place"

if command -v fc-cache &>/dev/null; then
  info "Running fc-cache ..."
  if [ "$DRY_RUN" = false ]; then
    muted "  (this may take a moment)"
    fc-cache -fv &>/dev/null || warn "fc-cache had warnings (non-fatal)"
  fi
  ok "Font cache updated"
else
  warn "fc-cache not found — skipping"
fi

if command -v bat &>/dev/null; then
  info "Building bat cache (theme) ..."
  if [ "$DRY_RUN" = false ]; then
    bat cache --build &>/dev/null || warn "bat cache build had warnings (non-fatal)"
  fi
  ok "Bat cache built"
else
  warn "bat not found — skipping cache build"
fi

# ───────────────────────────────────────────────────────
#  Phase 5: Systemd User Services
# ───────────────────────────────────────────────────────
echo ""
echo "── Phase 5: Systemd User Services ───────────────"

if [ "$NO_USER" = true ]; then
  muted "  --no-user set, skipping"
else
  # Enable services that should be enabled (matching current system state)
  USER_SERVICES=(
    cliphist.service
    download-organizer.service
    hyprpaper.service
    mpd.service
    mpd-mpris.service
    swaync.service
    waybar.service
    ydotool.service
  )

  # These services are NOT managed by enable/disable — they
  # start via socket activation (pipewire, wireplumber) or
  # hyprland.lua (hypridle).
  # Not touched: pipewire pipewire-pulse wireplumber hypridle

  # Reload systemd to pick up new/changed service files
  info "Reloading systemd user daemon ..."
  run systemctl --user daemon-reload
  for svc in "${USER_SERVICES[@]}"; do
    if systemctl --user is-enabled "$svc" &>/dev/null; then
      muted "  $svc already enabled"
    else
      info "Enabling $svc ..."
      # Enable first; start may fail if not in a Hyprland session
      run systemctl --user enable "$svc" || warn "Failed to enable $svc"
      run systemctl --user start "$svc" 2>/dev/null || true
    fi
  done
fi


# Guard: some commands need an interactive terminal for sudo/chsh prompts
require_tty() {
  [ -t 0 ] && return 0
  local cmd="$1"
  shift
  warn "$cmd needs an interactive terminal — skipping. Run manually: $*"
  return 1
}

# ───────────────────────────────────────────────────────
#  Phase 6: System-Level Changes
# ───────────────────────────────────────────────────────
echo ""
echo "── Phase 6: System-Level Changes ────────────────"

if [ "$NO_SYSTEM" = true ]; then
  muted "  --no-system set, skipping"
else
  # ── System services ──
  SYSTEM_SERVICES=(bluetooth NetworkManager keyd sddm)

  for svc in "${SYSTEM_SERVICES[@]}"; do
    svc_name="$svc.service"
    if systemctl is-enabled "$svc_name" &>/dev/null; then
      muted "  $svc_name already enabled"
    else
      info "Enabling $svc_name (may need sudo) ..."
      run sudo systemctl enable --now "$svc_name" \
        || warn "Could not enable $svc_name (may need manual setup)"
    fi
  done

  # ── Sudoers: power-profile ──
  if [ -f /etc/sudoers.d/power-profile ]; then
    muted "  sudoers power-profile rule already exists"
  else
    info "Setting up sudoers rule for power-profile switching ..."
    if require_tty "Sudoers rule" \
      "sudo tee /etc/sudoers.d/power-profile <<< '$USER ALL=(root) NOPASSWD: /usr/bin/tee /sys/firmware/acpi/platform_profile'"; then
      if [ "$DRY_RUN" = false ]; then
        echo "$USER ALL=(root) NOPASSWD: /usr/bin/tee /sys/firmware/acpi/platform_profile" \
          | sudo tee /etc/sudoers.d/power-profile >/dev/null
        sudo chmod 440 /etc/sudoers.d/power-profile
        ok "Sudoers rule added"
      fi
    fi
  fi

  # ── Default shell: zsh ──
  if [ "$SHELL" = "/usr/bin/zsh" ] || [ "$SHELL" = "/bin/zsh" ]; then
    muted "  Zsh is already the default shell"
  else
    info "Changing default shell to zsh ..."
    if require_tty "Shell change" "chsh -s /usr/bin/zsh"; then
      if [ "$DRY_RUN" = false ]; then
        if chsh -s /usr/bin/zsh; then
          ok "Default shell changed to zsh (log out and back in to take effect)"
        else
          warn "chsh failed — set manually: chsh -s /usr/bin/zsh"
        fi
      else
        muted "  [DRY-RUN] Would run: chsh -s /usr/bin/zsh"
      fi
    fi
  fi

  ok "System-level changes applied"
fi

# ───────────────────────────────────────────────────────
#  Summary
# ───────────────────────────────────────────────────────
echo ""
echo "══════════════════════════════════════════════════"
if [ "$DRY_RUN" = true ]; then
  echo "  Dry run complete — no changes made."
  echo "  Run without --dry-run to apply."
else
  echo "  Apply complete!"
  echo ""
  echo "  Next steps:"
  echo "    1. Reboot or start Hyprland:  uwsm start hyprland"
  echo "    2. If fonts aren't rendering, log out and back in"
  echo "    3. Run 'bat cache --build' if bat themes don't show"
  if [ "$DO_BACKUP" = true ]; then
    echo "    4. Backup saved to: $BACKUP_DIR"
  fi
fi
echo "══════════════════════════════════════════════════"
