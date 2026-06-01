-- ── CGGX Rice — Hyprland Main ───────────
-- Hyprland 0.55+ Lua config
-- Session: uwsm
-- GPU: Intel

-- Split configs ──────────────────────
require("settings")
require("binds")
require("rules")
require("animations")

-- Monitor ────────────────────────────
hl.monitor({
  output   = "eDP-1",      -- use `hyprctl monitors all`
  mode     = "1920x1080@60",
  position = "0x0",
  scale    = 1,
})

-- Fallback for unknown monitors ──
hl.monitor({
  output   = "",
  mode     = "preferred",
  position = "auto",
  scale    = 1,
})

-- Input ──────────────────────────────
hl.config({
  input = {
    kb_layout   = "us",
    follow_mouse = 1,
    sensitivity  = 0,
  },
})

-- Autostart ───────────────────────────
hl.on("hyprland.start", function()
  -- Managed by systemd user service (auto-restart on crash):
  -- hl.exec_cmd("waybar")
  hl.exec_cmd("swayosd-server")                            -- On-screen display (volume/brightness)
  -- Managed by systemd user services (step 2):
  -- hl.exec_cmd("hyprpaper")
  -- hl.exec_cmd("swaync")                                    -- Notification daemon + control center
  hl.exec_cmd("nm-applet")
  hl.exec_cmd("blueman-applet")                          -- Bluetooth tray icon
  hl.exec_cmd("/usr/lib/polkit-gnome-authentication-agent-1")
  -- Managed by systemd:
  -- hl.exec_cmd("wl-paste --watch cliphist store")  -- Clipboard history daemon
  -- Set wallpaper via IPC (hyprpaper v0.8.4 config preload doesn't work at startup)
  hl.exec_cmd("hyprctl hyprpaper wallpaper eDP-1,/home/nine/.local/share/wallpapers/cggx.webp")
end)