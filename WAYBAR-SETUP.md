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

These were settled during the grill-me / grill-with-docs sessions.

### 2.1 Bar Aesthetic

| Property | Decision |
|----------|----------|
| **Look** | Floating pill island — transparent `window#waybar` background, opaque `#151518` pill modules |
| **Position** | `top`, full-width |
| **Height** | 36px |
| **Border-radius** | **0 everywhere** — zero rounding, consistent with CGGX sharp aesthetic |
| **Active workspace** | Red `#ff2d55` background pill, subtle shadow on all workspaces |
| **Hover** | Margin shift on interactive modules, 0.15s ease transition |
| **Center section** | Empty (negative space — purposeful asymmetry) |
| **Surface color** | `#151518` (matches kitty background + rmpc bg) |

| Dimension | Decision |
|-----------|----------|
| **Icons** | Icon-first layout — every module has a colored Nerd Font icon before text |
| **Module grouping** | Left: workspaces + mpris; Center: empty; Right: [disk+memory+temperature] group | pulseaudio | clock | battery | [tray | power-button] |
| **Separators** | Thin 1px `#2a2a35` vertical lines between right-side groups |
| **Group module** | `group/sysmon` — gapless horizontal group for disk+memory+temperature |
| **Animations** | Smooth 0.15s ease transitions on all modules; margin-shift hover; `blink-orange` on urgent workspaces |
| **Power button** | Red gradient background (`#ff2d55` to `rgba(255,45,85,0.85)`), toggles Quickshell control panel |
| **MPRIS module** | Shows MPD now-playing — Nerd Font icon (/), right-click opens rmpc, scroll controls tracks |

### 2.3 Architecture

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Config structure** | Separated `include` pattern | `config.jsonc` defines layout only; module definitions in `modules/cggx.jsonc` |
| **Bar count** | Single bar | One monitor (1920×1080@60). Expandable later. |
| **Colors** | CSS variables via `@import "colors/cggx.css"` | Follows community convention, easy to regenerate via wallust/pywal |
| **Single vs multi-monitor** | Single output, no `output` restriction | Only one monitor; `output` can be added later |
| **Style files** | One `style.css` + one `colors/cggx.css` | No light/dark variant needed — CGGX is a fixed dark palette |
| **Data modules** | Built-in `disk`, `memory`, `battery` | Simple format strings with icon prefix; no extra scripts needed |

```
┌─────────────────────────────────────────────────────────────────────┐
│ [1][2][3][4][5]  ♫ Now Playing │  81%  6.4G  45°C │  42%  Mon│⏻│
└─────────────────────────────────────────────────────────────────────┘
 LEFT: workspaces (1-5 persistent) + mpris   CENTER: empty   RIGHT: sysmon group + audio + clock + battery + power
```

### 2.5 Module Definitions (`modules/cggx.jsonc`)

| Module ID | Type | Key Properties |
|-----------|------|----------------|
| `hyprland/workspaces#number` | Workspaces | 1-5 persistent, number icons, red active, muted empty |
| `mpris` | Media | MPD now-playing, / icons, right-click→rmpc, scroll→prev/next |
| `group/sysmon` | Group | Gapless horizontal: disk + memory + temperature |
| `disk` | System (built-in) | `{percentage_free}%`, 30s interval, lime text, click→btop |
| `memory` | System (built-in) | `{used}G / {total}G`, 30s interval, orange text, click→btop |
| `temperature` | System (built-in) | `thermal_zone0 {temp}°C`, 30s interval, cyan text, click→btop |
| `custom/sep1` | Separator | Empty, styled as 1px `#2a2a35` vertical line |
| `pulseaudio` | Audio | `{volume}%`, orange bg, right-click→mute toggle |
| `clock` | Time | `{:%a %d %H:%M}`, 60s interval, cyan bg |
| `battery` | Power (built-in) | `{icon} {capacity}%`, lime bg, warning 30%, critical 15% |
| `custom/sep2` | Separator | Empty, styled as 1px `#2a2a35` vertical line |
| `custom/power-button` | Custom | `panel-gear.sh` → Quickshell control panel toggle, red gradient bg |
| `tray` | System | icon-size 14, spacing 10 |
| Module | Click | Right-click | Scroll |
|--------|-------|-------------|--------|
| `workspaces` | `workspace {name}` | — | Cycle e+1 / e-1 |
| `mpris` | — | `kitty --single-instance rmpc` | `playerctl -p mpd next/prev` |
| `disk` | `kitty -e btop` | — | — |
| `memory` | `kitty -e btop` | — | — |
| `temperature` | `kitty -e btop` | — | — |
| `pulseaudio` | `pavucontrol-toggle.sh` | mute toggle | Volume up/down |
| `custom/power-button` | toggle quickshell panel | — | — |

| Module | Color |
|--------|-------|
| disk | `#c8ff00` (lime) |
| memory | `#ff6b00` (orange) |
| temperature | `#00e5ff` (cyan) |
| pulseaudio | `#ff6b00` (orange) |
| clock | `#00e5ff` (cyan) |
| battery | `#c8ff00` (lime) |
| charging | `#00e5ff` (cyan) |
| battery warning | `#ff6b00` (orange) |
| battery critical | `#ff2d55` (red) bg + `#0a0a0c` text |
| power | `#ff2d55` (red) |
| mpris | `#ff2d55` (red) |
| separator | `#2a2a35` |

### 2.8 CGGX Color Variables (`colors/cggx.css`)

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

### 3.2 Current `style.css` (abridged)

The full file is at [`configs/waybar/style.css`](./configs/waybar/style.css). Key sections:

```css
/* Workspace buttons — inner glow on active */
#workspaces button.active {
  background: @red;
  color:      @bg;
  box-shadow: 0 0 12px rgba(255, 45, 85, 0.4),
              0 2px 8px rgba(0, 0, 0, 0.6);
}

/* Hover lift — margin shift simulates lift (GTK CSS has no transform) */
#disk:hover,
#memory:hover,
/* ... */
#custom-power-button:hover {
  margin-top: 5px;
  margin-bottom: 7px;
}

/* Separators between groups */
#custom-sep1,
#custom-sep2 {
  background: @border;
  min-width:  1px;
  min-height: 14px;
  margin:     28px 6px;   /* centers in 70px bar */
}

/* Power button — red-tinted background */
#custom-power-button {
  background: linear-gradient(180deg, #1a1a20 0%, rgba(255, 45, 85, 0.08) 100%);
}
```

### 3.3 Current `modules/cggx.jsonc` (abridged)

The full file is at [`configs/waybar/modules/cggx.jsonc`](./configs/waybar/modules/cggx.jsonc).

Key aspects:
- **Built-in `disk`, `memory`, `battery`** — format strings include the Nerd Font icon prefix
- **Two separator modules** (`custom/sep1`, `custom/sep2`) between the three groups
- **New icon set**: (disk), (memory), (network), (audio), (clock), ⏻(power)

---

## 4. Deployment Checklist

- [ ] `~/.config/waybar/config.jsonc` — bar layout
- [ ] `~/.config/waybar/style.css` — styling
- [ ] `~/.config/waybar/colors/cggx.css` — palette variables
- [ ] `~/.config/waybar/modules/cggx.jsonc` — module definitions
- [ ] Test with `waybar --config ~/.config/waybar/config.jsonc`
- [ ] Verify all 9 workspaces render
- [ ] Verify active workspace has red bg + inner glow
- [ ] Verify group separators (1px `#2a2a35` lines between groups)
- [ ] Verify hover lift effect on modules
- [ ] Verify click actions (pavucontrol toggle, nmtui, wlogout toggle, power profile)
- [ ] `waybar -l debug` to inspect widget tree if style issues
- [ ] `GTK_DEBUG=interactive waybar` for live CSS tweaking

---

## 5. References

- [Waybar Wiki — Configuration](https://github.com/Alexays/Waybar/wiki/Configuration)
- [Waybar Wiki — Styling](https://github.com/Alexays/Waybar/wiki/Styling)
- [Waybar Wiki — Modules](https://github.com/Alexays/Waybar/wiki/Modules)
- [`waybar-import/`](./waybar-import/) — community dotfiles (5 bar presets)
- CGGX Palette: `#0a0a0c`, `#1a1a20`, `#ff2d55`, `#00e5ff`, `#c8ff00`, `#ff6b00`, `#e8e8f0`, `#6a6a80`
 `#1a1a20`, `#ff2d55`, `#00e5ff`, `#c8ff00`, `#ff6b00`, `#e8e8f0`, `#6a6a80`
00`, `#ff6b00`, `#e8e8f0`, `#6a6a80`
 `#1a1a20`, `#ff2d55`, `#00e5ff`, `#c8ff00`, `#ff6b00`, `#e8e8f0`, `#6a6a80`
