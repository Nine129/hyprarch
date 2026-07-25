#!/bin/bash
# ── CGGX Rice — Install Packages ──────────────────────
# Installs every package from packages_list:
#   1. Sync pacman databases
#   2. Classify packages (official repos → pacman, AUR → paru)
#   3. Install official packages with pacman -S --needed
#   4. Bootstrap an AUR helper (paru) if not already installed
#   5. Install AUR packages with paru -S --needed
#
# Usage: ./scripts/install-packages.sh [--dry-run] [--aur-only]
#   --dry-run  Print what would be done, make no changes
#   --aur-only Skip pacman step, only install AUR packages

set -euo pipefail

# ── Colors ─────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
MUTED='\033[0;37m'
NC='\033[0m'

ok()    { echo -e " ${GREEN}✓${NC} $1"; }
warn()  { echo -e " ${YELLOW}⚠${NC} $1"; }
fail()  { echo -e " ${RED}✗${NC} $1"; }
info()  { echo -e " ${CYAN}→${NC} $1"; }
muted() { echo -e "  ${MUTED}$1${NC}"; }

# ── Config ────────────────────────────────────────────
DRY_RUN=false
AUR_ONLY=false

for arg in "$@"; do
  case "$arg" in
    --dry-run)  DRY_RUN=true ;;
    --aur-only) AUR_ONLY=true ;;
    --help)
      cat <<'EOF'
CGGX Rice — Install Packages

Installs every package from the repo's packages_list:
pacman for official repos, paru for AUR packages.

Usage: ./scripts/install-packages.sh [flags]

Flags:
  --dry-run   Print packages that would be installed, make no changes
  --aur-only  Skip official packages, only install AUR packages
  --help      Show this message
EOF
      exit 0
      ;;
    *)
      echo "Unknown flag: $arg  (try --help)"
      exit 1
      ;;
  esac
done

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PKG_LIST="$REPO_DIR/packages_list"

if [ ! -f "$PKG_LIST" ]; then
  fail "packages_list not found at $PKG_LIST"
  exit 1
fi

echo "══════════════════════════════════════════════════"
echo "  CGGX Rice — Install Packages"
echo "  Repo: $REPO_DIR"
echo "  User: ${USER:-$HOME}"
echo "══════════════════════════════════════════════════"
echo ""

# ── Ensure pacman databases are synced and system is up to date ─────────────────
if [ "$DRY_RUN" = false ]; then
  info "Syncing pacman databases and updating system ..."
  sudo pacman -Syu --noconfirm
  ok "System updated"
else
  muted "  [DRY-RUN] Would run: sudo pacman -Syu --noconfirm"
fi

# ── Pre-classification: distro/repo specific packages ─────────────────
info "Checking repository compatibility ..."

# Packages that only exist in the CachyOS repositories.
CACHYOS_ONLY_PKGS=(
  cachyos-keyring
  cachyos-mirrorlist
  cachyos-v3-mirrorlist
  cachyos-v4-mirrorlist
  linux-cachyos
  linux-cachyos-headers
)

CACHYOS_REPOS_ENABLED=false
if grep -qE '^\s*\[cachyos' /etc/pacman.conf 2>/dev/null; then
  CACHYOS_REPOS_ENABLED=true
fi

if [ "$CACHYOS_REPOS_ENABLED" = false ]; then
  warn "CachyOS repositories not detected in /etc/pacman.conf"
  muted "  Skipping CachyOS-only kernel/keyring/mirrorlist packages."
  muted "  To use the CachyOS kernel, add the CachyOS repos first:"
  muted "    https://wiki.cachyos.org/cachyos_basic/installation/"
fi

# 32-bit libraries need [multilib].  Enable it if any lib32-* package is
# requested and the repo is currently disabled.
MULTILIB_ENABLED=false
if grep -qE '^[[:space:]]*\[multilib\]' /etc/pacman.conf 2>/dev/null; then
  MULTILIB_ENABLED=true
fi

if [ "$MULTILIB_ENABLED" = false ] && grep -qE '^[[:space:]]*#[[:space:]]*\[multilib\]' /etc/pacman.conf 2>/dev/null; then
  if grep -qE '^lib32-' "$PKG_LIST"; then
    warn "[multilib] is disabled but lib32-* packages are requested."
    if [ "$DRY_RUN" = false ]; then
      info "Enabling [multilib] in /etc/pacman.conf ..."
      sudo sed -i '/^[[:space:]]*#[[:space:]]*\[multilib\]/,/^[[:space:]]*#[[:space:]]*Include/ s/^#//' /etc/pacman.conf
      sudo pacman -Syu --noconfirm
      ok "[multilib] enabled"
    else
      muted "  [DRY-RUN] Would enable [multilib] and re-sync"
    fi
  fi
fi

# ── Classify packages ──────────────────────────────────
info "Classifying packages (official vs AUR) ..."

official_list=$(mktemp)

# Get all available official packages from synced repos.
# If this fails (e.g., databases not synced), fall back to checking each
# package individually with pacman -Si.
if ! pacman -Slq 2>/dev/null | sed 's|.*/||' | sort -u > "$official_list"; then
  warn "pacman -Slq failed — will fall back to per-package classification"
fi

official_pkgs=()
aur_pkgs=()

while IFS= read -r pkg || [ -n "$pkg" ]; do
  [ -z "$pkg" ] && continue

  # Skip CachyOS-only packages if the CachyOS repos are not configured.
  if [ "$CACHYOS_REPOS_ENABLED" = false ]; then
    skip=false
    for cachy_pkg in "${CACHYOS_ONLY_PKGS[@]}"; do
      if [ "$pkg" = "$cachy_pkg" ]; then
        skip=true
        break
      fi
    done
    if [ "$skip" = true ]; then
      muted "  Skipping $pkg (CachyOS repo not enabled)"
      continue
    fi
  fi

  if [ -s "$official_list" ]; then
    # Fast path: check against pre-built official list
    if grep -qxF "$pkg" "$official_list" 2>/dev/null; then
      official_pkgs+=("$pkg")
    else
      aur_pkgs+=("$pkg")
    fi
  else
    # Slow path: test each package with pacman -Si
    if pacman -Si "$pkg" &>/dev/null; then
      official_pkgs+=("$pkg")
    else
      aur_pkgs+=("$pkg")
    fi
  fi
done < "$PKG_LIST"

# ── Install official packages ──────────────────────────
if [ "$AUR_ONLY" = false ] && [ "${#official_pkgs[@]}" -gt 0 ]; then
  echo ""
  echo "── Official Packages (pacman) ────────────────────"
  if [ "$DRY_RUN" = false ]; then
    sudo pacman -S --needed --noconfirm "${official_pkgs[@]}" || {
      warn "Some official packages failed to install — continuing with AUR"
    }
    ok "Official packages installed"
  else
    muted "  [DRY-RUN] Would run: sudo pacman -S --needed --noconfirm"
    for pkg in "${official_pkgs[@]}"; do
      muted "    $pkg"
    done
  fi
elif [ "$AUR_ONLY" = true ]; then
  muted "  (--aur-only: skipping official packages)"
fi

# ── Bootstrap AUR helper ───────────────────────────────
if [ "${#aur_pkgs[@]}" -gt 0 ]; then
  echo ""
  echo "── AUR Packages (paru) ───────────────────────────"

  AUR_HELPER=""
  if command -v paru &>/dev/null; then
    AUR_HELPER="paru"
  elif command -v yay &>/dev/null; then
    AUR_HELPER="yay"
  fi
  if [ -z "$AUR_HELPER" ]; then
    if [ "$DRY_RUN" = false ]; then
      info "No AUR helper found — bootstrapping paru from AUR ..."
      if command -v git &>/dev/null; then
        BUILD_DIR=$(mktemp -d)
        # Cleanup build dir on exit or failure
        cleanup() { rm -rf "$BUILD_DIR"; }
        trap cleanup EXIT

        git clone --quiet --depth=1 https://aur.archlinux.org/paru.git "$BUILD_DIR/paru" || {
          fail "Failed to clone paru from AUR"
          rm -rf "$BUILD_DIR"
          exit 1
        }
        ( cd "$BUILD_DIR/paru" && makepkg -si --noconfirm ) || {
          fail "Failed to build/install paru"
          muted "  Install manually: git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si"
          rm -rf "$BUILD_DIR"
          exit 1
        }
        rm -rf "$BUILD_DIR"
        trap - EXIT

        if command -v paru &>/dev/null; then
          AUR_HELPER="paru"
          ok "paru bootstrapped"
        else
          fail "paru was built but not found on PATH after install"
          muted "  Try running: hash -r && paru --version"
          exit 1
        fi
      else
        fail "git is required to bootstrap AUR helper — install base-devel first"
        exit 1
      fi
    else
      muted "  [DRY-RUN] Would bootstrap paru from AUR"
      AUR_HELPER="paru"
    fi
  else
    muted "  Using existing AUR helper: $AUR_HELPER"
  fi

  # ── Install AUR packages ──────────────────────────────
  if [ -n "$AUR_HELPER" ] && [ "${#aur_pkgs[@]}" -gt 0 ]; then
    if [ "$DRY_RUN" = false ]; then
      $AUR_HELPER -S --needed --noconfirm "${aur_pkgs[@]}" || {
        warn "Some AUR packages failed — install them manually from the list above"
      }
      ok "AUR packages installed"
    else
      muted "  [DRY-RUN] Would run: $AUR_HELPER -S --needed --noconfirm"
      for pkg in "${aur_pkgs[@]}"; do
        muted "    $pkg"
      done
    fi
  fi
fi

# ── Summary ────────────────────────────────────────────
echo ""
echo "══════════════════════════════════════════════════"
if [ "$DRY_RUN" = true ]; then
  muted "  Dry run complete — no packages were installed."
  muted "  Run without --dry-run to install."
else
  ok "${#official_pkgs[@]} official + ${#aur_pkgs[@]} AUR packages processed"
  info "Run ./scripts/apply.sh to deploy configs"
fi
echo "══════════════════════════════════════════════════"
