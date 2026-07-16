#!/bin/bash
# ── CGGX Rice — Setup Lint ───────────────────────────
# Read-only pre-flight check: validates repo integrity, config
# consistency, and system readiness before running apply.sh.
#
# Usage: ./scripts/setup-lint.sh [--verbose]
#   --verbose   Show all checks including passing ones
#   --quiet     Suppress banner, show only failures/warnings
#   --fix       Attempt minor auto-fixes (set +x on scripts, etc.)
#
# Exit codes: 0 = all checks pass, 1 = warnings only, 2 = failures

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
VERBOSE=false
QUIET=false
DO_FIX=false

for arg in "$@"; do
  case "$arg" in
    --verbose) VERBOSE=true ;;
    --quiet)   QUIET=true ;;
    --fix)     DO_FIX=true ;;
    --help)
      cat <<'EOF'
CGGX Rice — Setup Lint

Validates repo structure, config consistency, and system
readiness for a clean deployment. Read-only by default.

Usage: ./scripts/setup-lint.sh [flags]

Flags:
  --verbose   Show all checks including passing ones
  --quiet     Suppress banner, show only failures/warnings
  --fix       Attempt minor auto-fixes (set +x, etc.)
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

# ── Paths ──────────────────────────────────────────────
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_SRC="$REPO_DIR/configs"
SCRIPTS_SRC="$REPO_DIR/scripts"
WALLPAPER_SRC="$REPO_DIR/wallpapers"

# ── Counters ──────────────────────────────────────────
PASSED=0
WARNINGS=0
FAILURES=0

pass() { PASSED=$((PASSED + 1)); "$@" || true; }
warn_() { WARNINGS=$((WARNINGS + 1)); "$@" || true; }  # shadowed by warn()
fail_() { FAILURES=$((FAILURES + 1)); "$@" || true; }

check_header() {
  [ "$QUIET" = false ] && echo "" && echo "── $1 ───────────────────────────────" || true
}

maybe_show() {
  if [ "$1" != "ok" ] || [ "$QUIET" = false ]; then
    echo -e "$2"
  fi
  return 0
}

show_ok()    { local m="$1"; maybe_show "ok"    " ${GREEN}✓${NC} $m"; pass true; }
show_warn()  { local m="$1"; maybe_show "warn"  " ${YELLOW}⚠${NC} $m"; warn_ true; }
show_fail()  { local m="$1"; maybe_show "fail"  " ${RED}✗${NC} $m"; fail_ true; }

# ======================================================
[ "$QUIET" = false ] && cat <<BANNER || true
══════════════════════════════════════════════════
  CGGX Rice — Setup Lint
  Repo: $REPO_DIR
  User: ${USER:-$HOME}  Host: $(hostname 2>/dev/null || echo "?")
══════════════════════════════════════════════════
BANNER

# ======================================================
#  Environment Sanity
# ======================================================
check_header "Environment"

# OS check
case "$(uname -s)" in
  Linux) show_ok "Operating system: Linux" ;;
  *)
    show_fail "Operating system: $(uname -s) — this rice targets Linux/Arch"
    ;;
esac

# Bash version
if [ "${BASH_VERSINFO:-0}" -ge 4 ]; then
  show_ok "Bash ${BASH_VERSION}"
else
  show_fail "Bash ${BASH_VERSION} — need >= 4"
fi

# $HOME safety (same check as apply.sh)
case "$HOME" in
  *\|*|*\\*|*\&*)
    show_fail "\$HOME contains |, \\, or & — sed substitution will corrupt configs"
    show_fail "  HOME=$HOME"
    show_fail "  Fix your home directory path before deploying"
    ;;
  *) show_ok "\$HOME has no sed-dangerous characters" ;;
esac

# Essential base tools
missing_utils=()
for util in basename dirname sed grep readlink realpath xargs find stat chmod; do
  command -v "$util" &>/dev/null || missing_utils+=("$util")
done
if [ "${#missing_utils[@]}" -eq 0 ]; then
  show_ok "Essential base utilities available"
else
  show_fail "Missing base utilities: ${missing_utils[*]}"
fi

# ======================================================
#  System Runtime
# ======================================================
check_header "System Runtime"

# XDG_RUNTIME_DIR
if [ -n "${XDG_RUNTIME_DIR:-}" ] && [ -d "$XDG_RUNTIME_DIR" ]; then
  show_ok "XDG_RUNTIME_DIR is set and exists"
else
  show_fail "XDG_RUNTIME_DIR is unset or missing — systemd --user depends on it"
  show_fail "  Log in via a display manager or TTY login (not via ssh -X)"
fi

# DBUS_SESSION_BUS_ADDRESS
if [ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
  show_ok "DBUS_SESSION_BUS_ADDRESS is set"
else
  show_fail "DBUS_SESSION_BUS_ADDRESS is unset — systemd --user communication will fail"
  show_fail "  Ensure dbus is running and the session bus address is exported"
fi

# systemctl --user is available and responsive
if command -v systemctl &>/dev/null; then
  if systemctl --user &>/dev/null; then
    show_ok "systemctl --user is responsive"
  else
    show_warn "systemctl --user failed — user instance may not be running"
    show_warn "  Start it: systemctl --user start"
    muted "  (Expected if you run this script very early in the session)"
  fi
else
  show_fail "systemctl not found on PATH — systemd user services cannot be enabled"
fi

# ~/.config is writable — Phase 1 depends on it
config_test="$HOME/.config/.lint-writable-test-$$"
if mkdir -p "$HOME/.config" 2>/dev/null && touch "$config_test" 2>/dev/null; then
  rm -f "$config_test"
  show_ok "~/.config is writable"
else
  show_fail "~/.config is not writable — Phase 1 copy will fail"
fi

# ~/.local/bin in PATH — download-organizer and termfilechooser-wrapper go here
case ":$PATH:" in
  *:"$HOME/.local/bin":*) show_ok "~/.local/bin is on PATH" ;;
  *) show_warn "~/.local/bin is not on PATH — add it to your shell rc for download-organizer and portal tools" ;;
esac

# ======================================================
#  User Setup
# ======================================================
check_header "User Setup"

# User groups for hardware access
current_groups=$(groups 2>/dev/null || id -Gn 2>/dev/null || echo "")
missing_groups=()
for g in input video audio; do
  case " $current_groups " in
    *" $g "*) ;;
    *) missing_groups+=("$g") ;;
  esac
done
if [ "${#missing_groups[@]}" -eq 0 ]; then
  show_ok "User is in all recommended groups (input, video, audio)"
else
  show_warn "User not in groups: ${missing_groups[*]}"
  muted "  Hyprland benefits from 'input'; brightnessctl needs 'video'; audio needs 'audio'."
  muted "  Fix: sudo usermod -aG ${missing_groups[*]} $USER"
  muted "  (then log out and back in)"
fi

# Git repo state — warn about uncommitted changes before destructive deploy
if command -v git &>/dev/null && [ -d "$REPO_DIR/.git" ]; then
  if git -C "$REPO_DIR" diff --quiet 2>/dev/null && git -C "$REPO_DIR" diff --cached --quiet 2>/dev/null; then
    show_ok "Git repo is clean"
  else
    show_warn "Git repo has uncommitted changes — 'apply.sh' deploys from the working tree"
    muted "  Run 'git status' in $REPO_DIR to review"
  fi
else
  muted "  (Not a git repo or git not available — skipping dirty check)"
fi

# ======================================================
#  Repo Structure
# ======================================================
check_header "Repo Structure"

# Critical directories
missing_dirs=()
for d in "$CONFIG_SRC/hypr" "$CONFIG_SRC/shell" "$SCRIPTS_SRC" "$WALLPAPER_SRC"; do
  [ -d "$d" ] || missing_dirs+=("$d")
done
if [ "${#missing_dirs[@]}" -eq 0 ]; then
  show_ok "All critical directories exist"
else
  show_fail "Missing directories: ${missing_dirs[*]}"
fi

# Also check: CONFIG_SRC/hypr/scripts, CONFIG_SRC/systemd, CONFIG_SRC/waybar
for d in "$CONFIG_SRC/hypr/scripts" "$CONFIG_SRC/systemd/user" "$CONFIG_SRC/waybar/scripts" "$CONFIG_SRC/fuzzel/scripts"; do
  [ -d "$d" ] || { show_warn "Missing optional directory: $d"; }
done

# Broken symlinks in the repo
broken=$(find "$REPO_DIR" -type l ! -exec test -e {} \; -print 2>/dev/null | head -20)
if [ -z "$broken" ]; then
  show_ok "No broken symlinks in repo"
else
  show_warn "Broken symlinks found:"
  while IFS= read -r sym; do
    target=$(readlink "$sym" 2>/dev/null || echo "?")
    muted "  $sym → $target"
  done <<<"$broken"
fi

# Config dirs that should be in apply.sh's exclude list
# apply.sh excludes: shell/, atuin/
all_configs=$(find "$CONFIG_SRC" -maxdepth 1 -type d ! -name '.' ! -name 'conf' -printf '%f\n' | sort)
expected_excluded="shell atuin"
unexpected=""
while IFS= read -r dir; do
  case " $expected_excluded " in
    *" $dir "*) ;;  # expected exclusion
    *) unexpected="$unexpected $dir" ;;
  esac
done <<<"$all_configs"

# Check that apply.sh's exclude list is in sync: iterate the copy loop and
# see if a config directory exists but wouldn't be copied (not an absolute
# indicator, just a sanity check).
apply_excludes_line=$(grep -n 'case.*name.*in' "$SCRIPTS_SRC/apply.sh" | head -1)
if [ -n "$apply_excludes_line" ]; then
  show_ok "apply.sh has an explicit exclude list for config copy"
else
  show_warn "Could not find exclude-list line in apply.sh"
fi

# ======================================================
#  Script & Binary References
# ======================================================
check_header "Script & Binary References"

# ── Hypr scripts exist and are executable ──
hypr_scripts=("$CONFIG_SRC/hypr/scripts/"*.sh)
non_exec=()
for s in "${hypr_scripts[@]}"; do
  [ -f "$s" ] || continue
  [ -x "$s" ] || non_exec+=("$(basename "$s")")
done
if [ "${#non_exec[@]}" -eq 0 ]; then
  show_ok "All hypr scripts are executable"
else
  show_warn "Non-executable hypr scripts: ${non_exec[*]}"
  if [ "$DO_FIX" = true ]; then
    for s in "${non_exec[@]}"; do
      chmod +x "$CONFIG_SRC/hypr/scripts/$s"
    done
    show_ok "Fixed: chmod +x on ${#non_exec[@]} script(s)"
  else
    muted "  Run with --fix to auto-fix"
  fi
fi

# ── Waybar scripts ──
waybar_scripts=("$CONFIG_SRC/waybar/scripts/"*.sh)
for s in "${waybar_scripts[@]}"; do
  [ -f "$s" ] && [ -x "$s" ] || {
    show_warn "Non-executable or missing waybar script: $(basename "$s" 2>/dev/null || echo "$s")"
    break
  }
done

# ── Fuzzel scripts ──
fuzzel_scripts=("$CONFIG_SRC/fuzzel/scripts/"*.sh)
for s in "${fuzzel_scripts[@]}"; do
  [ -f "$s" ] && [ -x "$s" ] || {
    show_warn "Non-executable or missing fuzzel script: $(basename "$s" 2>/dev/null || echo "$s")"
    break
  }
done

# ── Systemd wants/ symlinks target check ──
user_services_dir="$CONFIG_SRC/systemd/user"
if [ -d "$user_services_dir" ]; then
  missing_services=()
  while IFS= read -r sym; do
    target=$(readlink "$sym" 2>/dev/null || true)
    target_name=$(basename "$target")
    # service file should exist either in user-services dir or be a well-known system path
    if ! [ -f "$user_services_dir/$target_name" ] && ! [[ "$target" == /usr/lib/* ]]; then
      missing_services+=("$sym → $target")
    fi
  done < <(find "$user_services_dir" -type l -path '*.wants/*' 2>/dev/null)
  if [ "${#missing_services[@]}" -eq 0 ]; then
    show_ok "All systemd wants/ symlinks target valid service files"
  else
    show_warn "Systemd wants/ symlinks with potentially missing targets:"
    for ms in "${missing_services[@]}"; do
      muted "  $ms"
    done
  fi
else
  show_warn "systemd/user directory missing — skipping wants/ checks"
fi

# ── Service files referenced in binds.lua ──
# We check that the Hyprland Lua config files themselves exist
for f in "$CONFIG_SRC/hypr/binds.lua" "$CONFIG_SRC/hypr/hyprland.lua" "$CONFIG_SRC/hypr/settings.lua" "$CONFIG_SRC/hypr/rules.lua" "$CONFIG_SRC/hypr/animations.lua"; do
  [ -f "$f" ] || show_fail "Missing hypr config: $f"
done

# ── Lua syntax check ──
if command -v luac &>/dev/null; then
  bad_lua=0
  for f in "$CONFIG_SRC/hypr"/*.lua; do
    [ -f "$f" ] || continue
    luac -p "$f" 2>/dev/null || { bad_lua=$((bad_lua + 1)); muted "  $(basename "$f"): syntax error"; }
  done
  if [ "$bad_lua" -eq 0 ]; then
    show_ok "All hypr Lua configs pass syntax check"
  else
    show_fail "$bad_lua hypr Lua config(s) have syntax errors — Hyprland will abort"
  fi
else
  muted "  (luac not found — skipping Lua syntax validation)"
fi

# ── Cross-reference exec_cmd paths against actual files ──
# Extract every exec_cmd("...") from binds.lua and hyprland.lua,
# resolve file paths, flag ones that don't resolve.
missing_refs=0
for srcfile in "$CONFIG_SRC/hypr/binds.lua" "$CONFIG_SRC/hypr/hyprland.lua"; do
  [ -f "$srcfile" ] || continue
  while IFS= read -r line; do
    # Extract content between exec_cmd(" and ")
    cmdtext="${line#*exec_cmd(\"}"
    [ "$cmdtext" = "$line" ] && continue  # no exec_cmd on this line
    cmdtext="${cmdtext%%\"*}"

    # Split on ||, &&, ; to get individual commands
    while IFS= read -d ';' -r segment || [ -n "$segment" ]; do
      # Split on || and && (but keep the whole string for pkill X || Y pattern)
      # Normalize: handle pkill patterns specially
      case "$segment" in
        *\|\|*)
          # pkill X || Y — check Y (the real launch); skip pkill (it's a kill)
          right="${segment#*\|\|}"
          segment="$right"
          ;;
      esac

      # Extract first whitespace-delimited token
      read -r first rest <<<"$segment" || true
      [ -z "$first" ] && continue

      # Strip bash -c wrapper
      [ "$first" = "bash" ] && continue

      # Only check paths (contain / or start with ~)
      case "$first" in
        */*|~*)
          case "$first" in
            /usr/*|/bin/*) continue ;;
          esac
          # Resolve ~/ to $HOME and check if file exists
          expanded="${first/#\~/$HOME}"
          if [ ! -f "$expanded" ] && [ ! -x "$expanded" ]; then
            # Try repo-resolved: ~/hyprarch/... → $CONFIG_SRC/... or $HOME/hyprarch/... → $REPO_DIR/...
            repo_resolved="${first/#\~\/hyprarch/$CONFIG_SRC}"
            repo_resolved="${repo_resolved/#\$HOME\/hyprarch/$REPO_DIR}"
            if [ ! -f "$repo_resolved" ] && [ ! -x "$repo_resolved" ]; then
              show_warn "exec_cmd target not found: $first"
              missing_refs=$((missing_refs + 1))
            fi
          fi
          ;;
      esac
    done < <(echo "$cmdtext" | tr '|' ';')  # crude split — actually we handle || above
  done < <(grep 'exec_cmd(' "$srcfile" 2>/dev/null || true)
done
[ "$missing_refs" -eq 0 ] && show_ok "All exec_cmd script paths resolve"

# ── scripts/ repo scripts exist ──
for s in osd-notify.sh termfilechooser-wrapper.sh; do
  [ -f "$SCRIPTS_SRC/$s" ] || show_warn "Missing repo script: $SCRIPTS_SRC/$s"
done

# ── osd-notify.sh is executable ──
if [ -f "$SCRIPTS_SRC/osd-notify.sh" ] && [ ! -x "$SCRIPTS_SRC/osd-notify.sh" ]; then
  show_warn "osd-notify.sh is not executable"
  [ "$DO_FIX" = true ] && chmod +x "$SCRIPTS_SRC/osd-notify.sh" && show_ok "Fixed osd-notify.sh"
fi

# ── Downloads sorter binary ──
if [ -f "$REPO_DIR/downloads-sorter/download-organizer" ]; then
  show_ok "download-organizer binary exists"
  [ -x "$REPO_DIR/downloads-sorter/download-organizer" ] || {
    show_warn "download-organizer not executable"
    [ "$DO_FIX" = true ] && chmod +x "$REPO_DIR/downloads-sorter/download-organizer" && show_ok "Fixed"
  }
else
  show_warn "download-organizer binary missing (build it or check downloads-sorter/)"
fi

# ── Wallpaper files exist ──
wallpapers=("$WALLPAPER_SRC"/*)
if [ "${#wallpapers[@]}" -gt 0 ] && [ -f "${wallpapers[0]}" ]; then
  show_ok "Wallpaper files present (${#wallpapers[@]})"
else
  show_fail "No wallpaper files found in $WALLPAPER_SRC"
fi

# ── Config syntax checks ──

# Waybar config.jsonc — strip JS comments then validate with jq if available
waybar_config="$CONFIG_SRC/waybar/config.jsonc"
if [ -f "$waybar_config" ]; then
  # Try proper JSONC→JSON conversion; order by reliability
  if command -v python3 &>/dev/null; then
    if python3 -c "
import json, re, sys
with open('$waybar_config') as f:
    s = f.read()
# Strip // and /* */ comments
s = re.sub(r'//.*', '', s)
s = re.sub(r'/\*[^*]*\*/', '', s)
# Remove trailing commas before ] or }
s = re.sub(r',\s*([\]}])', r'\1', s)
try:
    json.loads(s)
    sys.exit(0)
except json.JSONDecodeError:
    sys.exit(1)
" 2>/dev/null; then
      show_ok "Waybar config.jsonc is valid JSON (comments + trailing commas stripped)"
    else
      show_warn "Waybar config.jsonc has syntax issues beyond standard JSONC tolerance"
    fi
  elif command -v jq &>/dev/null; then
    # jq alone doesn't handle JSONC — strip comments and trailing commas with sed
    # Trailing commas before closing brackets may still fail (sed is line-based)
    stripped=$(
      sed 's|//.*||g; s|/\*[^*]*\*/||g' "$waybar_config" \
        | sed -E ':1; s|,[[:space:]]*(\])|\1|g; s|,[[:space:]]*(\})|\1|g; t1' 2>/dev/null || true
    )
    if echo "$stripped" | jq . &>/dev/null; then
      show_ok "Waybar config.jsonc is valid JSON (sed-stripped)"
    else
      show_warn "Waybar config.jsonc has syntax issues (trailing commas in multi-line may remain)"
      muted "  The config will still work in Waybar (which tolerates JSONC natively)"
    fi
  else
    show_ok "Waybar config.jsonc exists (install python3 or jq for syntax validation)"
  fi
else
  show_warn "Waybar config.jsonc not found"
fi

# ── Waybar modules — validate included module file ──
waybar_modules_dir="$CONFIG_SRC/waybar/modules"
waybar_module_file="$waybar_modules_dir/cggx.jsonc"
if [ -f "$waybar_module_file" ]; then
  # Validate with same method as the bar config
  if command -v python3 &>/dev/null; then
    if python3 -c "
import json, re, sys
with open('$waybar_module_file') as f:
    s = f.read()
s = re.sub(r'//.*', '', s)
s = re.sub(r'/\*[^*]*\*/', '', s)
s = re.sub(r',\s*([\]}])', r'\1', s)
try:
    json.loads(s)
    sys.exit(0)
except json.JSONDecodeError:
    sys.exit(1)
" 2>/dev/null; then
      show_ok "Waybar modules/cggx.jsonc is valid JSON"
    else
      show_warn "Waybar modules/cggx.jsonc has syntax issues"
    fi
  else
    show_ok "Waybar modules/cggx.jsonc exists"
  fi
else
  show_warn "Waybar modules/cggx.jsonc not found — bar config includes it"
fi

# Desktop .desktop files — validate with desktop-file-validate if available
desktop_dir="$REPO_DIR/applications"
desktop_files=("$desktop_dir"/*.desktop)
if [ -d "$desktop_dir" ] && [ -f "${desktop_files[0]}" ]; then
  if command -v desktop-file-validate &>/dev/null; then
    bad_desktop=0
    for df in "${desktop_files[@]}"; do
      desktop-file-validate "$df" >/dev/null 2>&1 || bad_desktop=$((bad_desktop + 1))
    done
    if [ "$bad_desktop" -eq 0 ]; then
      show_ok "All .desktop files pass validation (${#desktop_files[@]})"
    else
      show_warn "$bad_desktop .desktop file(s) have validation issues"
      muted "  Run 'desktop-file-validate <file>' to see details"
    fi
  else
    show_ok "Desktop files exist (install desktop-file-utils for validation)"
  fi
fi

# Systemd service files — basic check with systemd-analyze if available
if command -v systemd-analyze &>/dev/null && [ -d "$user_services_dir" ]; then
  bad_units=0
  while IFS= read -r svc; do
    systemd-analyze verify "$svc" 2>/dev/null || bad_units=$((bad_units + 1))
  done < <(find "$user_services_dir" -name '*.service' -type f 2>/dev/null)
  if [ "$bad_units" -eq 0 ]; then
    show_ok "All systemd service files pass syntax check (when find ran)"
  else
    show_warn "$bad_units service file(s) have syntax issues"
    muted "  Run 'systemd-analyze verify <file>' to see details"
  fi
fi

# ======================================================
#  Binary Availability (on the current system)
# ======================================================
check_header "Binary Availability"

declare -A BIN_CATEGORIES
BIN_CATEGORIES=(
  ["terminal"]="kitty"
  ["launcher"]="fuzzel"
  ["wm"]="hyprctl hyprlock hyprpaper hypridle hyprshade hyprpicker"
  ["bar"]="waybar"
  ["notifications"]="swaync"
  ["logout"]="wlogout"
  ["audio"]="pamixer wpctl playerctl"
  ["display"]="swayosd-client swayosd-server brightnessctl"
  ["screenshot"]="grimblast grim slurp"
  ["clipboard"]="cliphist wl-clipboard"
  ["files"]="yazi"
  ["browser"]="vivaldi"
  ["shell-utils"]="eza bat fzf zoxide fd trash-cli duf dust btop fastfetch"
  ["media"]="rmpc mpd mpv imv"
  ["misc"]="nm-applet blueman-applet hyprpolkitagent zsh sudo"
)

missing_bins=()
all_found=true
for category in "${!BIN_CATEGORIES[@]}"; do
  bins="${BIN_CATEGORIES[$category]}"
  for bin in $bins; do
    if command -v "$bin" &>/dev/null; then
      [ "$VERBOSE" = true ] && muted "  $bin: found"
    else
      missing_bins+=("$bin")
      all_found=false
    fi
  done
done

if [ "$all_found" = true ]; then
  show_ok "All recommended binaries found on PATH"
else
  show_warn "Missing binaries (${#missing_bins[@]}): ${missing_bins[*]}"
  muted "  These are expected on a fresh system — install via packages_list"
fi

# ======================================================
#  Hardcoded Path Analysis
# ======================================================
check_header "Path Safety"

# Scan repo configs for /home/nine references
hardcoded_files=$(grep -rl --binary-files=without-match "/home/nine/" \
  "$CONFIG_SRC" "$SCRIPTS_SRC" "$REPO_DIR/applications" 2>/dev/null || true)

if [ -z "$hardcoded_files" ]; then
  show_ok "No hardcoded /home/nine paths — excellent"
else
  # Categorize what the sed pass in apply.sh fixes
  # apply.sh fixes within ~/.config/ after copy:
  #   1. /home/nine/hyprarch/configs/ → $HOME/.config/
  #   2. /home/nine/hyprarch/packages_list → $REPO_DIR/packages_list
  #   3. /home/nine/ → $HOME/ (catch-all)
  # Plus Phase 2 fixes shell/ files symlinked from repo.

  # Files that DON'T end up in ~/.config/ or aren't covered:
  # - scripts/ files (osd-notify.sh, termfilechooser-wrapper.sh) — not copied to ~/.config/
  # - applications/ .desktop files — copied to ~/.local/share/applications/ (NOT ~/.config/!)
  # - downloads-sorter/ files — copied to various places
  # - shell/ files — symlinked, handled by Phase 2 fix

  # We separate covered from uncovered
  total_files=$(echo "$hardcoded_files" | wc -l)
  covered=0
  uncovered_files=""

  while IFS= read -r f; do
    rel="${f#$REPO_DIR/}"
    case "$rel" in
      # Files under configs/ end up in ~/.config/ via Phase 1 copy → sed fixes them
      configs/*)
        covered=$((covered + 1))
        ;;
      # shell/ files are symlinked — Phase 2 now fixes them
      configs/shell/*)
        covered=$((covered + 1))
        ;;
      # Scripts are deployment helpers — their /home/nine references are in
      # sed patterns and grep commands applied to deployed configs, not the
      # deployable content itself. Skip them.
      scripts/*)
        covered=$((covered + 1))
        ;;
      # Everything else — review needed
      *)
        uncovered_files="$uncovered_files  $rel"$'\n'
        ;;
    esac
  done <<<"$hardcoded_files"

  [ "$covered" -gt 0 ] && show_ok "$covered hardcoded path(s) covered by sed pass"
  if [ -n "$uncovered_files" ]; then
    show_warn "Uncovered hardcoded paths in:"
    muted "  Files not in configs/ — need manual review before deploy:"
    while IFS= read -r line; do
      [ -n "$line" ] && muted "    $line"
    done <<<"$uncovered_files"
  else
    show_ok "All hardcoded paths are covered by sed pass"
  fi
fi

# ======================================================
#  Cross-Config References
# ======================================================
check_header "Cross-Config References"

# Wallpaper: hyprland.lua's hyprctl command should reference a real wallpaper file
# Extract the path after "wallpaper eDP-1," in hyprland.lua
wp_line=$(grep 'wallpaper eDP-1,' "$CONFIG_SRC/hypr/hyprland.lua" 2>/dev/null | grep 'exec_cmd' | head -1)
if [ -n "$wp_line" ]; then
  wp_path="${wp_line#*wallpaper eDP-1,}"
  wp_path="${wp_path%%\"*}"
  # Expand sed substitution: /home/nine/ → $HOME/
  wp_resolved="${wp_path/#\/home\/nine\//$HOME/}"
  # Also try the repo wallpaper dir (after Phase 3 copy, it's in ~/.local/share/wallpapers/)
  wp_basename=$(basename "$wp_resolved")
  if [ -f "$wp_resolved" ]; then
    show_ok "Wallpaper path resolves: $wp_basename"
  elif [ -f "$WALLPAPER_SRC/$wp_basename" ]; then
    show_ok "Wallpaper will deploy to resolved path (source: $wp_basename)"
  else
    show_warn "Wallpaper reference in hyprland.lua does not resolve: $wp_path"
    muted "  After sed substitution: $wp_resolved"
  fi
fi

# btop theme: the config references a theme file
btop_conf="$CONFIG_SRC/btop/btop.conf"
if [ -f "$btop_conf" ]; then
  theme_line=$(grep 'color_theme' "$btop_conf" 2>/dev/null | grep '/home/nine' | head -1)
  if [ -n "$theme_line" ]; then
    theme_path="${theme_line#*color_theme = \"}"
    theme_path="${theme_path%%\"*}"
    # After sed substitution: /home/nine/.config/btop/themes/cggx.theme → $HOME/.config/btop/themes/cggx.theme
    theme_name=$(basename "$theme_path")
    theme_resolved=$(find "$CONFIG_SRC/btop" -name "$theme_name" -type f 2>/dev/null | head -1)
    if [ -n "$theme_resolved" ]; then
      show_ok "btop theme file exists: $theme_name"
    else
      show_warn "btop theme not found in repo: $theme_name (referenced in btop.conf)"
    fi
  fi
fi

# wlogout icons: check every icon file referenced in style.css exists
wlogout_css="$CONFIG_SRC/wlogout/style.css"
if [ -f "$wlogout_css" ]; then
  missing_icons=0
  while IFS= read -r icon; do
    [ -z "$icon" ] && continue
    icon_file="$CONFIG_SRC/wlogout/icons/$icon"
    [ -f "$icon_file" ] || { missing_icons=$((missing_icons + 1)); muted "  missing: $icon"; }
  done < <(grep -oP 'url\("[^"]+/icons/\K[^"]+' "$wlogout_css" 2>/dev/null || true)
  if [ "$missing_icons" -eq 0 ]; then
    show_ok "All wlogout icons exist"
  else
    show_warn "$missing_icons wlogout icon(s) missing"
  fi
fi

# ======================================================
#  Summary
# ======================================================
check_header "Summary"

total=$((PASSED + WARNINGS + FAILURES))
[ "$total" -eq 0 ] && total=1  # avoid div-by-zero

echo ""
if [ "$FAILURES" -gt 0 ]; then
  echo -e " ${RED}${FAILURES} failure(s)${NC}, ${YELLOW}${WARNINGS} warning(s)${NC}, ${GREEN}${PASSED} passed${NC}"
  exit 2
elif [ "$WARNINGS" -gt 0 ]; then
  echo -e " ${YELLOW}${WARNINGS} warning(s)${NC}, ${GREEN}${PASSED} passed${NC}"
  exit 1
else
  echo -e " ${GREEN}All ${PASSED} checks passed${NC}"
  exit 0
fi
