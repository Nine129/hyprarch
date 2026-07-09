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
    kb_layout      = "us",
    follow_mouse   = 1,
    sensitivity    = 1.4,
    accel_profile  = "flat",
  },

  cursor = {
    no_hardware_cursors = true,
    enable_hyprcursor   = false,
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
  -- # Launch kitty in background on Hyprland start
  hl.exec_cmd("kitty --daemon")
  -- Quickshell
  hl.exec_cmd("quickshell -p ~/.config/quickshell")
  hl.exec_cmd("kitty --show-as=hidden")
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("swaync")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("hyprpm enable scrolloverview")
  hl.dsp.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.dsp.exec_cmd("wl-paste --type image --watch cliphist store")
end)

-- Window Rules ───────────────────────────
-- Window Rules chuẩn chỉ theo Hyprland Wiki v0.55.2 Lua API
hl.window_rule({ 
  match    = { class = "vesktop" }, 
  decorate = false,
})

-- Plugin
hl.config({
    plugin = {
        scrolloverview = {
            gesture_distance = 300, -- how far is the "max" for the gesture
            scale = 0.75, -- preferred overview scale
            workspace_gap = 0,
            layout = "vertical", -- vertical or horizontal
            wallpaper = 0, -- 0: global only, 1: per-workspace only, 2: both
            blur = false, -- blur only the main overview wallpaper

            shadow = {
                enabled = false,
                range = 50,
                render_power = 3,
                color = 0xee1a1a1a,
            },
        },
    },
})

