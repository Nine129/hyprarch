-- ── CGGX Rice — Keybinds ────────────────
-- Sourced via require("binds")
-- Mod: SUPER (Windows key)

-- Terminal ─────────────────────────
hl.bind("SUPER + Q",       hl.dsp.exec_cmd("kitty"))
hl.bind("SUPER + W",       hl.dsp.window.close())

-- Launcher ────────────────────────
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("~/.config/hypr/scripts/rofi-launcher.sh"))
hl.bind("SUPER + E",     hl.dsp.exec_cmd("kitty -e yazi"))

-- Layout ──────────────────────────
hl.bind("SUPER + F",       hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind("SUPER + V",       hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + P",       hl.dsp.window.pseudo({ action = "toggle" }))
hl.bind("SUPER + J",       hl.dsp.layout("togglesplit"))

-- Focus movement ──────────────────
hl.bind("SUPER + left",    hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + right",   hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + up",      hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + down",    hl.dsp.focus({ direction = "d" }))
hl.bind("SUPER + Tab",     hl.dsp.focus({ last = true }))

-- Move windows ────────────────────
hl.bind("SUPER + SHIFT + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + down",  hl.dsp.window.move({ direction = "d" }))

-- Swap windows ────────────────────
hl.bind("SUPER + CTRL + left",  hl.dsp.window.swap({ direction = "l" }))
hl.bind("SUPER + CTRL + right", hl.dsp.window.swap({ direction = "r" }))
hl.bind("SUPER + CTRL + up",    hl.dsp.window.swap({ direction = "u" }))
hl.bind("SUPER + CTRL + down",  hl.dsp.window.swap({ direction = "d" }))

-- Resize ───────────────────────────
hl.bind("SUPER + SHIFT + CTRL + left",  hl.dsp.window.resize({ x = -20, y = 0, relative = true }))
hl.bind("SUPER + SHIFT + CTRL + right", hl.dsp.window.resize({ x =  20, y = 0, relative = true }))
hl.bind("SUPER + SHIFT + CTRL + up",    hl.dsp.window.resize({ x =  0, y = -20, relative = true }))
hl.bind("SUPER + SHIFT + CTRL + down",  hl.dsp.window.resize({ x =  0, y =  20, relative = true }))

-- Workspaces ──────────────────────
hl.bind("SUPER + 1",       hl.dsp.focus({ workspace = 1 }))
hl.bind("SUPER + 2",       hl.dsp.focus({ workspace = 2 }))
hl.bind("SUPER + 3",       hl.dsp.focus({ workspace = 3 }))
hl.bind("SUPER + 4",       hl.dsp.focus({ workspace = 4 }))
hl.bind("SUPER + 5",       hl.dsp.focus({ workspace = 5 }))
hl.bind("SUPER + 6",       hl.dsp.focus({ workspace = 6 }))
hl.bind("SUPER + 7",       hl.dsp.focus({ workspace = 7 }))
hl.bind("SUPER + 8",       hl.dsp.focus({ workspace = 8 }))
hl.bind("SUPER + 9",       hl.dsp.focus({ workspace = 9 }))

-- Move windows to workspace ───────
hl.bind("SUPER + SHIFT + 1",  hl.dsp.window.move({ workspace = 1 }))
hl.bind("SUPER + SHIFT + 2",  hl.dsp.window.move({ workspace = 2 }))
hl.bind("SUPER + SHIFT + 3",  hl.dsp.window.move({ workspace = 3 }))
hl.bind("SUPER + SHIFT + 4",  hl.dsp.window.move({ workspace = 4 }))
hl.bind("SUPER + SHIFT + 5",  hl.dsp.window.move({ workspace = 5 }))
hl.bind("SUPER + SHIFT + 6",  hl.dsp.window.move({ workspace = 6 }))
hl.bind("SUPER + SHIFT + 7",  hl.dsp.window.move({ workspace = 7 }))
hl.bind("SUPER + SHIFT + 8",  hl.dsp.window.move({ workspace = 8 }))
hl.bind("SUPER + SHIFT + 9",  hl.dsp.window.move({ workspace = 9 }))

-- Cycle workspaces ────────────────
hl.bind("SUPER + mouse_down",  hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up",    hl.dsp.focus({ workspace = "e-1" }))

-- Special workspace (scratchpad) ──
hl.bind("SUPER + S",           hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind("SUPER + SHIFT + S",   hl.dsp.window.move({ workspace = "special:scratchpad" }))

-- Mouse binds ─────────────────────
hl.bind("SUPER + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273",  hl.dsp.window.resize(), { mouse = true })

-- Screenshots ─────────────────────
hl.bind("Print",               hl.dsp.exec_cmd("grimblast copy area"))                              -- Region → clipboard
hl.bind("SUPER + Print",       hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot-swappy.sh"))      -- Region → swappy → save
hl.bind("SUPER + SHIFT + Print",  hl.dsp.exec_cmd("grimblast copy output"))                         -- Full → clipboard

-- Clipboard manager ─────────────────
hl.bind("SUPER + C",           hl.dsp.exec_cmd("~/.config/hypr/scripts/cliphist-rofi.sh"))
hl.bind("SUPER + SHIFT + C",   hl.dsp.exec_cmd("cliphist wipe && notify-send 'Clipboard' 'History cleared'"))

-- Lock & exit ─────────────────────
hl.bind("SUPER + L",           hl.dsp.exec_cmd("hyprlock"))
hl.bind("SUPER + SHIFT + Q",   hl.dsp.exec_cmd("~/.config/hypr/scripts/power-menu.sh"))
hl.bind("SUPER + SHIFT + Escape",  hl.dsp.exec_cmd("hyprctl dispatch exit"))

-- Screenshot menu ─────────────────────
hl.bind("SUPER + D",           hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot-menu.sh"))

-- Media keys ─────────────────────────
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume raise --max-volume 150"), { repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume lower"),                { repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"))
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"))
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("swayosd-client --playerctl next"))
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("swayosd-client --playerctl previous"))
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("swayosd-client --playerctl play-pause"))
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("swayosd-client --brightness raise"),                  { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"),                 { repeating = true })     
-- Sourced via require("rules")

-- Float-only windows ──────────────
hl.window_rule({ match = { class = "pavucontrol" },        float = true, center = true })
hl.window_rule({ match = { class = "blueman-manager" },     float = true })
hl.window_rule({ match = { class = "nm-connection-editor" }, float = true })
hl.window_rule({ match = { class = "hyprpicker" },          float = true })
hl.window_rule({ match = { class = "imv" },                  float = true })
hl.window_rule({ match = { class = "mpv" },                  float = true })
hl.window_rule({ match = { class = "xdg-desktop-portal" },   float = true })

-- Browser PiP
hl.window_rule({
  match  = { class = "firefox", title = "Picture-in-Picture" },
  float  = true,
  size   = { 400, 300 },
})

-- Fixed workspace assignments ─────
hl.window_rule({ match = { class = "firefox" },   workspace = 1 })
hl.window_rule({ match = { class = "zen" },       workspace = 1 })
hl.window_rule({ match = { class = "chromium" },  workspace = 1 })
-- hl.window_rule({ match = { initial_class = "kitty" }, workspace = 2 })

-- Smart gaps (no gaps when single) ─
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, rounding   = 0 })
