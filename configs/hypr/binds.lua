-- ── CGGX Rice — Keybinds ────────────────
-- Sourced via require("binds")
-- Mod: SUPER (Windows key)
local vivaldi_launching = false

-- Terminal ─────────────────────────
hl.bind("SUPER + Q",       hl.dsp.exec_cmd("kitty --single-instance"))
hl.bind("SUPER + B",       hl.dsp.exec_cmd("kitty --single-instance -e btop"))

hl.bind("SUPER + W",       hl.dsp.window.close())
hl.bind("SUPER + SHIFT + Q", hl.dsp.exec_cmd("bash ~/hyprarch/configs/hypr/scripts/kitty-float.sh"))
hl.bind("SUPER + Backspace", hl.dsp.exec_cmd("pkill otter-launcher || bash ~/hyprarch/configs/hypr/scripts/kitty-float.sh --class otter-launcher -- otter-launcher"))
hl.bind("SUPER + R", hl.dsp.exec_cmd("kitty --single-instance -e nvim"))
hl.bind("SUPER + D", hl.dsp.exec_cmd("rmpc togglepause"))
hl.bind("SUPER + period", hl.dsp.exec_cmd("rmpc next"))
hl.bind("SUPER + comma", hl.dsp.exec_cmd("rmpc prev"))

hl.bind("SUPER + T", hl.dsp.exec_cmd("pkill wiremix || bash ~/hyprarch/configs/hypr/scripts/kitty-float.sh --class wiremix-float -- wiremix"))
hl.bind("SUPER + I", hl.dsp.exec_cmd("pkill wlctl || bash ~/hyprarch/configs/hypr/scripts/kitty-float.sh --class wlctl-float -- wlctl"))
hl.bind("SUPER + C", hl.dsp.exec_cmd("bash ~/hyprarch/configs/hypr/scripts/kitty-float.sh -d ~/Assistant -- omp"))

hl.bind("SUPER + SHIFT +E",     hl.dsp.exec_cmd("pkill -c filepicker || bash ~/hyprarch/configs/hypr/scripts/kitty-float.sh --class filepicker -- yazi"))

-- Launcher ────────────────────────
hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd("pkill fuzzel || fuzzel"),  { release = true })  
hl.bind("SUPER + E",     hl.dsp.exec_cmd("kitty --single-instance --class yazi -e yazi"))
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("pkill latuicon || ~/.config/hypr/scripts/emoji-picker.sh"))
hl.bind("SUPER + A", hl.dsp.exec_cmd("vivaldi --new-window vivaldi://startpage/"))
-- Layout ──────────────────────────
hl.bind("SUPER + F",       hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind("SUPER + X", function()
  local ws = hl.get_active_workspace()
  local w = hl.get_active_window()
  if not ws or not w then
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    return
  end
  -- single window on workspace and currently tiled → float to smaller centered window
  if #ws:get_windows() == 1 and not w.floating then
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.resize({ x = 1200, y = 750 }))
    hl.dispatch(hl.dsp.window.center())
  else
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
  end
end)
hl.bind("SUPER + P",       hl.dsp.exec_cmd("~/.config/hypr/scripts/zen-mode.sh"))
hl.bind("SUPER + J",       hl.dsp.layout("togglesplit"))
hl.bind("SUPER + Y", function()
  local cur = hl.get_config("general:layout")
  if cur == "scrolling" then
    hl.config({ general = { layout = "dwindle" } })
  else
    hl.config({ general = { layout = "scrolling" } })
  end
end)
hl.bind("SUPER + V", hl.dsp.exec_cmd("pkill fuzzel ||bash -c 'WAYLAND_DISPLAY=wayland-1 bash ~/hyprarch/configs/hypr/scripts/cliphist-fuzzel.sh'"))
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
hl.bind("SUPER + minus",  hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
hl.bind("SUPER + equal", hl.dsp.window.resize({ x =  50, y = 0, relative = true }))
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
hl.bind("SUPER + Print",       hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot-menu.sh"))         -- Region → screenshot menu
hl.bind("SUPER + SHIFT + Print",  hl.dsp.exec_cmd("grimblast copy output"))                         -- Full → clipboard
hl.bind("SUPER + ALT + Print", hl.dsp.exec_cmd("~/.config/hypr/scripts/lens-search.sh"))     -- Region → Google Lens search

-- Clipboard manager and rmpc i guess ─────────────────
hl.bind("SUPER + Z",           hl.dsp.exec_cmd("kitty --single-instance rmpc"))
hl.bind("SUPER + SHIFT + C",   hl.dsp.exec_cmd("cliphist wipe && notify-send 'Clipboard' 'History cleared'"))

-- Lock & exit ─────────────────────
hl.bind("SUPER + L",           hl.dsp.exec_cmd("hyprlock"))
hl.bind("SUPER + CTRL + Q",   hl.dsp.exec_cmd("pkill wlogout || wlogout --css ~/.config/wlogout/style.css --buttons-per-row 5 -T 410 -B 410 -L 200 -R 200"))
hl.bind("SUPER + SHIFT + Escape",  hl.dsp.exec_cmd("hyprctl dispatch exit"))

-- Screenshot menu ─────────────────────
hl.bind("CTRL + Print",           hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot-menu.sh"))

-- Media keys ─────────────────────────
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("~/hyprarch/scripts/osd-notify.sh volume raise"),  { repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("~/hyprarch/scripts/osd-notify.sh volume lower"),  { repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("~/hyprarch/scripts/osd-notify.sh volume mute-toggle"))
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("~/hyprarch/scripts/osd-notify.sh source mute-toggle"))
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("swayosd-client --playerctl next"))
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("swayosd-client --playerctl previous"))
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("swayosd-client --playerctl play-pause"))
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("~/hyprarch/scripts/osd-notify.sh brightness raise"),  { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("~/hyprarch/scripts/osd-notify.sh brightness lower"), { repeating = true })
hl.bind("SUPER + g", function()
    hl.plugin.scrolloverview.overview("toggle")
end)


