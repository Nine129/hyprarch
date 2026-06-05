# CGGX Hyprland Setup

> A documented, opinionated Hyprland rice based on the CGGX style
> (red/cyan/lime/orange palette on dark background).

## Related Documents

- **[SETUP-GUIDE.md](./SETUP-GUIDE.md)** — Step-by-step from fresh Arch install to full desktop
- **[ECOSYSTEM-SETUP.md](./ECOSYSTEM-SETUP.md)** — Hyprpaper, SwayNC, Kitty, Fastfetch, Screenshots, SwayOSD, Zsh, Clipboard
- **[README.md](./README.md)** — Project overview, quick start, folder structure, keybinds reference
- **[WAYBAR-SETUP.md](./WAYBAR-SETUP.md)** — Waybar configuration, styling, modules, and resolved decisions
- **[ROFI-SETUP.md](./ROFI-SETUP.md)** — Rofi theming, widget hierarchy, installation, decisions
- **[ECOSYSTEM-SETUP.md](./ECOSYSTEM-SETUP.md)** — Hyprpaper, SwayNC, Kitty, Fastfetch, Zsh setup guides
- **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)** — Common issues and fixes for all tools

---

## 1. Installation

### Arch Linux

```bash
sudo pacman -S hyprland           # stable release
# or
yay -S hyprland-git               # bleeding-edge git HEAD
```

Hyprland 0.55+ uses **Lua** for configuration — `~/.config/hypr/hyprland.lua`.
The old hyprlang syntax was deprecated in 0.55. If you are on an older version,
check the 0.54 wiki. For all new installs, use Lua.

### Dependencies

Hyprland requires a C++26 capable compiler (gcc ≥ 15 or clang ≥ 19).
It also auto-pulls: `aquamarine`, `hyprlang`, `hyprcursor`, `hyprutils`,
`hyprgraphics`, `hyprwayland-scanner` (build-only).

### NVIDIA Users

**Not applicable for this setup (Intel GPU).** If switching to NVIDIA later:

```bash
# kernel parameters: nvidia_drm.modeset=1
# env in ~/.config/uwsm/env:
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
```

---

## 2. Configuration Structure

```
~/.config/hypr/
├── hyprland.lua          # Main entry — monitors, input, binds, exec autostart
├── settings.lua          # hl.config() — general, decoration, blur, shadow
├── binds.lua             # All keybinds + mouse binds
├── rules.lua             # Window rules + workspace rules
├── animations.lua        # Curves + animation blocks
└── env                   # uwsm env file (NOT Lua)
~/.config/uwsm/
└── env                   # Environment variables (GTK, Qt, XDG, cursor)
```

### 2.1 Lua config basics

All Lua config uses the `hl.*` API. Key functions:

| Function | Purpose |
|----------|---------|
| `hl.config({...})` | Set general/decoration variables |
| `hl.bind(key, dispatcher, flags?)` | Keybinds |
| `hl.monitor({...})` | Monitor definitions |
| `hl.window_rule({...})` | Per-window rules |
| `hl.workspace_rule({...})` | Per-workspace rules |
| `hl.animation({...})` | Animation config |
| `hl.curve(name, {...})` | Custom bezier/spring curves |
| `hl.on(event, function)` | Event callbacks (autostart, hotplugs) |
| `hl.exec_cmd(cmd)` | Spawn async process |
| `hl.dispatch(dispatcher)` | Trigger a dispatcher |
| `hl.env(key, value)` | Set env vars (only if NOT using uwsm) |
| `hl.notification.create({...})` | Show a notification |

### 2.2 Using uwsm

uwsm manages the user's Wayland session via systemd. It:

- Sets `XDG_*` env vars automatically
- Provides proper session lifecycle (start → stop → cleanup)
- Manages environment variables via `~/.config/uwsm/env`

**Start Hyprland with uwsm:**
```
uwsm start hyprland
```

**Environment variables go in `~/.config/uwsm/env`**, NOT in `hyprland.lua`:

```
# ~/.config/uwsm/env
export XCURSOR_SIZE=24
export XCURSOR_THEME=Bibata-Modern-Ice

export GTK_THEME=Colloid-Red-Dark
export GTK_ICON_THEME=Papirus-Dark

export QT_QPA_PLATFORM=wayland;xcb
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_AUTO_SCREEN_SCALE_FACTOR=1

export GDK_BACKEND=wayland
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1
export MOZ_ENABLE_WAYLAND=1
```

**Shutdown:** use `hyprshutdown` (not the `exit` dispatcher) for clean teardown.

---

## 3. Monitor

```
hyprctl monitors all   # list monitors with names and capabilities
```

Monitor auto-detection (fallback for any unlisted display):

```lua
hl.monitor({
  output = "desc:...",    -- or just "" for fallback
  mode = "preferred",
  position = "auto",
  scale = 1,
})
```

For this setup: 1920×1080@60, single display, scale 1.

---

## 4. Input

### Keyboard

US layout. CapsLock remapped to Ctrl via `keyd` — keyd config goes in
`/etc/keyd/default.conf` and runs as a systemd service.

```lua
hl.config({
  input = {
    kb_layout = "us",
    follow_mouse = 1,
    sensitivity = 0,        -- no mouse acceleration
  },
})
```

### Mouse

External mouse only (touchpad disabled). No acceleration.

---

## 5. Workspaces

9 workspaces. Binds: `SUPER + 1..9` to switch, `SUPER + SHIFT + 1..9` to
move windows. No named workspaces (for now — can be added later).

**Workspace assignments:**
| WS | Usage | Example |
|----|-------|---------|
| 1 | Browser | Zen, Firefox, Chromium |
| 2 | Dev terminal | Kitty — project work |
| 3 | Editor terminal | Kitty + Neovim |
| 4-9 | General | Anything |

---

## 6. Layout (Dwindle)

Dwindle is a BSPWM-like binary-tree tiling layout.

```lua
hl.config({
  dwindle = {
    force_split                  = 0,     -- 0=follow mouse
    preserve_split               = false,
    smart_split                  = false,  -- set true for cursor-aware splits
    smart_resizing               = true,
    permanent_direction_override = false,
    special_scale_factor         = 1,
    split_width_multiplier       = 1.0,
    use_active_for_splits        = true,
    default_split_ratio          = 1.0,   -- 1.0 = 50/50
    split_bias                   = 0,
    precise_mouse_move           = false,
  },
})
```

---

## 7. Decoration

### General

```lua
hl.config({
  decoration = {
    rounding          = 0,     -- no rounded corners (CGGX aesthetic)
    rounding_power    = 2.0,
    active_opacity   = 1.0,
    inactive_opacity = 0.85,
    fullscreen_opacity = 1.0,
    dim_inactive     = true,
    dim_strength     = 0.5,
  },
})
```

### Blur

```lua
hl.config({
  decoration = {
    blur = {
      enabled     = true,
      size        = 8,
      passes      = 2,
      vibrancy    = 0.18,
      new_optimizations = true,
      xray        = false,   -- set true if floating windows overhead is high
      noise       = 0.0117,
      contrast    = 0.8916,
      brightness  = 0.8172,
    },
  },
})
```

### Shadows

```lua
hl.config({
  decoration = {
    shadow = {
      enabled       = true,
      range         = 12,
      render_power  = 3,
      color         = "rgba(ff2d5540)",   -- CGGX red-tinted shadow
      scale         = 1.0,
    },
  },
})
```

---

## 8. Animations

Bouncy spring-based animations:

```lua
-- Curves
hl.curve("bouncy", {
  type = "spring",
  mass = 1,
  stiffness = 70,
  dampening = 10,
})

hl.curve("smooth", {
  type = "bezier",
  points = { {0.25, 0.1}, {0.25, 1.0} },
})

-- Animations
hl.animation({ leaf = "windows",     enabled = true, speed = 8,  curve = "bouncy", style = "popin 80%" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 8,  curve = "bouncy", style = "popin 80%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 8,  curve = "bouncy", style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 10, curve = "smooth" })
hl.animation({ leaf = "fade",        enabled = true, speed = 5 })
hl.animation({ leaf = "fadeIn",      enabled = true, speed = 5 })
hl.animation({ leaf = "fadeOut",     enabled = true, speed = 5 })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 8,  curve = "bouncy", style = "slide" })
hl.animation({ leaf = "border",      enabled = true, speed = 8 })
```

**Animation tree:**
```
global
├─ windows (style: slide, popin, gnomed)
│  ├─ windowsIn
│  ├─ windowsOut
│  └─ windowsMove
├─ layers (style: slide, popin, fade)
│  ├─ layersIn
│  └─ layersOut
├─ fade
│  ├─ fadeIn / fadeOut / fadeSwitch / fadeShadow / fadeDim
│  ├─ fadeLayers → fadeLayersIn / fadeLayersOut
│  ├─ fadePopups → fadePopupsIn / fadePopupsOut
│  └─ fadeDpms
├─ border / borderangle
├─ workspaces (style: slide, slidevert, fade, slidefade, slidefadevert)
│  ├─ workspacesIn / workspacesOut
│  └─ specialWorkspace → specialWorkspaceIn / specialWorkspaceOut
└─ zoomFactor / monitorAdded
```

---

## 9. Window Rules

### Float-only (never tile)

| Class | Reason |
|-------|--------|
| `pavucontrol` | Audio mixer — tiny window |
| `blueman-manager` | Bluetooth manager |
| `nm-connection-editor` | Network settings |
| `hyprpicker` | Color picker |
| `imv` | Image viewer |
| `mpv` | Video player |
| `firefox` with `Picture-in-Picture` title | PiP windows |
| `xdg-desktop-portal-*` | File picker dialogs |

```lua
-- Example rule:
hl.window_rule({
  match = { class = "pavucontrol" },
  float = true,
  move = { "center" },
  size = { 800, 600 },
})
```

### Expressions

For move/size rules you can use expressions:
```
move = { "cursor_x - window_w * 0.5", "cursor_y - window_h * 0.5" }
size = { "monitor_w * 0.5", "monitor_h * 0.5" }
```

Available variables: `monitor_w`, `monitor_h`, `window_x`, `window_y`,
`window_w`, `window_h`, `cursor_x`, `cursor_y`.

### Smart gaps (no gaps when single window)

```lua
hl.workspace_rule({ workspace = "w[tv1]",  gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]",    gaps_out = 0, gaps_in = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 0, rounding = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" },   border_size = 0, rounding = 0 })
```

---

## 10. Keybinds

### Modifier

`SUPER` (Windows key).

### Essential binds

| Keys | Action |
|------|--------|
| `SUPER + Q` | Open Kitty |
| `SUPER + Super_L` (release) | Custom Rofi launcher (category-colored, Pango markup) |
| `SUPER + A` | Open Vivaldi browser |
| `SUPER + E` | Open kitty + yazi file manager |
| `SUPER + W` | Close window (killactive) |
| `SUPER + F` | Fullscreen toggle |
| `SUPER + X` | Float toggle |
| `SUPER + V` | Clipboard history picker |
| `SUPER + P` | Pseudo-tile toggle |
| `SUPER + J` | Toggle split direction |
| `SUPER + Tab` | Focus last window |
| `SUPER + arrows` | Move focus |
| `SUPER + SHIFT + arrows` | Move window |
| `SUPER + CTRL + arrows` | Swap window |
| `SUPER + SHIFT + CTRL + arrows` | Resize window |
| `SUPER + 1..9` | Switch workspace |
| `SUPER + SHIFT + 1..9` | Move window to workspace |
| `SUPER + mouse_down/up` | Cycle workspaces |
| `SUPER + S` | Toggle special workspace (scratchpad) |
| `SUPER + SHIFT + S` | Move to special workspace |
| `SUPER + mouse:272` | Drag window (floating) |
| `SUPER + mouse:273` | Resize window (floating) |
| `SUPER + Print` | Screenshot region → swappy markup → auto-save |
| `SUPER + SHIFT + Print` | Screenshot full → clipboard |
| `SUPER + D` | Screenshot menu (full/region/swappy/clipboard) |
| `Print` | Screenshot region → clipboard |
| `SUPER + L` | Lock screen (hyprlock) |
| `SUPER + SHIFT + Q` | Power menu (wlogout — shutdown/reboot/lock/logout/suspend) |
| `SUPER + SHIFT + Escape` | Exit Hyprland |
| `SUPER + C` | Clipboard history picker |
| `SUPER + SHIFT + C` | Clear clipboard history |

### Media keys

| Key | Action |
|-----|--------|
| `XF86AudioRaiseVolume` | `wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+` |
| `XF86AudioLowerVolume` | `wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-` |
| `XF86AudioMute` | `wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle` |
| `XF86AudioNext/Prev` | `playerctl next/previous` |
| `XF86AudioPlay/Pause` | `playerctl play-pause` |
| `XF86MonBrightnessUp/Down` | `brightnessctl s +5%-/5%-` |

---

## 11. Autostart

Most daemons are managed by **systemd user services** for crash resilience:

```lua
hl.on("hyprland.start", function()
  -- Managed by systemd user services:
  -- waybar, hyprpaper, hypridle, swaync, cliphist

  hl.exec_cmd("swayosd-server")                     -- On-screen display (volume/brightness)
  hl.exec_cmd("nm-applet")                          -- NetworkManager tray icon
  hl.exec_cmd("blueman-applet")                     -- Bluetooth tray icon
  hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
  -- Wallpaper set via IPC (hyprpaper v0.8.4 config preload doesn't work at startup)
  hl.exec_cmd("hyprctl hyprpaper wallpaper eDP-1,/home/nine/.local/share/wallpapers/cggx.webp")
end)
```

> See [SETUP-GUIDE.md §7.2](./SETUP-GUIDE.md#72-hyprland-user-services-recommended) for systemd service setup.

---

## 12. Ecosystem Tools

### Package list

```bash
# Core
sudo pacman -S hyprland hyprpaper hyprlock hypridle hyprpicker
sudo pacman -S waybar rofi-wayland
sudo pacman -S kitty swaync grim slurp swappy jq
sudo pacman -S wl-clipboard cliphist yazi
sudo pacman -S xdg-desktop-portal-hyprland xdg-desktop-portal-gtk polkit-gnome
sudo pacman -S nm-applet brightnessctl
sudo pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-jetbrains-mono-nerd
sudo pacman -S pipewire wireplumber btop fastfetch neovim zsh starship

# AUR
yay -S swayosd-git grimblast-git vivaldi bibata-cursor-theme colloid-icon-theme
```

### Notes on each

| Tool | Config file | Notes |
|------|-------------|-------|
| **waybar** | `~/.config/waybar/style.css` + `config.jsonc` | Transparent bar, floating pill modules |
| **rofi** | `~/.config/rofi/config.rasi` | CGGX theme, red accent, sharp corners |
| **kitty** | `~/.config/kitty/kitty.conf` | JetBrainsMono Nerd Font, CGGX colors |
| **swaync** | `~/.config/swaync/config.json` + `style.css` | Notification daemon + control center panel |
| **hyprpaper** | `~/.config/hypr/hyprpaper.conf` | Static wallpaper with dim overlay |
| **hyprlock** | `~/.config/hypr/hyprlock.conf` | Lock screen matching CGGX style |
| **hypridle** | `~/.config/hypr/hypridle.conf` | DPMS + lock on idle |
| **wlogout** | `~/.local/bin/wlogout` | Power menu (called via wlogout-toggle.sh) |
| **grim** | — | Screenshots via keybinds (grimblast from AUR) |
| **swayosd** | `~/.config/swayosd/style.css` | Volume/brightness OSD overlay |
| **swappy** | `~/.config/swappy/config` | Screenshot annotation auto-save |
| **yazi** | `~/.config/yazi/yazi.toml` | Terminal file manager |
| **nwg-look** | — | GTK theme preview/apply |

### xdg-desktop-portal

Must be running for native file pickers and screen sharing.
The hyprland portal must be the default:

```bash
systemctl --user enable --now xdg-desktop-portal-hyprland
```

### Theme chain

```
GTK apps ──► colloid-icon-theme/Papirus-Dark    ──► dark CGGX palette
Qt apps   ──► qt5ct (kvantum theme)               ──► same dark palette
Terminals ──► kitty.conf hardcoded colors          ──► CGGX palette
Waybar    ──► style.css custom colors              ──► CGGX palette
Rofi      ──► config.rasi colors                   ──► CGGX palette
```

---

## 13. CGGX Color Palette

| Role | Hex | Usage |
|------|-----|-------|
| Background | `#0a0a0c` | Base surface |
| Surface | `#1a1a20` | Module backgrounds, panel surfaces |
| Surface2 | `#262630` | Slightly lighter surface |
| Red | `#ff2d55` | Active workspace, urgent, accents |
| Cyan | `#00e5ff` | Clock, network, secondary accents |
| Lime | `#c8ff00` | Disk, battery, success states |
| Orange | `#ff6b00` | Memory, pulseaudio, warnings |
| Silver | `#e8e8f0` | Primary text, workspace labels |
| Muted | `#6a6a80` | Secondary text, dimmed elements |
| Border | `#2a2a35` | Window borders, dividers |

---

## 14. Config Card Summary

The showcase page (`hyprland-rice-showcase.html`) documents the following files:

| File | Tab | Status |
|------|-----|--------|
| `~/.config/hypr/hyprland.lua` | Hyprland | ✅ Lua config |
| `~/.config/hypr/settings.lua` | Hyprland | ✅ Lua config |
| `~/.config/hypr/binds.lua` | Hyprland | ✅ Lua config |
| `~/.config/hypr/rules.lua` | Hyprland | ✅ Lua config |
| `~/.config/hypr/animations.lua` | Hyprland | ✅ Lua config |
| `~/.config/hypr/hyprpaper.conf` | Hyprpaper | ✅ Done |
| `~/.config/waybar/style.css` | Waybar | ✅ Done |
| `~/.config/waybar/config.jsonc` | Waybar | ✅ Done |
| `~/.config/waybar/modules/cggx.jsonc` | Waybar | ✅ Done |
| `~/.config/waybar/colors/cggx.css` | Waybar | ✅ Done |
| `~/.config/kitty/kitty.conf` | Kitty | ✅ Done |
| `~/.config/swaync/config.json` + `style.css` | SwayNC | ✅ Done |
| `~/.config/rofi/config.rasi` | Rofi | ✅ Done |
| `~/.config/fastfetch/config.jsonc` | Fastfetch | ✅ Done |
| `~/.config/neovim/init.lua` | Neovim | ✅ Done |
| `~/.zshenv` | Shell (Zsh) | ✅ Done |
| `~/.zshrc` | Shell (Zsh) | ✅ Done |

---

## 16. Full Ecosystem Deployment

Copy the configs from the `configs/` folder to your home directory:

```bash
# Hyprland
cp -r configs/hypr/* ~/.config/hypr/

# Waybar
mkdir -p ~/.config/waybar/modules ~/.config/waybar/colors
cp configs/waybar/style.css ~/.config/waybar/
cp configs/waybar/config.jsonc ~/.config/waybar/
cp configs/waybar/modules/cggx.jsonc ~/.config/waybar/modules/
cp configs/waybar/colors/cggx.css ~/.config/waybar/colors/

# Kitty
mkdir -p ~/.config/kitty
cp configs/kitty/kitty.conf ~/.config/kitty/

# SwayNC
mkdir -p ~/.config/swaync
cp configs/swaync/style.css ~/.config/swaync/
cp configs/swaync/config.json ~/.config/swaync/

# Rofi
mkdir -p ~/.config/rofi
cp configs/rofi/config.rasi ~/.config/rofi/

# Fastfetch
mkdir -p ~/.config/fastfetch
cp configs/fastfetch/config.jsonc ~/.config/fastfetch/

# Shell
cp configs/shell/.zshenv ~/
cp configs/shell/.zshrc ~/

# Wallpaper
mkdir -p ~/.local/share/wallpapers
cp wallpapers/cggx.webp ~/.local/share/wallpapers/

# Clipboard script
mkdir -p ~/.config/hypr/scripts
# Hyprland user scripts
mkdir -p ~/.config/hypr/scripts
cp configs/hypr/scripts/*.sh ~/.config/hypr/scripts/
chmod +x ~/.config/hypr/scripts/*.sh

# Cliphist config
mkdir -p ~/.config/cliphist
cp configs/cliphist/config ~/.config/cliphist/
```

# Swappy config
mkdir -p ~/.config/swappy
cp configs/swappy/config ~/.config/swappy/

# SwayOSD
mkdir -p ~/.config/swayosd
cp configs/swayosd/style.css ~/.config/swayosd/

# Screenshot script
cp configs/hypr/scripts/screenshot-swappy.sh ~/.config/hypr/scripts/
chmod +x ~/.config/hypr/scripts/screenshot-swappy.sh

After copying, reload everything:
```bash
# Hyprland
hyprctl reload config

# Hyprpaper
killall hyprpaper; hyprpaper &

# Waybar
killall waybar; waybar &

# SwayNC (reload config + css)
swaync-client --reload-config
swaync-client --reload-css

# Kitty (auto-reloads)
kitty @ load-config

# Zsh
source ~/.zshrc
```

> For detailed ecosystem guides (Hyprpaper, SwayNC, Kitty, Fastfetch, Zsh), see
> **[ECOSYSTEM-SETUP.md](./ECOSYSTEM-SETUP.md)**.
>
> Having issues? Check **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)**.

---

## 15. References

- [Hyprland Wiki — Configuring Start](https://wiki.hypr.land/Configuring/Start)
- [Hyprland Wiki — Variables](https://wiki.hypr.land/Configuring/Basics/Variables)
- [Hyprland Wiki — Monitors](https://wiki.hypr.land/Configuring/Basics/Monitors)
- [Hyprland Wiki — Binds](https://wiki.hypr.land/Configuring/Basics/Binds)
- [Hyprland Wiki — Dispatchers](https://wiki.hypr.land/Configuring/Basics/Dispatchers)
- [Hyprland Wiki — Window Rules](https://wiki.hypr.land/Configuring/Basics/Window-Rules)
- [Hyprland Wiki — Workspace Rules](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules)
- [Hyprland Wiki — Animations](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations)
- [Hyprland Wiki — Autostart](https://wiki.hypr.land/Configuring/Basics/Autostart)
- [Hyprland Wiki — Environment Variables](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables)
- [Hyprland Wiki — Expanding Functionality](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Expanding-functionality)
- [Hyprland Wiki — Dwindle Layout](https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout)
- [Hyprland Wiki — Installation](https://wiki.hypr.land/Getting-Started/Installation)
- [Showcase HTML](hyprland-rice-showcase.html)
- [Waybar import reference](waybar-import/)
- [ECOSYSTEM-SETUP.md](./ECOSYSTEM-SETUP.md)
- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

---

*Generated 2026-05-31 during a grill-me session with Pi agent.*
