# CGGX Rice — Arch Linux Hyprland

> A documented, drop-in-ready Hyprland desktop rice in the CGGX style
> (red `#ff2d55` · cyan `#00e5ff` · lime `#c8ff00` · orange `#ff6b00` on dark `#0a0a0c`).

```
╭─ user@arch ~/arch-hyprland-rice
╰─ $ ls
```

## Quick Start

**New to this rice? Start with [`SETUP-GUIDE.md`](./SETUP-GUIDE.md)** — it walks you
from a fresh Arch install to a fully functional CGGX desktop with every tool configured.

If you already have Arch and Hyprland installed, here's the tl;dr copy-paste:

```bash
# 1. Copy all configs
cp -r configs/hypr/*    ~/.config/hypr/
mkdir -p ~/.config/waybar/modules ~/.config/waybar/colors
cp configs/waybar/style.css ~/.config/waybar/
cp configs/waybar/config.jsonc ~/.config/waybar/
cp configs/waybar/modules/cggx.jsonc ~/.config/waybar/modules/
cp configs/waybar/colors/cggx.css ~/.config/waybar/colors/
cp configs/rofi/config.rasi ~/.config/rofi/
cp configs/kitty/kitty.conf ~/.config/kitty/
cp -r configs/swaync/ ~/.config/swaync/
cp configs/fastfetch/config.jsonc ~/.config/fastfetch/
cp configs/neovim/init.lua ~/.config/nvim/
cp configs/shell/.zshenv ~/
cp configs/shell/.zshrc ~/

# 2. Copy wallpaper
mkdir -p ~/.local/share/wallpapers
cp wallpapers/cggx.webp ~/.local/share/wallpapers/

# 3. Install packages
sudo pacman -S hyprland hyprpaper waybar rofi swaync kitty fastfetch neovim zsh \
  grim slurp swappy wl-clipboard cliphist \
  pavucontrol brightnessctl playerctl \
  polkit-gnome nm-connection-editor network-manager-applet \
  ttf-share-tech-mono nerd-fonts

# 4. Launch (after login)
uwsm start hyprland
```

## Folder Structure

```
arch-hyprland-rice/
├── README.md                         ← You are here
├── hyprland-rice-showcase.html       ← Visual showcase (open in browser)
│
├── SETUP-GUIDE.md                    ← Step-by-step from fresh Arch install to full desktop
├── HYPRLAND-SETUP.md                 ← Hyprland architecture, decisions, Lua config
├── WAYBAR-SETUP.md                   ← Waybar research, modules, styling
├── ROFI-SETUP.md                     ← Rofi theming, widget hierarchy
├── ECOSYSTEM-SETUP.md                ← Hyprpaper, SwayNC, Kitty, Fastfetch, Screenshots, SwayOSD, Zsh, Clipboard
├── TROUBLESHOOTING.md                ← Common issues & fixes
│
├── configs/
│   ├── hypr/          hyprland.lua, settings.lua, binds.lua, rules.lua,
│   │                  animations.lua, hyprpaper.conf
│   ├── waybar/        style.css, config.jsonc, modules/cggx.jsonc, colors/cggx.css
│   ├── rofi/          config.rasi
  ├── swayosd/       style.css
  ├── swappy/        config
│   ├── kitty/         kitty.conf
│   ├── swaync/        style.css, config.json
│   ├── fastfetch/     config.jsonc
│   ├── neovim/        init.lua
│   ├── shell/         .zshenv, .zshrc
│   └── gtk/           settings.ini
│
├── wallpapers/
│   └── cggx.webp                     ← CGGX gradient wallpaper
│
└── waybar-import/                    ← Community Waybar presets (reference)
```

## Documentation Map

| Document | Covers | Length |
|----------|--------|--------|
| [`SETUP-GUIDE.md`](./SETUP-GUIDE.md) | **Full install walkthrough** — post-install prep, all packages, configs, services, Zsh, first-boot verification | — |
| [`HYPRLAND-SETUP.md`](./HYPRLAND-SETUP.md) | Arch install, Lua API, monitors, input, workspaces, Dwindle, decoration, blur, shadows, animations, window rules, keybinds, window rules, deployment | 595 lines |
| [`WAYBAR-SETUP.md`](./WAYBAR-SETUP.md) | Waybar research, 15+ community presets, decisions, 4-file config skeletons, deployment checklist | 524 lines |
| [`ROFI-SETUP.md`](./ROFI-SETUP.md) | Rofi documentation research, theme decisions, widget hierarchy, color formats, drun/run/window modes, installation | 419 lines |
| [`ECOSYSTEM-SETUP.md`](./ECOSYSTEM-SETUP.md) | Hyprpaper (hyprlang format), SwayNC (CSS theme, widgets), Kitty (palette, keybinds), Fastfetch (logo colors, modules), Screenshots, SwayOSD, Zsh (prompt, aliases) | — |
| [`TROUBLESHOOTING.md`](./TROUBLESHOOTING.md) | FAQs, common errors, fixes for all tools | — |

## Design Principles

- **Zero border-radius** everywhere — windows, Waybar, notifications, launcher
- **Floating pill modules** in Waybar — transparent bar, opaque `rgba(26,26,32,0.88)` islands
- **Blurred glass** surfaces — terminal `background_opacity 0.92`, Rofi popup at 70%, notifications at 88%
- **9 workspaces** — 1→browser, 2→kitty dev, 3→kitty nvim
- **Hyprland Lua** config (0.55+) — split into 5 files, `require()`-based
- **CGGX palette** — consistent across every tool

## Keybinds

| Keys | Action |
|------|--------|
| `SUPER + Q` | Open kitty terminal |
| `SUPER + SPACE` | Rofi app launcher (`drun`) |
| `SUPER + 1-9` | Switch workspace |
| `SUPER + SHIFT + 1-9` | Move window to workspace |
| `SUPER + arrow` | Focus window in direction |
| `SUPER + SHIFT + arrow` | Move window in direction |
| `SUPER + W` | Close focused window |
| `SUPER + F` | Fullscreen toggle |
| `SUPER + V` | Toggle float |
| `SUPER + S` | Toggle scratchpad |
| `Print` | Region screenshot → clipboard (grimblast) |
| `SUPER + Print` | Region screenshot → swappy markup → auto-save |
| `SUPER + SHIFT + Print` | Full screenshot → clipboard |
| `SUPER + D` | Screenshot menu (full/region/swappy/clipboard) |
| `SUPER + SHIFT + Q` | Power menu (shutdown/reboot/lock/logout/suspend) |
| `XF86AudioRaiseVolume` | Volume up (swayosd OSD) |
| `XF86AudioLowerVolume` | Volume down (swayosd OSD) |
| `XF86AudioMute` | Mute/unmute (swayosd OSD) |
| `XF86MonBrightnessUp` | Brightness up (swayosd OSD) |
| `XF86MonBrightnessDown` | Brightness down (swayosd OSD) |
| `SUPER + L` | Lock screen (hyprlock) |
| `SUPER + C` | Clipboard history picker |
| `SUPER + SHIFT + C` | Clear clipboard history |

## Palette Reference

```
  Base       #0a0a0c  ██████  Backgrounds
  Surface    #1a1a20  ██████  Panels, cards, pills
  Red        #ff2d55  ██████  Primary accent, active, critical
  Cyan       #00e5ff  ██████  Secondary accent, links, info
  Lime       #c8ff00  ██████  Git staged, success
  Orange     #ff6b00  ██████  Urgent, warnings
  Silver     #e8e8f0  ██████  Foreground text
  Muted      #6a6a80  ██████  Secondary text, inactive
  Border     #2a2a35  ██████  Subtle borders
```

---

## License

These configs are free to use, modify, and share. No attribution required.
