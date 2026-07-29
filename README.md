# CGGX Rice — Arch Linux Hyprland

> A documented, drop-in-ready Hyprland desktop rice in the CGGX style
> (red `#ff2d55` · cyan `#00e5ff` · lime `#c8ff00` · orange `#ff6b00` on dark `#0a0a0c`).

## Quick Start

**New to this rice?** Start with [`docs/SETUP-GUIDE.md`](./docs/SETUP-GUIDE.md) — it walks you
from a fresh Arch install to a fully functional CGGX desktop with every tool configured.

If you already have Arch and Hyprland installed, here's the tl;dr:

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

# 5. Install packages (see SETUP-GUIDE.md for full list)

# 6. Launch (after login)
uwsm start hyprland
```

## Folder Structure

```
hyprarch/
├── README.md                         ← You are here
├── CONTEXT.md                        ← Domain glossary (colors, design terms)
├── packages_list                     ← Full package manifest
│
├── docs/                             ← Full documentation
│   ├── SETUP-GUIDE.md                ← Step-by-step from fresh Arch install to full desktop
│   ├── HYPRLAND-SETUP.md             ← Hyprland architecture, decisions, Lua config
│   ├── WAYBAR-SETUP.md               ← Waybar research, modules, styling
│   ├── ROFI-SETUP.md                 ← Rofi theming, widget hierarchy
│   ├── FUZZEL-SETUP.md               ← Fuzzel launcher, dmenu scripts
│   ├── ECOSYSTEM-SETUP.md            ← All ecosystem tools (20+ applications)
│   ├── MPD-MUSIC-SETUP.md            ← MPD daemon, rmpc TUI, cava visualizer
│   ├── CLI-TOOLS.md                  ← fzf, atuin, ghgrab, zoxide, eza, tealdeer, bat
│   ├── TROUBLESHOOTING.md            ← Common issues & fixes
│   └── starship-research.md          ← Starship presets research (reference)
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
│   ├── fastfetch/     config.jsonc, logo.txt, logo PNGs (xnewlogo.png)
│   ├── neovim/        init.lua, lua/ (NvChad-based, CGGX theme)
│   ├── btop/          btop.conf, themes/cggx.theme
│   ├── yazi/          yazi.toml, theme.toml, keymap.toml, init.lua, plugins/ (7 plugins)
│   ├── mpd/           mpd.conf
│   ├── rmpc/          config.ron, notify.sh, themes/ (cggx.ron)
│   ├── atuin/         config.toml, themes/cggx.toml
│   ├── fzf/           fzf.zsh, fzf-opts.sh, preview.sh, open_file.sh, show_image.sh
│   ├── ghgrab/        theme.toml
│   ├── bat/           config, themes/NvCGGX.tmTheme
│   ├── easyeffects/   db/ (compressor, equalizer, limiter, loudness, graph)
│   ├── pipewire/      pipewire.conf.d/ (99-quality.conf, 99-resample.conf)
│   ├── fcitx5/        config, profile, conf/ (Unikey Vietnamese IME)
│   ├── vesktop/       themes/Translucence.theme.css, settings/quickCss.css, settings/settings.json
│   ├── otter-launcher/  config.toml, images/
│   ├── cliphist/      config
│   ├── swappy/        config
│   ├── zathura/       zathurarc
│   ├── shell/         .zshenv, .zshrc, .zprofile
│   ├── autostart/     com.github.wwmm.easyeffects.desktop (EasyEffects tray service)
│   ├── gtk-3.0/       settings.ini, bookmarks
│   ├── gtk/gtk-4.0/   gtk.css
│   ├── fontconfig/    fonts.conf
│   ├── starship.toml
│   ├── systemd/user/  cliphist, hypridle, hyprpaper, swaync, waybar, mpd, mpd-mpris, download-organizer
│   ├── xdg/           mimeapps.list
│   └── xdg-desktop-portal/ hyprland-portals.conf (termfilechooser preferred)
│
├── applications/
│   ├── yazi.desktop              ← Terminal file manager desktop entry
│   ├── steam.desktop             ← Steam with CGGX env vars
│   ├── vivaldi-window.desktop    ← Vivaldi windowed mode entry
│   └── mimeinfo.cache            ← MIME type associations
│
├── scripts/
│   ├── osd-notify.sh             ← Volume/brightness OSD notification script
│   ├── termfilechooser-wrapper.sh ← Terminal file chooser wrapper
│   └── sync-packages-list        ← Sync package manifest
│
├── vivaldi/                      ← Vivaldi customization
│   ├── custom-css/cggx.css       ← CGGX-themed Vivaldi styles
│   ├── theme/ (cggx-dark.zip)    ← Vivaldi theme files
│   ├── README.md, DESIGN.md, RESEARCH.md
│   └── baseline                  ← Vivaldi baseline binary
│
├── downloads-sorter/             ← ~/Downloads auto-categorizer
│   ├── install.sh, config.yaml, download-organizer.service
│   └── README.md
│
├── wallpapers/
│   └── cggx.webp                 ← CGGX gradient wallpaper
│   └── gengar.jpg                ← Alternate wallpaper
│
└── hooks/                        ← Pacman hooks
    └── packages-list-sync.hook
```

## Documentation Map

| Document | Covers |
|----------|--------|
| [`docs/SETUP-GUIDE.md`](./docs/SETUP-GUIDE.md) | Full install walkthrough — post-install prep, all packages, configs, services, Zsh, verification |
| [`docs/HYPRLAND-SETUP.md`](./docs/HYPRLAND-SETUP.md) | Arch install, Lua API, monitors, input, workspaces, Dwindle, decoration, blur, shadows, animations, window rules, keybinds, deployment, lock/idle |
| [`docs/WAYBAR-SETUP.md`](./docs/WAYBAR-SETUP.md) | Waybar research, decisions, 4-file config skeleton, styling reference |
| [`docs/ROFI-SETUP.md`](./docs/ROFI-SETUP.md) | Rofi documentation research, theme decisions, widget hierarchy, color formats, drun/run/window modes |
| [`docs/FUZZEL-SETUP.md`](./docs/FUZZEL-SETUP.md) | Fuzzel Wayland-native launcher, dmenu scripts, keybinds, migration from Rofi |
| [`docs/ECOSYSTEM-SETUP.md`](./docs/ECOSYSTEM-SETUP.md) | 20+ tools: Hyprpaper, SwayNC, Kitty, Fastfetch, Screenshots, SwayOSD, Zsh, Clipboard, Zathura, Fontconfig, Downloads Sorter, Bat, EasyEffects, PipeWire, Fcitx5, Vesktop, Portal Filechooser |
| [`docs/MPD-MUSIC-SETUP.md`](./docs/MPD-MUSIC-SETUP.md) | MPD daemon, rmpc TUI, cava visualizer, mpd-mpris bridge, Waybar integration |
| [`docs/CLI-TOOLS.md`](./docs/CLI-TOOLS.md) | fzf, atuin, ghgrab, zoxide, eza, tealdeer, bat — terminal productivity layer |
| [`docs/TROUBLESHOOTING.md`](./docs/TROUBLESHOOTING.md) | FAQs, common errors, fixes for all 20+ tools |

## Features

- **Floating pill modules** in Waybar — transparent bar, opaque `#151518` islands
- **Sharp aesthetic** — minimal border-radius (8px windows, 0px internal UI)
- **5 persistent workspaces** in Waybar — 1→browser, 2→kitty dev, 3→kitty nvim
- **Hyprland Lua** config (0.55+) — split into 5 files, `require()`-based
- **Systemd user services** — waybar, hyprpaper, hypridle, swaync, cliphist, mpd, mpd-mpris, download-organizer
- **Fuzzel** primary launcher — Wayland-native, fast startup, replaces Rofi for app launch
- **Custom OSD** — `osd-notify.sh` replaces swayosd-client for volume/brightness with `notify-send` popups
- **CGGX palette** — neon cyberpunk colors consistent across 20+ tools
- **MonaspiceNe Nerd Font** — primary font for waybar, fuzzel, rofi, kitty, all UI
- **Music stack** — MPD daemon + rmpc TUI + cava visualizer + mpd-mpris bridge
- **PipeWire high-quality audio** — 96kHz sample rate, max quality resampling
- **EasyEffects audio chain** — compressor, equalizer, limiter, loudness, crossfeed
- **Fcitx5 input method** — Unikey Vietnamese IME with keyboard hotkeys
- **Vesktop (Discord) full theme** — Translucence CSS theme + frameless QuickCss
- **Bat cat replacement** — NvCGGX theme for syntax highlighting
- **XDG portals** — terminal file chooser preferred for GTK file dialogs
- **Custom `.desktop` entries** — Yazi, Steam, Vivaldi window mode
- **Colorful, not muted** — every tool gets vibrant category colors (lime docs, orange music, cyan archives, amber code)

## Keybinds

| Keys | Action |
|------|--------|
| `SUPER + Q` | Open kitty terminal |
| `SUPER + SHIFT + Q` | Power menu (wlogout) |
| `SUPER + CTRL + Q` | Float kitty terminal |
| `SUPER + Super_L` (release) | Fuzzel launcher (app search) |
| `SUPER + Backspace` | Otter-launcher (terminal launcher) |
| `SUPER + A` | Open Vivaldi browser |
| `SUPER + E` | Open kitty + yazi file manager |
| `SUPER + SHIFT + E` | Emoji/icon picker (latuicon) |
| `SUPER + R` | Open kitty + nvim |
| `SUPER + D` / `SUPER + Z` | rmpc toggle pause / open rmpc |
| `SUPER + period` | rmpc next track |
| `SUPER + comma` | rmpc previous track |
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
| `XF86AudioRaiseVolume` | Volume up (osd-notify) |
| `XF86AudioLowerVolume` | Volume down (osd-notify) |
| `XF86AudioMute` | Mute/unmute (osd-notify) |
| `XF86AudioMicMute` | Mic mute (osd-notify) |
| `XF86AudioNext/Prev/Play` | Media controls (swayosd-client/playerctl) |
| `XF86MonBrightnessUp/Down` | Brightness up/down (osd-notify) |

## Palette Reference

```
  Base       #0a0a0c  ██████  Backgrounds
  Surface    #151518  ██████  Panels, cards, pills
  Surface2   #1a1a20  ██████  Alt surfaces
  Border     #2a2a35  ██████  Subtle borders, separators
  Red        #ff2d55  ██████  Primary accent, active, critical
  Cyan       #00e5ff  ██████  Secondary accent, links, info
  Lime       #c8ff00  ██████  Git staged, success
  Orange     #ff6b00  ██████  Urgent, warnings
  Purple     #bd00ff  ██████  Developer tooling
  Pink       #ff007f  ██████  Game entries
  Gold       #ffcc00  ██████  Office entries
  Silver     #e8e8f0  ██████  Foreground text
  Muted      #6a6a80  ██████  Secondary text, inactive
```

## Related Projects

- [Vivaldi CGGX Theme](./vivaldi/) — Full CGGX theme for Vivaldi browser with custom CSS and theme files
- [downloads-sorter](./downloads-sorter/) — Inotify-based auto-categorizer for `~/Downloads`

---

## License

These configs are free to use, modify, and share. No attribution required.
