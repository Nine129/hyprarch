# Rofi Setup — CGGX Rice

> Rofi: Application launcher, window switcher, and dmenu replacement.
> Part of the CGGX Hyprland rice — brutalist, zero-radius, red-cyan-lime palette.
>
> See also: **[HYPRLAND-SETUP.md](./HYPRLAND-SETUP.md)** — Hyprland config, architecture, Lua reference |
> **[WAYBAR-SETUP.md](./WAYBAR-SETUP.md)** — Waybar styling, modules, decisions |
> **[ECOSYSTEM-SETUP.md](./ECOSYSTEM-SETUP.md)** — Hyprpaper, SwayNC, Kitty, Fastfetch, Screenshots, SwayOSD, Zsh, Clipboard guides |
> **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)** — Common issues and fixes |
> **[README.md](./README.md)** — Project overview and quick start

---

## Table of Contents

1. [Research Sources](#1-research-sources)
2. [Decisions](#2-decisions)
3. [File Structure](#3-file-structure)
4. [Installation](#4-installation)
5. [Configuration Reference](#5-configuration-reference)
6. [Theme Reference](#6-theme-reference)
7. [Usage](#7-usage)
8. [Cross-References](#8-cross-references)

---

## 1. Research Sources

| Source | URL | Content |
|--------|-----|---------|
| GitHub Repo | https://github.com/davatorium/rofi | Source, issues, wiki |
| Official Docs | https://davatorium.github.io/rofi/ | Web-version of manpages |
| Theme manpage | `/current/rofi-theme.5/` | Widget structure, properties, format spec |
| Config manpage | `/current/rofi.1/` | CLI options, configuration block, PATTERN |
| Transparency guide | `/guides/Transparency/theme3-transparency/` | Real vs screenshot vs background transparency |
| Positioning guide | `/guides/Positioning/theme3-positioning/` | Location, anchor, offsets |
| Wiki (archived) | GitHub Wiki tab | Unmaintained — links to official docs instead |
| Example themes | `/themes/` in repo | Adapta-Nokto.rasi, Arc-Dark.rasi, dmenu.rasi, etc. |

### Key Documentation Structure

Rofi 2.0.0 (stable) and the development branch share the same docs at:

```
/current/rofi.1/          — General usage, CLI, configuration block
/current/rofi-theme.5/    — Theme format, widgets, properties (the big one)
/current/rofi-dmenu.5/    — Dmenu emulation mode
/current/rofi-script.5/   — Custom script mode
/current/rofi-keys.5/     — Keybinding reference
/current/rofi-debugging.5/— Debug flags
/current/rofi-actions.5/  — Action system
/current/rofi-thumbnails.5/— Window thumbnail support
```

The old GitHub Wiki is **deprecated** — it redirects to the MkDocs site above.

---

## 2. Decisions

### 2.1 Default Mode: `drun`

| Decision | Choice |
|----------|--------|
| Default invocation | `rofi -show drun` |
| Rationale | Application launcher is the most frequent use case; window switching available via mode switcher buttons |
| Keybind | `SUPER + SPACE` |
| Alternative modes available | `run` (typed commands), `window` (window switcher) |

### 2.2 Configuration File

| Decision | Choice |
|----------|--------|
| File | `~/.config/rofi/config.rasi` |
| Format | Single-file rasi (rofi advanced style information) |
| Split approach? | No — unlike Waybar's multi-file include pattern, Rofi convention is one self-contained file. The configuration block and theme are both in `config.rasi`. |

### 2.3 Theme Decisions

| Decision | Choice |
|----------|--------|
| Border radius | **0 everywhere** — consistent with entire CGGX rice |
| Window border | `1px solid @border` (#2a2a35) — matches window borders in Hyprland |
| Active selection | Red left border (3px) + rgba(255,45,85,0.12) background tint |
| Urgent items | Orange accent |
| Active items | Cyan accent |
| Window width | 520px — centered on screen |
| Transparency | `"real"` — requires Wayland compositor (Hyprland) |
| Font | Share Tech Mono 10 |
| Icons | Papirus-Dark theme |
| Search placeholder | "search..." in muted (#6a6a80) |
| Cursor color | Red (#ff2d55) |
| Element layout | `[element-icon, element-text]` horizontal |
| Scrollbar | Disabled — cleaner look with 8 visible lines |
| Mode switcher | Enabled — shows LAUNCH / RUN / WINDOW buttons at bottom |

### 2.4 Color Palette (CGGX → Rofi)

```rasi
* {
  bg:      #0a0a0c;   /* window background */
  bg-alt:  #111115;   /* mode-switcher + message background */
  surface: #1a1a20;
  border:  #2a2a35;   /* window border */
  fg:      #e8e8f0;   /* primary text */
  fg-dim:  #6a6a80;   /* secondary text, placeholder */
  red:     #ff2d55;   /* selection accent, cursor, prompt */
  cyan:    #00e5ff;   /* active state */
  lime:    #c8ff00;   /* (reserved for future use) */
  orange:  #ff6b00;   /* urgent state */
}
```

### 2.5 Element States Mapped

| State | Background | Text Color | Left Border |
|-------|-----------|------------|-------------|
| `normal.normal` | transparent | @fg | transparent |
| `normal.urgent` | transparent | @orange | — |
| `normal.active` | transparent | @secondary | — |
| `selected.normal` | `rgba(255,45,85,0.12)` | @fg | 3px @primary |
| `selected.urgent` | `rgba(255,45,85,0.15)` | @orange | 3px @orange |
| `selected.active` | `rgba(0,229,255,0.12)` | @secondary | 3px @secondary |
| `alternate.normal` | transparent | @fg | — |

---

## 3. File Structure

```
~/.config/rofi/
  ├── config.rasi        # Main config + theme (single file)
  └── (no separate files — Rofi keeps it simple)
```

### Config.rasi Layout

The file is divided into clear sections:

```
/* ── Palette ──────────────────────────── */
* { ... color variables ... }

/* ── Configuration ────────────────────── */
configuration { ... modes, icons, terminal, etc ... }

/* ── Global widget defaults ───────────── */
* { ... default bg, text-color, border-radius:0 ... }

/* ── Window ───────────────────────────── */
window { ... sizing, border, position, transparency ... }

/* ── Mainbox ──────────────────────────── */
mainbox { ... layout container ... }

/* ── Inputbar ─────────────────────────── */
inputbar { ... spacing, border-bottom ... }

/* ── Prompt ───────────────────────────── */
prompt { ... "❯ LAUNCH" in red ... }

/* ── Entry ────────────────────────────── */
entry { ... search box, cursor, placeholder ... }

/* ── Case indicator ───────────────────── */
case-indicator { ... A/a indicator ... }

/* ── Listview ─────────────────────────── */
listview { ... 1 column, 8 lines, dynamic, no scrollbar ... }

/* ── Element ──────────────────────────── */
element { ... icon + text layout ... }

/* 6 state variants ────────────────────── */
element normal.normal { }
element normal.urgent { }
element normal.active { }
element selected.normal { }
element selected.urgent { }
element selected.active { }
element alternate.normal { }

/* ── Element text ─────────────────────── */
element-text { ... text styling, highlight:bold ... }

/* ── Element icon ─────────────────────── */
element-icon { ... size:1.2em ... }

/* ── Element index ────────────────────── */
element-index { ... shortcut numbers ... }

/* ── Mode switcher ────────────────────── */
mode-switcher { ... bottom bar ... }
button { ... individual mode buttons ... }
button selected { ... active mode ... }

/* ── Message box ──────────────────────── */
message { ... error dialogs ... }
textbox { ... message text ... }
```

---

## 4. Installation

### 4.1 Arch Linux

```bash
sudo pacman -S rofi
```

Optional — Wayland-specific build (slightly newer, some Wayland fixes):

```bash
yay -S rofi-lbonn-wayland-git
```

The `rofi` package in the official repos works fine with Hyprland in practice.

### 4.2 Deploy Config

```bash
mkdir -p ~/.config/rofi
cp config.rasi ~/.config/rofi/config.rasi
```

### 4.3 Verify

```bash
# Dump current theme to confirm it loaded
rofi -dump-theme | head -5

# Test launch
rofi -show drun

# Press Escape to exit
```

### 4.4 Dependencies

- **Papirus-Dark icon theme** (optional but recommended):
  ```bash
  sudo pacman -S papirus-icon-theme
  ```
- **Share Tech Mono font** (from the rice font pack, or `ttf-sharetechmono` from AUR)

---

## 5. Configuration Reference

### 5.1 Configuration Block Options

Set inside `configuration { ... }`:

| Option | CGGX Value | Description |
|--------|-----------|-------------|
| `modes` | `[ drun, run, window ]` | Enabled modes in order |
| `terminal` | `"kitty"` | Terminal for run mode |
| `combi-modes` | `[ window, drun, run ]` | Modes for combi view |
| `show-icons` | `true` | Display app icons |
| `icon-theme` | `"Papirus-Dark"` | Icon set |
| `drun-display-format` | `"{name}"` | What to show in drun list |
| `display-drun` | `"❯ LAUNCH"` | Prompt text for drun mode |
| `display-run` | `" RUN"` | Prompt text for run mode |
| `display-window` | `" WINDOW"` | Prompt text for window mode |
| `sidebar-mode` | `false` | Sidebar layout (off) |
| `click-to-exit` | `true` | Click outside to close |
| `cycle` | `true` | Wrap around list |
| `matching` | `"normal"` | Matching method |
| `sort` | `false` | Disable sort |
| `case-sensitive` | `false` | Case-insensitive search |

### 5.2 Command-Line Usage

```bash
# Application launcher (default)
rofi -show drun

# Run dialog (type command)
rofi -show run

# Window switcher
rofi -show window

# Combined view
rofi -show combi

# Dmenu mode (for scripts)
echo -e "opt1\nopt2\nopt3" | rofi -dmenu -p "Choose:"
```

---

## 6. Theme Reference

### 6.1 Widget Hierarchy

```
window
  overlay
  mainbox
    inputbar
      box
        prompt
        entry
        case-indicator
        num-rows
        num-filtered-rows
        textbox-current-entry
        icon-current-entry
    message
      textbox
    listview
      scrollbar
      element (×N)
        element-icon
        element-text
        element-index
    mode-switcher
      button (×N)
```

### 6.2 Key Widget Properties Used

| Widget | Key Properties | CGGX Value |
|--------|---------------|-----------|
| `window` | `width`, `border`, `border-radius`, `transparency`, `font`, `location`, `anchor`, `padding` | 400px, transparent (no border), 0, "real", Share Tech Mono 10, center, center, 0 |
| `inputbar` | `spacing`, `border-bottom` | 0, 1px solid @secondary |
| `prompt` | `text-color`, `padding`, `vertical-align` | @red, 10px 0 10px 12px, 0.5 |
| `entry` | `background-color`, `text-color`, `placeholder-color`, `cursor-color`, `padding` | transparent, @fg, @fg-dim, @red, 10px 12px |
| `listview` | `columns`, `lines`, `spacing`, `dynamic`, `cycle`, `scrollbar`, `layout` | 1, 8, 0, true, true, false, vertical |
| `element` | `orientation`, `children`, `spacing`, `padding`, `border-left` | horizontal, [element-icon, element-text], 8px, 6px 12px, 3px solid transparent |
| `element-text` | `text-color`, `vertical-align`, `highlight` | @fg, 0.5, bold |
| `element-icon` | `size`, `vertical-align` | 1.2em, 0.5 |
| `mode-switcher` | `enabled`, `spacing`, `background-color`, `border-top`, `padding` | false, 0, @bg-alt, 1px solid @border, 0 |
| `button` | `text-color`, `padding`, `cursor` | @fg-dim, 6px 14px, pointer |
| `button selected` | `text-color`, `background-color` | @red, rgba(255,45,85,0.08) |
| `message` | `background-color`, `border-top`, `padding` | @bg-alt, 1px solid @border, 8px 12px |

### 6.3 Color Formats Supported

Rofi supports the full CSS color spec:

```
#RGB              → #F00
#RRGGBB           → #FF2D55
#RRGGBBAA         → #FF2D5580
rgba(r,g,b,a)     → rgba(255,45,85,0.12)
rgb(r,g,b)        → rgb(0,229,255)
hsl(h,s,l)        → hsl(0,100%,50%)
hwb(h,w,b)        → hwb(0,0%,0%)
cmyk(c,m,y,k)     → cmyk(0%,100%,60%,10%)
named colors      → transparent, red, cyan, etc.
```

### 6.4 Distance Units

| Unit | Meaning | Example |
|------|---------|---------|
| `px` | Screen pixels | `padding: 10px` |
| `em` | Relative to font height | `size: 1.2em` |
| `ch` | Width of one digit | `width: 30ch` |
| `%` | Percentage of monitor dimension | `width: 40%` |
| `mm` | Physical millimeters | `padding: 2mm` |

### 6.5 Math in Sizes

```rasi
width: calc( 100% - 40px );
width: calc( 40% min 500px );
```

### 6.6 Transparency Modes

| Mode | Value | Requires |
|------|-------|----------|
| Real ARGB | `"real"` | Compositor (Hyprland) |
| Fake screenshot | `"screenshot"` | Nothing (slow on 4K) |
| Root background | `"background"` | Root window image |
| Custom image | `"/path/to/img.png"` | PNG file |

---

## 7. Usage

### 7.1 Keybind

| Keybind | Action |
|---------|--------|
| `SUPER + SPACE` | Open rofi in drun (app launcher) mode |

### 7.2 Navigation

| Key | Action |
|-----|--------|
| `↑` / `↓` | Navigate list |
| `Enter` | Launch selected |
| `Escape` | Close |
| `Ctrl + Tab` | Switch mode (LAUNCH → RUN → WINDOW) |
| `Ctrl + Space` | Toggle case sensitivity |

### 7.3 What It Shows

- **LAUNCH mode**: Installed applications from `.desktop` files
- **RUN mode**: Typed commands (uses `PATH`)
- **WINDOW mode**: Open windows on all workspaces

---

## 8. Cross-References

| Resource | Location |
|----------|----------|
| Rofi config card | `arch-hyprland-rice/hyprland-rice-showcase.html` (section `<!-- ROFI -->`) |
| Rofi mockup popup | Same HTML, inside `.hypr-desktop` (`.rofi-popup` div) |
| Keybind declaration | `binds.lua` tab: `SUPER + SPACE` → `rofi -show drun` |
| Keybinds table | HTML keybinds section: `SUPER + SPACE` → `rofi drun` |
| Hyprland setup | [`HYPRLAND-SETUP.md`](./HYPRLAND-SETUP.md) — installation, ecosystem table |
| Waybar setup | [`WAYBAR-SETUP.md`](./WAYBAR-SETUP.md) — (not directly related) |
| Palette reference | CGGX CSS variables in `:root` (HTML) and Waybar `colors/cggx.css` |

---

> **Last updated:** 2026-05-31
> **Status:** ✅ Complete — config.rasi written, mockup shown, keybind set.
