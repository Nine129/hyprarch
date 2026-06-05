# CGGX Rice — Arch Linux Hyprland

> A documented, drop-in-ready Hyprland desktop rice in the CGGX style
> (red `#ff2d55` · cyan `#00e5ff` · lime `#c8ff00` · orange `#ff6b00` on dark `#0a0a0c`).

```
╭─ user@arch ~/hyprarch
╰─ $ ls
```

## Quick Start

**New to this rice? Start with [`SETUP-GUIDE.md`](./SETUP-GUIDE.md)** — it walks you
from a fresh Arch install to a fully functional CGGX desktop with every tool configured.

If you already have Arch and Hyprland installed, here's the tl;dr copy-paste:

```bash
# 1. Copy all configs
cp -r configs/* ~/.config/

# 2. Make scripts executable
chmod +x ~/.config/hypr/scripts/*.sh

# 3. Copy wallpaper
mkdir -p ~/.local/share/wallpapers
cp wallpapers/cggx.webp ~/.local/share/wallpapers/

# 4. Symlink Zsh dotfiles
ln -sf ~/.config/shell/.zshenv ~/.zshenv
ln -sf ~/.config/shell/.zshrc ~/.zshrc

# 5. Install packages (see SETUP-GUIDE.md §3-5 for full list)

# 6. Launch (after login)
uwsm start hyprland
```

## Folder Structure

```
hyprarch/
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
│   │                  animations.lua, hyprpaper.conf, hyprlock.conf, hypridle.conf
│   │                  scripts/ (rofi-launcher, power-profile, screenshot-menu, etc.)
│   ├── waybar/        style.css, config.jsonc, modules/cggx.jsonc, colors/cggx.css
│   ├── rofi/          config.rasi, power-profile.rasi
│   ├── swayosd/       style.css
│   ├── swappy/        config
│   ├── kitty/         kitty.conf
│   ├── swaync/        style.css, config.json
│   ├── fastfetch/     config.jsonc, logo.txt
│   ├── neovim/        init.lua (requires cggx module)
│   ├── btop/          btop.conf, themes/cggx.theme
│   ├── cliphist/      config
│   ├── shell/         .zshenv, .zshrc
│   ├── gtk-3.0/       settings.ini, gtk.css
│   ├── gtk/gtk-4.0/   gtk.css
│   ├── fontconfig/    fonts.conf
│   ├── starship.toml
│   ├── systemd/user/  cliphist.service, hypridle.service, hyprpaper.service, swaync.service
│   └── xdg/           mimeapps.list
│
├── wallpapers/
│   └── cggx.webp                     ← CGGX gradient wallpaper
│
└── waybar-import/                    ← Community Waybar presets (reference)
```

## Documentation Map

| Document | Covers |
|----------|--------|
| [`SETUP-GUIDE.md`](./SETUP-GUIDE.md) | Full install walkthrough — post-install prep, all packages, configs, services, Zsh, first-boot verification |
| [`HYPRLAND-SETUP.md`](./HYPRLAND-SETUP.md) | Arch install, Lua API, monitors, input, workspaces, Dwindle, decoration, blur, shadows, animations, window rules, keybinds, deployment |
| [`WAYBAR-SETUP.md`](./WAYBAR-SETUP.md) | Waybar research, 15+ community presets, decisions, 4-file config skeletons, deployment checklist |
| [`ROFI-SETUP.md`](./ROFI-SETUP.md) | Rofi documentation research, theme decisions, widget hierarchy, color formats, drun/run/window modes, installation |
| [`ECOSYSTEM-SETUP.md`](./ECOSYSTEM-SETUP.md) | Hyprpaper, SwayNC, Kitty, Fastfetch, Screenshots, SwayOSD, Zsh, Clipboard guides |
| [`TROUBLESHOOTING.md`](./TROUBLESHOOTING.md) | FAQs, common errors, fixes for all tools |

## Design Principles

- **Zero border-radius** everywhere — windows, Waybar, notifications, launcher
- **Floating pill modules** in Waybar — transparent bar, opaque `rgba(26,26,32,0.88)` islands
- **Blurred glass** surfaces — terminal `background_opacity 0.92`, notifications at 88%
- **9 workspaces** — 1→browser, 2→kitty dev, 3→kitty nvim
- **Hyprland Lua** config (0.55+) — split into 5 files, `require()`-based
- **Systemd user services** for waybar, hyprpaper, hypridle, swaync, cliphist
- **CGGX palette** — neon cyberpunk colors consistent across every tool
- **JetBrainsMonoNL Nerd Font Mono** — primary font for waybar, rofi, all UI
- **Colorful, not muted** — every tool gets vibrant category colors (lime docs, hot purple images, cyan archives, amber code)

## Keybinds

| Keys | Action |
|------|--------|
| `SUPER + Q` | Open kitty terminal |
| `SUPER + Super_L` (release) | Custom Rofi launcher (category-colored, Pango markup) |
| `SUPER + A` | Open Vivaldi browser |
| `SUPER + E` | Open kitty + yazi file manager |
| `SUPER + 1-9` | Switch workspace |
| `SUPER + SHIFT + 1-9` | Move window to workspace |
| `SUPER + arrow` | Focus window in direction |
| `SUPER + SHIFT + arrow` | Move window in direction |
| `SUPER + CTRL + arrow` | Swap window in direction |
| `SUPER + SHIFT + CTRL + arrow` | Resize window |
| `SUPER + Tab` | Focus last window |
| `SUPER + W` | Close focused window |
| `SUPER + F` | Fullscreen toggle |
| `SUPER + X` | Toggle float |
| `SUPER + V` | Clipboard history picker |
| `SUPER + SHIFT + C` | Clear clipboard history |
| `SUPER + S` | Toggle scratchpad |
| `SUPER + P` | Toggle pseudo-tiling |
| `SUPER + J` | Toggle split direction |
| `Print` | Region screenshot → clipboard (grimblast) |
| `SUPER + Print` | Region screenshot → swappy markup → auto-save |
| `SUPER + SHIFT + Print` | Full screenshot → clipboard |
| `SUPER + D` | Screenshot menu (full/region/swappy/clipboard) |
| `SUPER + L` | Lock screen (hyprlock) |
| `SUPER + SHIFT + Q` | Power menu (wlogout — shutdown/reboot/lock/logout/suspend) |
| `SUPER + SHIFT + Escape` | Exit Hyprland |
| `XF86AudioRaiseVolume` | Volume up (swayosd OSD) |
| `XF86AudioLowerVolume` | Volume down (swayosd OSD) |
| `XF86AudioMute` | Mute/unmute (swayosd OSD) |
| `XF86AudioMicMute` | Mic mute (swayosd OSD) |
| `XF86AudioNext/Prev/Play` | Media controls (swayosd/playerctl) |
| `XF86MonBrightnessUp` | Brightness up (swayosd OSD) |
| `XF86MonBrightnessDown` | Brightness down (swayosd OSD) |

## Palette Reference

```
  Base       #0a0a0c  ██████  Backgrounds
  Surface    #1a1a20  ██████  Panels, cards, pills
  Red        #ff2d55  ██████  Primary accent, active, critical
  Cyan       #00e5ff  ██████  Secondary accent, links, info
  Lime       #c8ff00  ██████  Git staged, success
  Orange     #ff6b00  ██████  Urgent, warnings
  Purple     #bd00ff  ██████  Dev entries (Rofi launcher)
  Pink       #ff007f  ██████  Game entries (Rofi launcher)
  Gold       #ffcc00  ██████  Office entries (Rofi launcher)
  Silver     #e8e8f0  ██████  Foreground text
  Muted      #6a6a80  ██████  Secondary text, inactive
  Border     #2a2a35  ██████  Subtle borders
```

---

## License

These configs are free to use, modify, and share. No attribution required.
