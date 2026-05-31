# ── CGGX Zsh — Profile ─────────────────────────────────
# Place at ~/.zprofile
# Auto-launch Hyprland on tty1 (no SDDM/display manager)

if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  exec uwsm start hyprland
fi
