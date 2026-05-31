# CGGX Ecosystem Setup

> Companion guide covering the smaller ecosystem tools:
> **Hyprpaper** · **SwayNC** · **Kitty** · **Fastfetch** · **Screenshots** · **Zsh**

---

## Table of Contents

- [1. Hyprpaper](#1-hyprpaper)
- [2. SwayNC](#2-swaync)
- [3. Kitty](#3-kitty)
- [4. Fastfetch](#4-fastfetch)
- [6. Zsh](#6-zsh)

---

## 1. Hyprpaper

### Overview

Hyprpaper is a wallpaper daemon for Hyprland. Since v0.8.4 it uses **hyprlang** config format (same syntax as Hyprland's old config system).

**Important:** The old `preload` / `wallpaper = monitor,path` / `unload` syntax was **removed** in 0.8.4. Use the special-category block format below.

### File location

```
~/.config/hypr/hyprpaper.conf
```

### Config

```conf
splash = false
ipc   = true

wallpaper = eDP-1 {
    path     = ~/.local/share/wallpapers/cggx.webp
    fit_mode = cover
}
```

### Options

| Option | Values | Default | Description |
|--------|--------|---------|-------------|
| `splash` | `true` / `false` | `false` | Show "Welcome to Hyprland" text |
| `ipc` | `true` / `false` | `true` | Allow runtime switching via `hyprctl hyprpaper` |
| `wallpaper` | *(special category)* | — | Wallpaper entry keyed by monitor name |

**Wallpaper block fields:**

| Field | Values | Default | Description |
|-------|--------|---------|-------------|
| `path` | file path | — | Image file or directory (supports `~`) |
| `fit_mode` | `cover`, `fill`, `tile`, `contain` | `cover` | How the image fits the screen |
| `timeout` | seconds | `0` | Slideshow interval (0 = static) |
| `order` | `default`, `random`, `random-shuffle` | `default` | Image selection order |
| `recursive` | `0` / `1` | `0` | Scan subdirectories for images |

### Commands

```bash
# Start
hyprctl dispatch exec hyprpaper

# Reload
killall hyprpaper; hyprpaper &

# Switch wallpaper at runtime
hyprctl hyprpaper wallpaper "eDP-1,~/.local/share/wallpapers/cggx.webp"

# List preloaded
hyprctl hyprpaper listloaded
```

### Multiple monitors

Add more `wallpaper` blocks for each monitor:

```conf
wallpaper = DP-1 {
    path     = ~/wallpapers/desktop.webp
    fit_mode = cover
}
wallpaper = eDP-1 {
    path     = ~/wallpapers/laptop.webp
    fit_mode = cover
}
```

---

## 2. SwayNC

### Overview

**SwayNotification Center (swaync)** is the current meta for notification daemons on Hyprland. It doubles as a **control center panel** that can be summoned from Waybar — showing notifications, media playback controls (MPRIS), Do Not Disturb toggle, and more.

Unlike Dunst which only pushes popups, swaync provides both **floating notification popups** *and* a **pull-down panel** with widgets.

### Dependencies

```bash
sudo pacman -S swaync
```

### File location

```
~/.config/swaync/config.json   # JSON configuration
~/.config/swaync/style.css      # GTK CSS theme
```

### Architecture

| Component | Role |
|-----------|------|
| `swaync` | Background daemon — shows popups + control center |
| `swaync-client` | CLI for toggling panel, reloading config, DND, inhibition |

`swaync` is started once in `hyprland.lua` autostart. Hot-reload with:

```bash
swaync-client --reload-config   # Reload config.json
swaync-client --reload-css      # Reload style.css
swaync-client -t -sw            # Toggle control center panel
swaync-client -d -sw            # Toggle Do Not Disturb
```

### Config (`config.json`)

```jsonc
{
  // Position
  "positionX": "right",
  "positionY": "top",
  "layer": "overlay",

  // Control center
  "control-center-exclusive-zone": false,
  "control-center-width": 400,
  "control-center-height": 600,

  // Notifications
  "notification-window-width": 400,
  "timeout": 10,
  "timeout-low": 5,
  "timeout-critical": 0,
  "notification-grouping": true,
  "notification-2fa-action": false,
  "image-visibility": "when-available",
  "hide-on-action": true,

  // Widgets
  "widgets": ["title", "dnd", "mpris", "notifications"],
  "widget-config": {
    "title": { "text": "Notifications", "clear-all-button": true },
    "mpris": { "autohide": true, "show-album-art": "always" }
  }
}
```

**Key settings explained:**

| Setting | Our value | Why |
|---------|-----------|-----|
| `positionX` / `positionY` | `right` / `top` | Notifications appear in top-right corner |
| `control-center-exclusive-zone` | `false` | Panel overlays Waybar (not pushed aside) |
| `hide-on-action` | `true` | Auto-close panel when clicking a notification |
| `timeout-critical` | `0` | Critical notifications persist until dismissed |
| `notification-grouping` | `true` | Groups notifications by app name |
| `widgets` | title, dnd, mpris, notifications | Clean panel with media player |

### Theme (`style.css`)

swaync uses **CSS custom properties** (CSS variables) for theming. The default SCSS is compiled with CSS variables, so a simple `:root` override is all you need.

```css
:root {
  --cc-bg: rgba(10, 10, 12, 0.85);

  --noti-border-color: rgba(255, 45, 85, 0.2);
  --noti-bg: 26, 26, 32;
  --noti-bg-alpha: 0.88;
  --noti-bg-darker: rgb(15, 15, 20);
  --noti-bg-hover: rgb(36, 36, 44);
  --noti-bg-focus: rgba(255, 45, 85, 0.15);
  --noti-close-bg: rgb(42, 42, 52);
  --noti-close-bg-hover: rgb(255, 45, 85);

  --text-color: #e8e8f0;
  --text-color-disabled: #6a6a80;
  --bg-selected: rgb(255, 45, 85);

  --border: 1px solid rgba(255, 45, 85, 0.2);
  --border-radius: 0;
}
```

**Theme highlights:**

| Variable | Value | Effect |
|----------|-------|--------|
| `--border-radius` | `0` | Sharp corners everywhere |
| `--cc-bg` | `rgba(10,10,12,0.85)` | Dark glass control center |
| `--noti-bg` / `--noti-bg-alpha` | `26,26,32` / `0.88` | Popup surface |
| `--noti-border-color` | `rgba(255,45,85,0.2)` | Red-tinted borders |
| `--bg-selected` | `rgb(255,45,85)` | Red accent for switches |
| `--text-color` | `#e8e8f0` | Silver text |
| `--text-color-disabled` | `#6a6a80` | Muted labels |
| `--noti-close-bg-hover` | `rgb(255,45,85)` | Close button turns red |

### Urgency levels

| Level | Visual treatment | Timeout | Use case |
|-------|-----------------|---------|----------|
| `low` | Normal surface | 5s | Volume, brightness, info |
| `normal` | Normal surface | 10s | Messages, updates |
| `critical` | Red border (`border: 1px solid rgba(255,45,85,0.6)`) | Persists | Errors, low battery |

### Notification visibility rules

In swaync, notification visibility is declared in `config.json` under `notification-visibility`:

```jsonc
"notification-visibility": {
  "screenshot": {
    "state": "transient",
    "app-name": "grim|slurp|swappy|flameshot"
  },
  "volume": {
    "state": "muted",
    "app-name": "pavucontrol|pulseaudio|PipeWire|swayosd-client"
  }
}
```

State values:
- `enabled` — show normally
- `transient` — shown but not saved to control center history
- `muted` — hidden entirely
- `ignored` — ignored by the daemon (won't even pop up)

### Control Center Panel

Press `SUPER + SHIFT + N` (or bind in Waybar) to toggle the panel:

```
┌──────────────────────────────────────┐
│  Notifications              [Clear]  │
│  Do Not Disturb              [OFF]   │
│                                      │
│  ┌─ Now Playing ──────────────────┐  │
│  │  ►  Never Gonna Give You Up    │  │
│  │     Rick Astley                │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌─ Notification 1 ───────────────┐  │
│  │  Slack    2 min ago        [×] │  │
│  │  New message from @user       │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘
```

The panel appears on the right side, overlaying the Waybar (due to `control-center-exclusive-zone: false`).

### Waybar integration

Add a notification module to Waybar to show unread count + toggle:

```jsonc
// In ~/.config/waybar/modules/cggx.jsonc
"custom/notification": {
  "tooltip": true,
  "format": "{icon}",
  "format-icons": {
    "notification": "",
    "none": "",
    "dnd-notification": "",
    "dnd-none": "",
    "inhibited-notification": "",
    "inhibited-none": "晴"
  },
  "return-type": "json",
  "exec": "swaync-client -swb",
  "on-click": "swaync-client -t -sw",
  "on-click-right": "swaync-client -d -sw",
  "escape": true
}
```

### Keybinds

In `configs/hypr/binds.lua`:

```lua
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t -sw"))  -- Toggle panel
```

### Waybar CSS

```css
#custom-notification {
  font-family: "JetBrainsMono Nerd Font";
}
```

### Commands

```bash
# Reload config
swaync-client --reload-config

# Reload CSS
swaync-client --reload-css

# Toggle panel
swaync-client -t -sw

# Toggle DND
swaync-client -d -sw

# Get notification count (JSON)
swaync-client -swb

# Inhibit notifications (e.g. during screen share)
swaync-client --inhibitor-add "reason"
swaync-client --inhibitor-remove "reason"

# Test notification
notify-send "CGGX Rice" "SwayNC working!" -u normal
```

### Troubleshooting

- **No popups appear** → is `swaync` running? `pgrep -x swaync`
- **Popups have rounded corners** → `--border-radius: 0` in `style.css` + `swaync-client --reload-css`
- **Panel won't open** → check `swaync-client -t -sw` in terminal for errors
- **Notifications don't group** → `notification-grouping: true` in config.json
- **Media controls not showing** → ensure `"mpris"` is in the `widgets` array

---

## 3. Kitty

### Overview

Kitty is a GPU-accelerated terminal emulator. Config is in `key = value` format.

### File location

```
~/.config/kitty/kitty.conf
```

### Font

```conf
font_family      Share Tech Mono
bold_font         auto
italic_font       auto
bold_italic_font  auto
font_size        10.0
```

The `Share Tech Mono` font must be installed from `ttf-share-tech-mono` (available in AUR) or `nerd-fonts` (which bundles it).

### CGGX 16-color palette

```
  color0/8   #0a0a0c / #2a2a35    Black / Dark gray
  color1/9   #ff2d55 / #ff2d55    Red
  color2/10  #c8ff00 / #c8ff00    Green / Lime
  color3/11  #ff6b00 / #ff6b00    Yellow / Orange
  color4/12  #00e5ff / #00e5ff    Blue / Cyan
  color5/13  #b48cff / #b48cff    Magenta / Purple
  color6/14  #00e5ff / #00e5ff    Cyan
  color7/15  #e8e8f0 / #e8e8f0    White / Silver
```

### Extended colors

| Setting | Value |
|---------|-------|
| `background` | `#0a0a0c` |
| `foreground` | `#e8e8f0` |
| `background_opacity` | `0.92` |
| `selection_foreground` | `#0a0a0c` |
| `selection_background` | `#ff2d55` |

### Keybinds

| Keys | Action |
|------|--------|
| `Ctrl+Shift+arrow` | Navigate split windows |
| `Ctrl+Shift+Enter` | New window (split) |
| `Ctrl+Shift+W` | Close window |
| `Ctrl+Shift+N` | New tab |
| `Ctrl+Shift+Q` | Close tab |
| `Ctrl+Shift+1-9` | Switch to tab N |
| `Ctrl+Shift+F` | Toggle stacks layout |
| `Ctrl+Shift+R` | Reload config |
| `Ctrl+Shift+Z` | Toggle fullscreen |

### Commands

```bash
# Reload config
kitty @ load-config

# Change theme visually
kitty +kitten themes

# View scrollback in pager
kitty +kitten show_hyperlinked_grep
```

---

## 4. Fastfetch

### Overview

Fastfetch is a system information tool (like Neofetch). Config is in JSONC format.

### File location

```
~/.config/fastfetch/config.jsonc
```

### Logo

```jsonc
"logo": {
  "type": "small",          // "auto", "small", "large", or image path
  "color": {
    "1": "red",             // Arch logo top — CGGX red
    "2": "cyan",            // Arch logo middle — CGGX cyan
    "3": "lime"             // Arch logo bottom — CGGX lime
  },
  "padding": { "right": 2 }
}
```

Valid named colors: `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`, `default`, and prefixed variants (`bright_red`, `light_cyan`, etc.).

### Modules

The config shows these sections:

| Module | Displays |
|--------|----------|
| `title` | `user@host` |
| `os` | OS name and version |
| `host` | Machine model |
| `kernel` | Kernel release |
| `uptime` | System uptime |
| `packages` | Package count (pacman, flatpak, etc.) |
| `shell` | Current shell |
| `wm` | Window manager |
| `wmtheme` | WM theme |
| `terminal` | Terminal emulator |
| `terminalfont` | Terminal font |
| `cpu` | CPU model and cores |
| `gpu` | GPU information |
| `memory` | RAM usage |
| `disk` | Disk usage |
| `battery` | Battery status |
| `localip` | Network IP |
| `bluetooth` | Bluetooth devices |
| `colors` | Color palette swatch |

### Commands

```bash
# Show system info
fastfetch

# Show with specific config
fastfetch --config ~/.config/fastfetch/config.jsonc

# List all modules
fastfetch --list-modules
```

---

## 5. Screenshots

### Overview

Screenshot pipeline using **grimblast** (Hyprland's grim/slurp wrapper) + **swappy** for annotation.

### Dependencies

```bash
sudo pacman -S grim slurp swappy jq wl-clipboard
```

`grimblast` is available in the AUR:
```bash
yay -S grimblast-git
```

### Keybinds

| Key | Command | Pipeline |
|-----|---------|----------|
| `Print` | `grimblast copy area` | Region → clipboard (paste anywhere) |
| `SUPER + Print` | `~/.config/hypr/scripts/screenshot-swappy.sh` | Region → clipboard → swappy → auto-save |
| `SUPER + SHIFT + Print` | `grimblast copy output` | Full screen → clipboard |

### Picker script

**`~/.config/hypr/scripts/screenshot-swappy.sh`:**

```bash
#!/usr/bin/env bash
# Captures a region, opens in swappy for annotation,
# then auto-saves to ~/Pictures/Screenshots/
set -euo pipefail

if ! grimblast copy area; then
  exit 0  # User cancelled (Esc)
fi

wl-paste | swappy -f -
```

### Swappy config

**`~/.config/swappy/config`:**

```ini
[Default]
save_dir=$HOME/Pictures/Screenshots
save_filename_format=screenshot-%Y-%m-%d-%H%M%S.png
show_panel=false
show_info=true
```

On save in swappy, the annotated image goes to `~/Pictures/Screenshots/screenshot-<timestamp>.png`.

### Zsh aliases

| Alias | Pipeline |
|-------|----------|
| `ss` | Region → swappy markup → `~/Pictures/Screenshots/` |
| `ss-full` | Full screen → swappy markup → `~/Pictures/Screenshots/` |
| `ss-window` | Active window → swappy markup → `~/Pictures/Screenshots/` |
| `ss-save` | Region → save directly to `~/Pictures/` (no markup) |

### Save location

All swappy-annotated screenshots:
```
~/Pictures/Screenshots/screenshot-2026-05-31-143022.png
```

Grimblast direct saves:
```
~/Pictures/2026-05-31-143022_grimblast_area.png
```

### Troubleshooting

- **`grimblast: command not found`** → install `grimblast-git` from AUR
- **Swappy opens but image is blank** → ensure `wl-paste` has content. Try `wl-paste | swappy -f -` manually
- **Screenshots not saving** → verify `~/.config/swappy/config` has `save_dir=$HOME/Pictures/Screenshots`
- **Esc doesn't cancel** → press Esc in the slurp overlay (not the terminal)

---

## 6. SwayOSD

### Overview

**swayosd** provides a subtle overlay when you press volume, brightness, mic-mute, or media keys. It's a GTK-based popup with a client-server architecture.

### Why swayosd over avizo

| Criteria | **swayosd** | avizo |
|----------|-------------|-------|
| Arch repo | `extra` (main) | AUR only |
| Theming | GTK CSS (`style.css`) | SVG-based |
| Features | Volume, brightness, caps-lock, playerctl, mic-mute | Volume, brightness only |
| Active dev | ✅ Active | Maintenance mode |

### Dependencies

```bash
sudo pacman -S swayosd
```

### File location

```
~/.config/swayosd/style.css
```

### Architecture

| Component | Role |
|-----------|------|
| `swayosd-server` | Background daemon — shows popup windows on demand |
| `swayosd-client` | CLI tool — triggers a popup by sending commands to the server |

`swayosd-server` is started in `hyprland.lua` autostart. Keybinds invoke `swayosd-client` to display the popup.

### Config (`style.css`)

The GTK CSS file at `~/.config/swayosd/style.css` controls the popup appearance.

```css
window#osd {
  border-radius: 0;              /* Sharp corners */
  border: none;
  background: rgba(10, 10, 12, 0.88);

  #container { margin: 16px 20px; }

  image, label { color: #e8e8f0; }

  progressbar:disabled,
  image:disabled { opacity: 0.35; }

  progressbar {
    min-height: 6px;
    border-radius: 0;
    background: transparent;
    border: none;
  }

  trough {
    min-height: inherit;
    border-radius: 0;
    border: none;
    background: #6a6a80;        /* Muted track */
  }

  progress {
    min-height: inherit;
    border-radius: 0;
    border: none;
    background: #ff2d55;        /* Red accent fill */
  }
}
```

**Design notes:**
- `border-radius: 0` everywhere — matches the CGGX sharp-corner aesthetic
- Transparent dark popup (`rgba(10,10,12,0.88)`)
- Silver text (`#e8e8f0`), red progress fill (`#ff2d55`), muted track (`#6a6a80`)
- Disabled indicators at 35% opacity

### Keybinds

All media keys now route through `swayosd-client` instead of raw `wpctl`/`brightnessctl`:

| Key | Client command | Effect |
|-----|----------------|--------|
| `XF86AudioRaiseVolume` | `--output-volume raise --max-volume 150` | Volume up (max 150%) |
| `XF86AudioLowerVolume` | `--output-volume lower` | Volume down |
| `XF86AudioMute` | `--output-volume mute-toggle` | Mute/unmute speakers |
| `XF86AudioMicMute` | `--input-volume mute-toggle` | Mute/unmute mic |
| `XF86AudioNext` | `--playerctl next` | Next track |
| `XF86AudioPrev` | `--playerctl previous` | Previous track |
| `XF86AudioPlay` | `--playerctl play-pause` | Play/pause |
| `XF86MonBrightnessUp` | `--brightness raise` | Brightness up |
| `XF86MonBrightnessDown` | `--brightness lower` | Brightness down |

### Popup appearance

```
┌──────────────────────────────┐
│  🔊 ████████░░░░░░  75%      │
└──────────────────────────────┘
```

- Icon matches the action (🔊 volume, ☀ brightness, 🎵 playback)
- Progress bar with red fill (`#ff2d55`) on muted track (`#6a6a80`)
- Sharp corners everywhere
- Appears centered onscreen, auto-dismisses after ~1.5s

### Tips

- **LibInput backend** (optional): `sudo systemctl enable --now swayosd-libinput-backend.service` — auto-detects Caps/Num/Scroll lock presses without keybinds
- **Multi-monitor**: `swayosd-client --monitor "$(hyprctl monitors -j | jq -r '.[] | select(.focused == true).name')" --output-volume raise` to show OSD only on the focused monitor
- **Custom step size**: `swayosd-client --output-volume +2` instead of the default step

### Troubleshooting

- **No popup appears** → is `swayosd-server` running? `pgrep -x swayosd-server`
- **Popup has rounded corners** → verify `border-radius: 0` in `style.css` and restart swayosd-server
- **`swayosd-client: command not found`** → ensure `swayosd` is installed
- **Volume stays at 100%** → `--max-volume 150` allows up to 150% in PulseAudio/WirePlumber

---

## 7. Zsh

### Overview

Zsh is the default shell. Two config files are provided: `.zshenv` (environment variables) and `.zshrc` (interactive shell config).

### File locations

```
~/.zshenv    # Env vars (loaded for every shell)
~/.zshrc     # Interactive shell config (aliases, prompt, completion)
```

### `.zshenv` — Environment variables

```zsh
export EDITOR=nvim
export VISUAL=nvim
export BROWSER=firefox
export TERMINAL=kitty
export PAGER=less
export MANPAGER='nvim +Man!'

# Wayland
export MOZ_ENABLE_WAYLAND=1
export SDL_VIDEODRIVER=wayland
export QT_QPA_PLATFORM=wayland;xcb
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export GDK_BACKEND=wayland,x11,*
export _JAVA_AWT_WM_NONREPARENTING=1
```

### `.zshrc` — Interactive shell

**Prompt format:**

```
╭─ user@host ~/some/path (main)
╰─ $
```

Uses `vcs_info` for git branch display with staged (`●` lime) and unstaged (`●` red) indicators.

**Key settings:**

| Setting | Value | Purpose |
|---------|-------|---------|
| `HISTSIZE` / `SAVEHIST` | 50000 | Large history |
| `HISTDUP` | `erase` | Deduplicate history |
| `bindkey -v` | vi-mode | Vi keybindings in shell |
| `PROMPT_SUBST` | *on* | Allow command substitution in prompt (needed for `$(git_prompt_info)`) |

**Aliases (60+):**

| Group | Examples |
|-------|----------|
| **System** | `ll`, `la`, `grep --color`, `df -h` |
| **Hyprland** | `hrc` (reload), `hw` (workspaces), `hm` (monitors), `hb` (hyprpaper) |
| **Waybar** | `wbr` (restart waybar) |
| **Rofi** | `rfl` (drun), `rfw` (window), `rfr` (run) |
| **Kitty** | `k`, `kssh` |
| **Neovim** | `v`, `vi`, `vim` |
| **Git** | `ga`, `gc`, `gp`, `gl`, `gs`, `gd`, `gb`, `gco`, `gcb`, `gpl`, `gf` |
| **Screenshot** | `ss` (area), `ss-full`, `ss-window` |
| **Systemd** | `sc`, `scu`, `jc`, `jcu` |
| **AUR** | `y` (yay), `ys` (install), `yr` (remove), `yu` (upgrade) |

**LS_COLORS** uses a CGGX-aware set: directories in cyan (`38;5;81`), executables in green (`38;5;47`), images in magenta (`38;5;213`), archives in muted gray (`38;5;244`), config files in cyan.

**Clipboard daemon:** The clipboard history daemon now starts from **Hyprland's autostart** (`hyprland.lua`), not from `.zshrc`. See [§8 — Clipboard](#8-clipboard-cliphist--wl-clipboard) below for details.

### Making Zsh the default shell

```bash
chsh -s /usr/bin/zsh
# Log out and back in, or:
exec zsh
```

---

## 8. Clipboard (cliphist + wl-clipboard)

### Overview

Wayland's clipboard works through the data device protocol — when an app closes, its copied content **disappears**. `cliphist` fixes this by maintaining a persistent history daemon.

### Dependencies

```bash
sudo pacman -S wl-clipboard cliphist
```

### Architecture

```
App copies text → wl-copy → Wayland data device → wl-paste → cliphist store
                                                    ↓
                                              cliphist list → rofi -dmenu → cliphist decode → wl-copy (paste)
```

### Daemon (autostart)

The clipboard history daemon is started by Hyprland on session boot:

```lua
-- ~/.config/hypr/hyprland.lua (autostart section)
hl.exec_cmd("wl-paste --watch cliphist store")
```

This watches the clipboard via `wl-paste` and pipes every new entry into `cliphist store`.  
Previously this was in `.zshrc`, but the daemon must run **before** you use the clipboard — Hyprland's autostart is the correct place.

### Picker script

**`~/.config/hypr/scripts/cliphist-rofi.sh`**:

```bash
#!/usr/bin/env bash
entries=$(cliphist list)

if [[ -z "$entries" ]]; then
  rofi -e "Clipboard empty" -theme ~/.config/rofi/config.rasi
  exit 1
fi

selected=$(echo "$entries" | rofi -dmenu \
  -p " Clipboard" \
  -display-columns 2 \
  -theme ~/.config/rofi/config.rasi)

if [[ -z "$selected" ]]; then
  exit 0
fi

echo "$selected" | cliphist decode | wl-copy
```

Note: `-display-columns 2` tells Rofi to show only column 2 (the preview text),
hiding the numeric IDs that `cliphist list` prepends.

### cliphist config file

cliphist reads settings from `~/.config/cliphist/config` (or `$XDG_CONFIG_HOME` override).
This file is optional — defaults work out of the box — but recommended for tuning.

**`~/.config/cliphist/config`:**

```conf
# CGGX Cliphist config
max-items         1500        # Total entries to keep (default 750)
max-store-size    10MiB       # Max size per clipboard item (default 5MB)
preview-width     120         # Preview chars shown in picker (default 100)
max-dedupe-search 200         # How many recent items to dedupe against (default 100)
```

All options can also be set via environment variables (`CLIPHIST_MAX_ITEMS=1500`)
or CLI flags (`-max-items 1500`).

Bound in `binds.lua`:

```lua
hl.bind("SUPER + C",         hl.dsp.exec_cmd("~/.config/hypr/scripts/cliphist-rofi.sh"))
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("cliphist wipe && notify-send 'Clipboard' 'History cleared'"))
```

### Deployment

```bash
# Script
mkdir -p ~/.config/hypr/scripts
cp configs/hypr/scripts/cliphist-rofi.sh ~/.config/hypr/scripts/
chmod +x ~/.config/hypr/scripts/cliphist-rofi.sh

# Config (optional — defaults work without it)
mkdir -p ~/.config/cliphist
cp configs/cliphist/config ~/.config/cliphist/
```

### Keybinds

| Keys | Action |
|------|--------|
| `SUPER + C` | Open clipboard history picker |
| `SUPER + SHIFT + C` | Clear clipboard history |

### Related tools

| Command | Purpose |
|---------|---------|
| `wl-copy` | Copy to clipboard (stdin) |
| `wl-paste` | Paste from clipboard (stdout) |
| `cliphist store` | Store clipboard content in history (stdin) |
| `cliphist list` | List history entries |
| `cliphist decode` | Decode a base64 entry for piping |
| `cliphist wipe` | Clear all history |

### Troubleshooting

- **`wl-paste: command not found`** → install `wl-clipboard`
- **`cliphist: command not found`** → install `cliphist`
- **Picker shows empty** → the daemon may not be running. Check: `ps aux | grep cliphist`. If missing, start manually: `wl-paste --watch cliphist store &`
- **Copy still dies on app close** → ensure `cliphist` is installed AND the daemon autostart line is present in the autostart section
