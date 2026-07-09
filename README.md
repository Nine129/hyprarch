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
├── FUZZEL-SETUP.md                   ← Fuzzel launcher, dmenu scripts, replacement for Rofi drun
├── ECOSYSTEM-SETUP.md                ← Hyprpaper, SwayNC, Kitty, Fastfetch, Screenshots, SwayOSD, Zsh, Clipboard, Zathura
├── MPD-MUSIC-SETUP.md                ← MPD daemon, rmpc TUI, cava visualizer, mpd-mpris bridge
├── CLI-TOOLS.md                      ← fzf, atuin, ghgrab, zoxide, eza, tealdeer
├── TROUBLESHOOTING.md                ← Common issues & fixes
│
├── configs/
│   ├── hypr/          hyprland.lua, settings.lua, binds.lua, rules.lua,
│   │                  animations.lua, hyprpaper.conf, hyprlock.conf, hypridle.conf
│   │                  scripts/ (launchers, screenshot, clipboard, power, etc.)
│   ├── waybar/        style.css, config.jsonc, modules/cggx.jsonc, colors/cggx.css
│   ├── fuzzel/        fuzzel.ini, scripts/power-menu.sh
│   ├── rofi/          config.rasi, power-profile.rasi
│   ├── swayosd/       style.css, config.toml
│   ├── swaync/        style.css, config.json
│   ├── wlogout/       layout, style.css, icons/
│   ├── kitty/         kitty.conf, rainbow-trail.conf
│   ├── fastfetch/     config.jsonc, logo.txt, logo PNGs
│   ├── neovim/        init.lua, lua/
│   ├── btop/          btop.conf, themes/cggx.theme
│   ├── yazi/          yazi.toml, theme.toml, keymap.toml, init.lua, plugins/
│   ├── mpd/           mpd.conf
│   ├── rmpc/          config.ron, notify.sh, themes/
│   ├── atuin/         config.toml, themes/cggx.toml
│   ├── fzf/           fzf.zsh, preview.sh, open_file.sh, show_image.sh
│   ├── ghgrab/        theme.toml
│   ├── vesktop/       themes/Translucence.theme.css
│   ├── otter-launcher/  config.toml, images/
│   ├── cliphist/      config
│   ├── swappy/        config
│   ├── zathura/       zathurarc
│   ├── shell/         .zshenv, .zshrc, .zprofile
│   ├── gtk-3.0/       settings.ini
│   ├── gtk/gtk-4.0/   gtk.css
│   ├── fontconfig/    fonts.conf
│   ├── starship.toml
│   ├── systemd/user/  cliphist, hypridle, hyprpaper, swaync, download-organizer, mpd-mpris
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
| [`HYPRLAND-SETUP.md`](./HYPRLAND-SETUP.md) | Arch install, Lua API, monitors, input, workspaces, Dwindle, decoration, blur, shadows, animations, window rules, keybinds, deployment, lock/idle |
| [`WAYBAR-SETUP.md`](./WAYBAR-SETUP.md) | Waybar research, 15+ community presets, decisions, 4-file config skeletons, deployment checklist |
| [`ROFI-SETUP.md`](./ROFI-SETUP.md) | Rofi documentation research, theme decisions, widget hierarchy, color formats, drun/run/window modes, installation |
| [`FUZZEL-SETUP.md`](./FUZZEL-SETUP.md) | Fuzzel Wayland-native launcher, dmenu scripts, keybinds, migration from Rofi |
| [`ECOSYSTEM-SETUP.md`](./ECOSYSTEM-SETUP.md) | Hyprpaper, SwayNC, Kitty, Fastfetch, Screenshots, SwayOSD, Zsh, Clipboard, Zathura, Downloads Sorter, Fontconfig |
| [`MPD-MUSIC-SETUP.md`](./MPD-MUSIC-SETUP.md) | MPD daemon, rmpc TUI, cava visualizer, mpd-mpris bridge, Waybar integration |
| [`CLI-TOOLS.md`](./CLI-TOOLS.md) | fzf, atuin, ghgrab, zoxide, eza, tealdeer — terminal productivity layer |
| [`TROUBLESHOOTING.md`](./TROUBLESHOOTING.md) | FAQs, common errors, fixes for all tools |
- **Floating pill modules** in Waybar — transparent bar, opaque `#151518` islands
- **Sharp aesthetic** — minimal border-radius (8px windows, 12px launcher)
- **5 persistent workspaces** in Waybar — 1→browser, 2→kitty dev, 3→kitty nvim
- **Hyprland Lua** config (0.55+) — split into 5 files, `require()`-based
- **Systemd user services** — waybar, hyprpaper, hypridle, swaync, cliphist, mpd, mpd-mpris, download-organizer
- **Fuzzel** replaces Rofi as primary launcher — Wayland-native, faster startup
- **CGGX palette** — neon cyberpunk colors consistent across every tool (20+ tools themed)
- **MonaspiceNe Nerd Font** — primary font for waybar, fuzzel, rofi, kitty, all UI
- **Music stack** — MPD daemon + rmpc TUI + cava visualizer + mpd-mpris bridge
- **Colorful, not muted** — every tool gets vibrant category colors (lime docs, orange music, cyan archives, amber code)
## Keybinds

| Keys | Action |
|------|--------|
| `SUPER + Q` | Open kitty terminal |
| `SUPER + SHIFT + Q` | Float kitty terminal |
| `SUPER + Super_L` (release) | Fuzzel launcher (app search) |
| `SUPER + Backspace` | Otter-launcher (terminal launcher) |
| `SUPER + A` | Open Vivaldi browser |
| `SUPER + E` | Open kitty + yazi file manager |
| `SUPER + D` | rmpc toggle pause (music) |
| `SUPER + SHIFT + D` | rmpc next track |
| `SUPER + CTRL + D` | rmpc previous track |
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
| `SUPER + V` | Clipboard history picker (fuzzel) |
| `SUPER + SHIFT + C` | Clear clipboard history |
| `SUPER + S` | Toggle scratchpad |
| `SUPER + P` | Toggle pseudo-tiling |
| `SUPER + J` | Toggle split direction |
| `SUPER + G` | Scroll overview (hyprpm plugin) |
| `Print` | Region screenshot → clipboard (grimblast) |
| `SUPER + Print` | Region screenshot → swappy markup → auto-save |
| `SUPER + SHIFT + Print` | Full screenshot → clipboard |
| `CTRL + Print` | Screenshot menu (fuzzel dmenu) |
| `SUPER + L` | Lock screen (hyprlock) |
| `SUPER + SHIFT + Q` | Power menu (fuzzel dmenu) |
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
