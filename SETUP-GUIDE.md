# CGGX Rice — Full Setup Guide

> **From a fresh Arch Linux install to a fully functional CGGX Hyprland desktop.**
> This guide assumes you've already installed Arch Linux (via Chris Titus, archinstall, or manual) and have working internet + `sudo` access.

---

## Table of Contents

1. [Post-Install Prep](#1-post-install-prep)
2. [Graphics & Drivers](#2-graphics--drivers)
3. [Core Desktop Packages](#3-core-desktop-packages)
4. [Ecosystem Packages](#4-ecosystem-packages)
5. [AUR Packages](#5-aur-packages)
6. [Fonts & Theming](#6-fonts--theming)
7. [Service Enablement](#7-service-enablement)
8. [Apply Configs](#8-apply-configs)
9. [Zsh Setup](#9-zsh-setup)
10. [Environment & Session](#10-environment--session)
11. [Reboot & Verify](#11-reboot--verify)
12. [Keybinds Reference](#12-keybinds-reference)

---

## 1. Post-Install Prep

### 1.1 Pacman Config

```bash
# Enable parallel downloads
sudo sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf

# Enable multilib (for 32-bit libs, optional but recommended)
sudo sed -i '/^\[multilib\]/,/^$/ s/^#//' /etc/pacman.conf

# Update
sudo pacman -Syu
```

### 1.2 Install AUR Helper (yay)

```bash
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay && makepkg -si
cd ~ && rm -rf /tmp/yay
```

> Chris Titus's script may install `yay` automatically. Skip this step if `yay` already exists.

---

## 2. Graphics & Drivers

**Intel GPU only** — skip this section for other GPUs.

```bash
sudo pacman -S --needed \
  mesa \
  vulkan-intel \
  intel-media-driver \
  libva-intel-driver
```

> `xf86-video-intel` is **not recommended** on Wayland — the modesetting driver (included with Xorg) is preferred.

---

## 3. Core Desktop Packages

Install the window manager, compositor, bar, launcher, yazi (terminal file manager), lock/idle daemons, and core Wayland infrastructure:

```bash
sudo pacman -S --needed \
  uwsm \
  waybar \
  rofi-wayland \
  swaync \
  kitty \
  yazi \
  hyprlock \
  hypridle \
  polkit-gnome \
  polkit-kde-agent \
  xdg-desktop-portal-hyprland \
  xdg-desktop-portal-gtk \
  qt5-wayland \
  qt6-wayland
```

> **⚠️ Hyprland version note:** Arch's `[extra]` repo currently has Hyprland 0.46.x, but this rice uses the **Lua config API** introduced in **0.55+**. You must install `hyprland-git` from the **AUR** instead (see [Section 5](#5-aur-packages)). The stock `pacman -S hyprland` will NOT parse `.lua` configs.

**What each provides:**

| Package | Role |
|---------|------|
| `uwsm` | User-defined Wayland session manager — launches Hyprland as a user unit |
| `waybar` | Status bar |
| `rofi-wayland` | App launcher / run dialog |
| `swaync` | Notification daemon + control center |
| `kitty` | Terminal emulator |
| `yazi` | Terminal file manager (Rust) |
| `hyprlock` | Lock screen |
| `hypridle` | Idle management daemon (auto-lock, dpms) |
| `polkit-gnome` | Polkit authentication agent |
| `polkit-kde-agent` | Alternative polkit agent (fallback) |
| `xdg-desktop-portal-hyprland` | Wayland screen capture / file picker portal |
| `xdg-desktop-portal-gtk` | GTK portal backend |
| `qt5-wayland` / `qt6-wayland` | Qt Wayland platform plugins (needed by qt apps) |

---

## 4. Ecosystem Packages

### 4.1 Audio & Media

```bash
sudo pacman -S --needed \
  pipewire \
  wireplumber \
  pipewire-pulse \
  pipewire-audio \
  pavucontrol
```

### 4.2 Screenshots & Color Picker

```bash
sudo pacman -S --needed \
  grim \
  slurp \
  swappy \
  hyprpicker
```

> `grim` + `slurp` are used by the `grimblast` script (installed from AUR below).
> `swappy` is the editor for screenshot region saves.

**Note on grimblast:** We install `grimblast-git` from the AUR (next section) because
it provides the standard grim/slurp wrapper used by Hyprland community scripts.
If you prefer, you can use `grim slurp -g "$(slurp)" - | swappy -f -` directly in scripts.

### 4.3 Clipboard

```bash
sudo pacman -S --needed \
  wl-clipboard \
  cliphist
```

### 4.4 Shell & Utilities

```bash
sudo pacman -S --needed \
  zsh \
  starship \
  btop \
  fastfetch \
  neovim \
  networkmanager \
  nm-connection-editor \
  network-manager-applet \
  bluez \
  bluez-utils \
  blueman
```

### 4.5 Wallpaper & Display

```bash
sudo pacman -S --needed \
  hyprpaper
```

### 4.6 Browser

Vivaldi is in the AUR — installed via `yay` in [Section 5](#5-aur-packages).

### 4.7 Theming (Icons & Cursor)

```bash
sudo pacman -S --needed \
  papirus-icon-theme \
  bibata-cursor-theme
```

> - **Papirus-Dark** is the icon theme referenced by the GTK-3/4 configs
> - **Bibata-Modern-Ice** is the cursor theme set via `XCURSOR_THEME` in `.zshenv`
> - Apply with `nwg-look` or manually via `~/.config/gtk-3.0/settings.ini`

### 4.8 AUR Helper (already installed above)

---

## 5. AUR Packages

```bash
# Hyprland (git) — 0.55+ with Lua config support
# Arch's [extra] repo only has 0.46.x — Lua was introduced in 0.55
yay -S hyprland-git

# Vivaldi browser (AUR)
yay -S vivaldi vivaldi-ffmpeg-codecs

# SwayOSD — on-screen volume/brightness display
yay -S swayosd-git

# grimblast — grim/slurp wrapper (screenshots)
yay -S grimblast-git
```

> If `grimblast-git` build fails, check community alternatives or use `grim + slurp` directly.
>
> **Tip:** `hyprland-git` builds from the latest git commit. If a build fails,
> check the [Hyprland GitHub](https://github.com/hyprwm/Hyprland) for known
> issues, or install a specific tag version via the AUR's `PKGBUILD`.

---

## 6. Fonts & Theming

### 6.1 Required Fonts

```bash
sudo pacman -S --needed \
  noto-fonts \
  noto-fonts-emoji \
  ttf-jetbrains-mono-nerd \
  ttf-nerd-fonts-symbols-mono

# Share Tech Mono — used by Waybar, Kitty, Rofi, Hyprlock
# This is OPTIONAL but strongly recommended for the correct look
# If missing, apps will fall back to the system monospace font
yay -S ttf-share-tech-mono
```

> **Share Tech Mono is not optional for the intended look** — it's used in waybar
> (`font-family: 'Share Tech Mono'`), kitty (`font_family Share Tech Mono`),
> rofi (`font: "Share Tech Mono 10"`), hyprlock (`font_family = Share Tech Mono`),
> and all rofi-based scripts. Without it, every app falls back to a default monospace
> and the aesthetic breaks.

### 6.2 Cursor & Icons (optional)

```bash
yay -S bibata-cursor-theme papirus-icon-theme
```

> These are referenced in the config but won't break anything if missing — Hyprland
> will fall back to the system default cursor/icon theme.

### 6.3 GTK Theme

The config uses **Adwaita-dark** (included with `gtk3`).

```bash
sudo pacman -S --needed gtk3
```

---

## 7. Service Enablement

### 7.1 System Services

```bash
# PipeWire (audio)
systemctl --user enable --now pipewire
systemctl --user enable --now wireplumber

# Bluetooth
sudo systemctl enable --now bluetooth

# NetworkManager
sudo systemctl enable --now NetworkManager
```

### 7.2 Hyprland User Services (Recommended)

Replace `exec_cmd` daemon spawning with proper systemd user services for crash resilience and journalctl logging:

```bash
# Create service files
mkdir -p ~/.config/systemd/user
cp ~/arch-hyprland-rice/configs/systemd/user/*.service ~/.config/systemd/user/

# Enable and start all four
systemctl --user enable --now hyprpaper hypridle swaync cliphist

# Check logs if something isn't working
journalctl --user -u hyprpaper -f
journalctl --user -u hypridle -f
```

> ⚠️ If you use these services, **remove** the corresponding `hl.exec_cmd()` lines from `hyprland.lua` (hyprpaper, hypridle, swaync, wl-paste). The included `configs/hypr/hyprland.lua` already has them commented out with a note.

---

## 8. Apply Configs

### 8.1 Clone or Copy the Rice

```bash
# If you have the rice folder, copy everything:
cp -r arch-hyprland-rice/configs/* ~/.config/
```

Or if the configs are in a git repo:

```bash
git clone <your-rice-repo> ~/rice
cp -r ~/rice/configs/* ~/.config/
```

### 8.2 Set Up Wallpaper

```bash
mkdir -p ~/.local/share/wallpapers
cp /path/to/your/wallpaper.webp ~/.local/share/wallpapers/cggx.webp
```

> The hyprpaper config references `~/.local/share/wallpapers/cggx.webp`.
> Adjust the path in `~/.config/hypr/hyprpaper.conf` if your wallpaper is elsewhere.

### 8.3 Make Scripts Executable

```bash
chmod +x ~/.config/hypr/scripts/*.sh
```

### 8.4 Verify Config Structure

After copying, verify the layout:

```
~/.config/
├── hypr/
│   ├── hyprland.lua
│   ├── binds.lua
│   ├── settings.lua
│   ├── rules.lua
│   ├── animations.lua
│   ├── hyprpaper.conf
│   └── scripts/
│       ├── cliphist-rofi.sh
│       ├── power-menu.sh
│       ├── screenshot-menu.sh
│       └── screenshot-swappy.sh
├── waybar/
│   ├── config.jsonc
│   ├── style.css
│   └── modules/cggx.jsonc
├── swaync/
│   ├── config.json
│   └── style.css
├── swayosd/
│   └── style.css
├── kitty/
│   └── kitty.conf
├── rofi/
│   └── config.rasi
├── fastfetch/
│   └── config.jsonc
├── cliphist/
│   └── config
├── swappy/
│   └── config
├── shell/
│   ├── .zshenv
│   └── .zshrc
└── neovim/
    └── init.lua
```

### 8.5 Set Up Zsh Dotfiles

```bash
# The configs/shell/ folder contains .zshenv and .zshrc
# They need to be symlinked (or copied) to $HOME

ln -sf ~/.config/shell/.zshenv ~/.zshenv
ln -sf ~/.config/shell/.zshrc ~/.zshrc
```

> **Why `ln -sf`?** `.zshenv` must live at `~/.zshenv` — Zsh reads it from `$HOME`
> regardless of `ZDOTDIR`. The `.zshrc` can also be symlinked, or you can set
> `ZDOTDIR` in `.zshenv` if you prefer all zsh files under `~/.config/zsh/`.

---

## 9. Zsh Setup

### 9.1 Change Default Shell

```bash
chsh -s /usr/bin/zsh
```

> Log out and back in (or reboot) for the change to take effect.
> You can also run `zsh` to start using it immediately.

### 9.2 Starship Prompt

Starship is configured via `~/.config/starship.toml`. A custom CGGX-themed config
is included in the dotfiles — full CGGX palette, language modules, git status:

```bash
cp ~/arch-hyprland-rice/configs/starship.toml ~/.config/starship.toml
```

If you prefer to start from scratch and customize:

```bash
cp ~/arch-hyprland-rice/configs/starship.toml ~/.config/starship.toml
# Then edit ~/.config/starship.toml to your liking
```

The included config features: red `❯` prompt character, cyan directory,
purple git branch, lime/muted git status, orange rust indicator,
cyan python indicator, command duration, and an Arch OS logo.

### 9.3 Zsh Plugins (Optional)

The `.zshrc` is minimal by design. To add syntax highlighting and autosuggestions:

```bash
# Using zsh-completions, zsh-syntax-highlighting, zsh-autosuggestions
yay -S zsh-completions zsh-syntax-highlighting zsh-autosuggestions
```

Then uncomment or add to `~/.zshrc`:

```zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
```

---

## 10. Environment & Session

### 10.1 UWSM Environment

Create `~/.config/uwsm/env` if you need custom environment variables:

```bash
mkdir -p ~/.config/uwsm
```

For this rice, no special env vars are needed (Intel GPU, no NVIDIA quirks).
The defaults are sufficient.

### 10.2 Autostart

The Hyprland config uses the Lua API (`hl.exec_cmd()`) in `hyprland.lua` to start
daemons at startup:

```lua
hl.exec_cmd("waybar")
hl.exec_cmd("swayosd-server")
hl.exec_cmd("hyprpaper")
hl.exec_cmd("swaync")
hl.exec_cmd("nm-applet")
hl.exec_cmd("/usr/lib/polkit-gnome-authentication-agent-1")
hl.exec_cmd("wl-paste --watch cliphist store")
```

All daemons start with Hyprland. No need for a display manager (SDDM/GDM).

### 10.3 Starting Hyprland

From a TTY:

```bash
exec Hyprland
```

Or via UWSM (recommended for proper session management):

```bash
uwsm start hyprland
```

Add this to `~/.bash_profile` or `~/.zprofile` for auto-start on TTY login:

```bash
if [ -z "$WAYLAND_DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
  exec uwsm start hyprland
fi
```

> **Note:** Don't add this until you've verified everything works. Boot to TTY,
> start Hyprland manually with `uwsm start hyprland` first.

---

## 11. Reboot & Verify

### 11.1 First Boot

```bash
sudo reboot
```

After reboot, you'll be at a TTY. Start Hyprland:

```bash
uwsm start hyprland
```

### 11.2 Verification Checklist

| Check | Command / What to Look For |
|-------|---------------------------|
| Hyprland version | `hyprctl version` → should show 0.55+ |
| Workspaces | `SUPER+1..9` → switch between 9 workspaces |
| App launcher | `SUPER+SPACE` → Rofi drun pops up |
| Terminal | `SUPER+RETURN` → Kitty opens |
| Bar | Waybar visible at top edge, 9 workspace pills |
| Wallpaper | Hyprpaper shows CGGX wallpaper |
| Volume | Volume keys → SwayOSD popup with ♫ icon |
| Screenshots | `Print` → select region → clipboard; `SUPER+PRINT` → swappy editor |
| Notification | Run `notify-send "test"` → SwayNC popup top-right |
| Clipboard | `SUPER+C` → Rofi clipboard picker with history |
| Power menu | `SUPER+SHIFT+Q` → Rofi power menu (lock/logout/reboot/shutdown) |
| Bluetooth | `blueman-manager` from terminal |
| Network | nm-applet icon visible in Waybar tray |

### 11.3 Troubleshooting

If something doesn't work:

- **Logs**: `hyprctl getoption debug:enable_stdout_logs` (enable logging)
- **Config syntax**: `hyprctl systeminfo` shows loaded config files
- **Waybar**: Run `waybar` from terminal to see error output
- **SwayNC**: `swaync-client --reload-config` after config change
- **SwayOSD**: `swayosd-client --output-volume 50` to test
- **Rofi**: `rofi -show drun` from terminal to debug

See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for detailed fixes.

---

## 12. Keybinds Reference

| Binding | Action |
|---------|--------|
| `SUPER + Q` | Launch Kitty |
| `SUPER + SPACE` | App launcher (rofi -show drun) |
| `SUPER + E` | File manager (kitty -e yazi) |
| `SUPER + C` | Clipboard picker (cliphist-rofi.sh) |
| `SUPER + W` | Close focused window |
| `SUPER + 1..9` | Switch to workspace |
| `SUPER + SHIFT + 1..9` | Move window to workspace |
| `SUPER + L` | Lock screen (hyprlock) |
| `SUPER + SHIFT + Q` | Power menu (rofi) |
| `SUPER + SHIFT + ESC` | Exit Hyprland |
| `Print` | Screenshot region → clipboard (grimblast) |
| `SUPER + Print` | Screenshot region → swappy editor |
| `SUPER + SHIFT + Print` | Screenshot full screen → clipboard |
| `SUPER + D` | Screenshot menu (rofi) |
| `SUPER + V` | Toggle float |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + S` | Toggle scratchpad |
| Volume keys | Volume up/down/mute (SwayOSD) |
| Brightness keys | Brightness up/down (SwayOSD) |

---

## Full Package Checklist

Copy-paste this to install **everything at once**:

```bash
# Official repos
sudo pacman -S --needed \
  uwsm waybar rofi-wayland swaync kitty yazi \
  hyprlock hypridle polkit-gnome \
  polkit-kde-agent xdg-desktop-portal-hyprland xdg-desktop-portal-gtk qt5-wayland qt6-wayland \
  pipewire wireplumber pipewire-pulse pipewire-audio pavucontrol \
  grim slurp swappy hyprpicker wl-clipboard cliphist \
  zsh starship btop fastfetch neovim hyprpaper \
  networkmanager nm-connection-editor network-manager-applet \
  bluez bluez-utils blueman \
  papirus-icon-theme bibata-cursor-theme \
  noto-fonts noto-fonts-emoji ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols-mono \
  gtk3

# AUR
yay -S hyprland-git vivaldi vivaldi-ffmpeg-codecs swayosd-git grimblast-git ttf-share-tech-mono
```

Then:

```bash
# Copy configs
cp -r configs/* ~/.config/

# Scripts executable
chmod +x ~/.config/hypr/scripts/*.sh

# Zsh dotfiles
ln -sf ~/.config/shell/.zshenv ~/.zshenv
ln -sf ~/.config/shell/.zshrc ~/.zshrc

# Wallpaper
mkdir -p ~/.local/share/wallpapers
cp wallpaper.webp ~/.local/share/wallpapers/cggx.webp

# Services
systemctl --user enable --now pipewire wireplumber
sudo systemctl enable --now bluetooth NetworkManager

# Shell
chsh -s /usr/bin/zsh

# Done! Reboot and start Hyprland
sudo reboot
# → uwsm start hyprland
```

---

> **Next steps after verification:** hypridle (idle manager) and
> hyprlock (lockscreen) are already configured and auto-start.
> from this guide by design — the rice focuses on the kinetic desktop experience.
