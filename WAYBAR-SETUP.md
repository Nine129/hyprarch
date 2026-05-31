# Waybar Setup — CGGX Rice

> Documented: 2026-05-31
> Source: [Waybar Wiki](https://github.com/Alexays/Waybar/wiki) + [`waybar-import/`](./waybar-import/) (community dotfiles)
>
> See also: **[HYPRLAND-SETUP.md](./HYPRLAND-SETUP.md)** — Hyprland config, architecture, Lua reference |
> **[ROFI-SETUP.md](./ROFI-SETUP.md)** — Rofi theming, widget hierarchy, installation |
> **[ECOSYSTEM-SETUP.md](./ECOSYSTEM-SETUP.md)** — Hyprpaper, SwayNC, Kitty, Fastfetch, Screenshots, SwayOSD, Zsh, Clipboard guides |
> **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)** — Common issues and fixes |
> **[README.md](./README.md)** — Project overview and quick start

---

## 1. Research Summary

### 1.1 Official Wiki

#### Configuration

- **Location**: `~/.config/waybar/config` or `~/.config/waybar/config.jsonc`
- **Format**: JSONC (supports `//` and `/* */` comments)
- **Structure**: Array of bar objects `[{...}, {...}]` — each bar targets a specific `output` (monitor)

**Bar-level options**:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `layer` | string | `bottom` | `top` or `bottom` — display in front of or behind windows |
| `position` | string | `top` | `top`, `bottom`, `left`, `right` |
| `output` | string/array | — | Monitor(s) this bar appears on; `!eDP-1` means "everywhere except eDP-1" |
| `height` | integer | — | Fixed height; omit for dynamic |
| `width` | integer | — | Fixed width |
| `modules-left` | array | — | Left-aligned modules |
| `modules-center` | array | — | Center-aligned modules |
| `modules-right` | array | — | Right-aligned modules |
| `margin` | string | — | Margins in CSS format without units (e.g. `"6px 4px 0px 4px"`) |
| `margin-<dir>` | integer | — | Individual margin |
| `spacing` | integer | `4` | Gap between modules |
| `name` | string | — | CSS class added for styling individual bars |
| `exclusive` | bool | `true` | Request exclusive zone from compositor |
| `passthrough` | bool | `false` | Pass pointer events through (for overlay bars) |
| `fixed-center` | bool | `true` | Keep center block truly centered vs floating between left/right |
| `include` | array | — | Paths to additional config files (for shared module definitions) |
| `ipc` | bool | `false` | Subscribe to Sway IPC bar events |

**Module-level event bindings** (applied to every module):

| Event | Type | Description |
|-------|------|-------------|
| `on-click` | string | Left click command |
| `on-click-right` | string | Right click |
| `on-click-middle` | string | Middle click |
| `on-scroll-up` | string | Scroll up on module |
| `on-scroll-down` | string | Scroll down |
| `on-double-click` | string | Double click |
| `on-update` | string | Runs when module updates |

**Formatting**:

- PangoMarkup is supported: `"format": "<span color=\"red\">{}</span>"`
- Module instances via `#` suffix: `battery#bat2` → CSS class `.bat2`
- `include` accepts array of paths; nested includes permitted (avoid circular)

#### Styling

- **File**: `~/.config/waybar/style.css` (also `style-light.css` / `style-dark.css` for system theme)
- **Main selector**: `window#waybar`
- **Position class**: `window#waybar.top`, `window#waybar.bottom`
- **Name class**: `window#waybar.<name>` (when `name` set in config)
- **Per-output**: `window.eDP-1 * { font-size: 10px; }`
- **Module groups**: `.modules-left`, `.modules-center`, `.modules-right`
- **Generic module**: `label.module` (text), `box.module` (container)
- **Tooltips**: `tooltip { }` / `tooltip label { }`

**Debug tools**:

- `GTK_DEBUG=interactive waybar` — live CSS inspector (GTK style)
- `waybar -l debug` — prints full widget tree

**Animation best practice**: Use `animation-timing-function: steps(12)` instead of `linear` to keep CPU usage low.

**Gtk theme CSS variables** (will follow system theme):

```css
window#waybar {
    background: @theme_base_color;
    border-bottom: 1px solid @unfocused_borders;
    color: @theme_text_color;
}
```

Available modifiers: `shade()`, `alpha()`, `mix()`.

#### Modules Index

The wiki lists 40+ modules. Those relevant to a Hyprland + CGGX rice:

| Module | Purpose |
|--------|---------|
| `hyprland/workspaces` | Hyprland workspace switcher (multiple style variants) |
| `hyprland/window` | Active window title |
| `clock` | Date/time with calendar tooltip |
| `cpu` | CPU usage |
| `memory` | RAM usage |
| `disk` | Disk usage |
| `network` | WiFi/Ethernet status |
| `pulseaudio` | Volume control |
| `bluetooth` | Bluetooth status |
| `battery` | Power status |
| `backlight` | Screen brightness |
| `mpris` | Media player info (player-agnostic) |
| `custom/*` | User scripts (launcher, power, updates, etc.) |
| `group/*` | Module grouping with optional drawers |
| `tray` | System tray |
| `cava` | Audio visualizer |
| `image` | Static image (e.g. user avatar) |
| `temperature` | Thermal monitor |
| `idle_inhibitor` | Inhibit idle/screensaver |

### 1.2 Community Config Patterns (`waybar-import/`)

The [`waybar-import/`](./waybar-import/) folder contains real dotfiles from an Arch Hyprland user ("rei"). Key architectural insight:

**Five bar presets**, each in its own `bars/<name>/` directory:

| Preset | Position | Height | Vibe | Layout |
|--------|----------|--------|------|--------|
| **island** | Top | auto | Transparent bg, floating opaque pill modules | Launcher + workspaces + spotify + cava \| clock \| bt + net + sys-tray + power |
| **spectrum** | Top | 40px | Full-width, colorful, groups with accordion drawers | Arch logo + cpu + mem + disk + mpris \| pacman workspaces \| tray + sys-settings + audio + updates + clock + power |
| **amedeus** | Top | 34px | Flat dark, active workspace has underline | Workspaces + clock + battery \| window title \| tray + temp + cpu + mem + wireplumber + net + notif |
| **grounded** | **Bottom** | 40px | 1300px centered, pill modules | Circles workspaces + tray + cava \| music group \| audio + btop + clock |
| **hollow** | Top | 24px | Ultra-minimal, dark pills, accordion drawers | Power + workspaces \| window \| tray + clock + sys-info + battery + notif |

**Shared architecture**:

```
~/.config/waybar/
├── config.jsonc              ← symlink → bars/<name>/config.jsonc (or inline)
├── style.css                 ← symlink → bars/<name>/style.css (or inline)
├── config                    ← alternate all-in-one config (island style)
├── modul                     ← NotMugil's full module reference (all modules documented)
├── colors/
│   ├── current-theme.css     ← active theme variables (symlinked)
│   ├── catppuccin.css
│   ├── gruvbox-dark.css
│   ├── tokyo-night.css
│   └── starlit.css
├── bars/
│   ├── island/config.jsonc + style.css
│   ├── spectrum/config.jsonc + style.css
│   ├── amedeus/config.jsonc + style.css
│   ├── grounded/config.jsonc + style.css
│   └── hollow/config.jsonc + style.css
├── modules/
│   ├── island.jsonc          ← modules for island preset
│   ├── spectrum.jsonc        ← modules for spectrum preset
│   ├── amedeus.jsonc         ← modules for amedeus preset
│   ├── grounded.jsonc        ← modules for grounded preset
│   ├── hollow.jsonc          ← modules for hollow preset
│   └── <name>.jsonc          ← generic module definitions (from modul)
├── scripts/
│   ├── mediaplayer.py        ← Python script for MPRIS info
│   ├── spotify.sh            ← Spotify status script
│   ├── waybar-date.sh        ← Custom date formatter
│   ├── waybar-power.sh       ← Power menu script
│   ├── waybar-sysinfo.sh     ← System info script
│   └── waybar-logout.sh      ← Logout script
└── wallust/
    └── colors-waybar.css     ← wallust-generated colors
```

**CSS variable convention** (all presets use `@import "colors/current-theme.css"`):

```css
@define-color background    #1e1e2e;
@define-color backgrounddark #181825;
@define-color foreground    #cdd6f4;
@define-color foregrounddark #6c7086;
@define-color text          #cdd6f4;
@define-color textdark      #6c7086;
@define-color textlight     #6c7086;
@define-color color0        #45475a;
@define-color color1        #45475a;
@define-color color2        #45475a;
@define-color color3        #45475a;
@define-color color4        #89b4fa;
@define-color color5        #f38ba8;
@define-color color6        #a6e3a1;
@define-color color7        #f9e2af;
@define-color color8        #94e2d5;
@define-color color9        #cba6f7;
@define-color color10       #f2cdcd;
@define-color color11       #585b70;
@define-color color12       #89b4fa;
@define-color color13       #f38ba8;
@define-color color14       #a6e3a1;
@define-color color15       #f9e2af;
```

---

## 2. CGGX Rice — Resolved Decisions

These were settled during the grill-me session.

### 2.1 Bar Aesthetic

| Property | Decision |
|----------|----------|
| **Look** | Floating pill island — transparent `window#waybar` background, opaque `rgba(26,26,32,0.88)` pill modules |
| **Position** | `top`, full-width |
| **Border-radius** | **0 everywhere** — zero rounding, consistent with CGGX sharp aesthetic |
| **Active workspace** | Red `#ff2d55` background pill (not underline) — matches original mockup |
| **Hover** | Subtle brightening, no background color shift |

### 2.2 Architecture

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Config structure** | Separated `include` pattern | `config.jsonc` defines layout only; module definitions in `modules/cggx.jsonc` |
| **Bar count** | Single bar | One monitor (1920×1080@60). Expandable later. |
| **Colors** | CSS variables via `@import "colors/cggx.css"` | Follows community convention, easy to regenerate via wallust/pywal |
| **Single vs multi-monitor** | Single output, no `output` restriction | Only one monitor; `output` can be added later |
| **Style files** | One `style.css` + one `colors/cggx.css` | No light/dark variant needed — CGGX is a fixed dark palette |

### 2.3 Module Layout

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ [1][2][3][4][5][6][7][8][9]  / 81% FREE │ RAM 12.6G │ SSID │ 42% │ clock │ 100%│30%│││
└─────────────────────────────────────────────────────────────────────────────┘
 LEFT: workspaces (1-9 persistent)        RIGHT: disk + memory + network +
        empty center                              pulseaudio + clock +
                                                  battery + tray + power
```

### 2.4 Module Definitions (`modules/cggx.jsonc`)

| Module ID | Type | Key Properties |
|-----------|------|----------------|
| `hyprland/workspaces#number` | Workspaces | 1-9 persistent, red active, orange urgent, muted empty. See color map below. |
| `disk` | System | `{specific_used:0.2f} GB`, interval 30s |
| `memory` | System | `{used} GiB`, interval 30s |
| `network` | Network | `{essid}` text + signal icons via `format-icons`, click → nmtui |
| `pulseaudio` | Audio | `{icon} {volume}%`, click → pavucontrol |
| `clock` | Time | `{:%a %d  %H:%M}`, alt-click → date format |
| `battery` | Power | `{icon} {capacity}%`, charge/warning states |
| `custom/power-button` | Custom | ``, click → wlogout |
| `tray` | System | icon-size 14, spacing 10 |

**Color map for workspace numbers**:

```
1 → active:  #ff2d55 (red)
2 → empty:   #6a6a80 (muted)
3 → urgent:  #ff6b00 (orange) + pulse animation
4-9 → follows same pattern
```

### 2.5 Keybindings (mouse events on modules)

| Module | Click | Right-click | Scroll |
|--------|-------|-------------|--------|
| `workspaces` | Switch to workspace | — | Cycle e+1 / e-1 |
| `network` | `kitty -e 'nmtui'` | `rfkill toggle wifi` | — |
| `pulseaudio` | `pavucontrol` | `pactl set-sink-mute 0 toggle` | Volume up/down |
| `battery` | — | — | — |
| `custom/power-button` | `wlogout -b 5` | — | — |

### 2.6 CGGX Color Variables (`colors/cggx.css`)

```css
@define-color bg       #0a0a0c;
@define-color surface  #1a1a20;
@define-color border   #2a2a35;
@define-color red      #ff2d55;
@define-color cyan     #00e5ff;
@define-color lime     #c8ff00;
@define-color orange   #ff6b00;
@define-color silver   #e8e8f0;
@define-color muted    #6a6a80;
```

---

## 3. File Generation Plan

The following files need to be created in `~/.config/waybar/` during deployment:

```
~/.config/waybar/
├── config.jsonc           ← bar layout (left/center/right, height, layer)
├── style.css              ← CSS styling for all modules
├── colors/
│   └── cggx.css           ← CGGX palette as @define-color variables
└── modules/
    └── cggx.jsonc          ← module definitions (format, interval, click handlers)
```

### 3.1 `config.jsonc` Skeleton

```jsonc
[
  {
    "layer": "top",
    "position": "top",
    "height": 40,
    "margin": "6px 4px 0px 4px",
    "include": "~/.config/waybar/modules/cggx.jsonc",
    "modules-left": [
      "hyprland/workspaces#number"
    ],
    "modules-center": [],
    "modules-right": [
      "disk",
      "memory",
      "network",
      "pulseaudio",
      "clock",
      "battery",
      "tray",
      "custom/power-button"
    ]
  }
]
```

### 3.2 `style.css` Skeleton

```css
@import "colors/cggx.css";

* {
  border: none;
  border-radius: 0;
  font-family: JetBrainsMonoNL Nerd Font;
  font-weight: 600;
  font-size: 10px;
  min-height: 0;
}

window#waybar {
  background: transparent;
  color: @silver;
}

window > box {
  background: transparent;
  padding: 0 4px;
}

/* Workspaces — number badges */
#workspaces {
  margin: 6px 2px;
}
#workspaces button {
  padding: 2px 8px;
  background: rgba(26,26,32,0.88);
  color: @muted;
  font-size: 10px;
  line-height: 20px;
}
#workspaces button.active {
  background: @red;
  color: @bg;
}
#workspaces button.urgent {
  color: @orange;
  animation: blink-orange 1s steps(12) infinite alternate;
}
#workspaces button:hover {
  color: @silver;
  background: rgba(42,42,53,0.5);
}

/* Pill modules */
#disk,
#memory,
#network,
#pulseaudio,
#clock,
#battery,
#custom-power-button,
#tray {
  background: rgba(26,26,32,0.88);
  padding: 0 10px;
  margin: 6px 2px;
  line-height: 22px;
}

#disk             { color: @lime; }
#memory           { color: @orange; }
#network          { color: @cyan; }
#pulseaudio       { color: @orange; }
#clock            { color: @cyan; }
#battery          { color: @lime; }
#battery.charging { color: @cyan; }
#battery.warning  { color: @orange; }
#battery.critical { color: @red; }

#custom-power-button {
  color: @red;
}

#tray {
  background: transparent;
}
#tray > * {
  padding: 0 2px;
}

/* Tooltips */
tooltip {
  background: @bg;
  border: 1px solid @border;
  color: @silver;
  font-family: JetBrainsMonoNL Nerd Font;
  font-size: 10px;
}
tooltip label {
  padding: 8px;
  color: @silver;
}

/* Urgent pulse animation */
@keyframes blink-orange {
  to { color: @silver; }
}
```

### 3.3 `modules/cggx.jsonc` Skeleton

```jsonc
{
  "hyprland/workspaces#number": {
    "all-outputs": true,
    "on-click": "activate",
    "format": "{icon}",
    "on-scroll-up": "hyprctl dispatch workspace e+1",
    "on-scroll-down": "hyprctl dispatch workspace e-1",
    "persistent-workspaces": {
      "1": [], "2": [], "3": [], "4": [], "5": [],
      "6": [], "7": [], "8": [], "9": []
    },
    "format-icons": {
      "1": "1", "2": "2", "3": "3", "4": "4", "5": "5",
      "6": "6", "7": "7", "8": "8", "9": "9",
      "urgent": "󰁫",
      "default": ""
    }
  },
  "disk": {
    "interval": 30,
    "format": "{specific_used:0.2f} GB",
    "unit": "GB"
  },
  "memory": {
    "interval": 30,
    "format": "{used} GiB"
  },
  "network": {
    "interval": 30,
    "format-wifi": "{essid}",
    "format-ethernet": "{ifname}",
    "format-disconnected": "󰖪",
    "on-click": "kitty -e 'nmtui'",
    "tooltip-format": "{ipaddr}"
  },
  "pulseaudio": {
    "format": "{icon} {volume}%",
    "format-muted": "󰖁",
    "format-icons": {
      "default": ["", ""]
    },
    "scroll-step": 1,
    "on-click": "pavucontrol",
    "on-click-right": "pactl set-sink-mute 0 toggle"
  },
  "clock": {
    "interval": 60,
    "format": "{:%a %d  %H:%M}",
    "format-alt": "{:%Y-%m-%d}"
  },
  "battery": {
    "interval": 60,
    "states": {
      "warning": 30,
      "critical": 15
    },
    "format": "{icon} {capacity}%",
    "format-charging": " {capacity}%",
    "format-plugged": " {capacity}%",
    "format-icons": ["", "", "", "", ""]
  },
  "custom/power-button": {
    "format": "",
    "on-click": "wlogout -b 5",
    "tooltip": false
  },
  "tray": {
    "icon-size": 14,
    "spacing": 10
  }
}
```

---

## 4. Deployment Checklist

- [ ] `~/.config/waybar/config.jsonc` — bar layout
- [ ] `~/.config/waybar/style.css` — styling
- [ ] `~/.config/waybar/colors/cggx.css` — palette variables
- [ ] `~/.config/waybar/modules/cggx.jsonc` — module definitions
- [ ] Test with `waybar --config ~/.config/waybar/config.jsonc`
- [ ] Verify all 9 workspaces render
- [ ] Verify active/urgent/empty colors
- [ ] Verify click actions (pavucontrol, nmtui, wlogout)
- [ ] `waybar -l debug` to inspect widget tree if style issues
- [ ] `GTK_DEBUG=interactive waybar` for live CSS tweaking

---

## 5. References

- [Waybar Wiki — Configuration](https://github.com/Alexays/Waybar/wiki/Configuration)
- [Waybar Wiki — Styling](https://github.com/Alexays/Waybar/wiki/Styling)
- [Waybar Wiki — Modules](https://github.com/Alexays/Waybar/wiki/Modules)
- [`waybar-import/`](./waybar-import/) — community dotfiles (5 bar presets)
- CGGX Palette: `#0a0a0c`, `#1a1a20`, `#ff2d55`, `#00e5ff`, `#c8ff00`, `#ff6b00`, `#e8e8f0`, `#6a6a80`
