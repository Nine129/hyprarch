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

Install the window manager, compositor, bar, launchers, yazi (terminal file manager), lock/idle daemons, and core Wayland infrastructure:

```bash
sudo pacman -S --needed \
  hyprland \
  uwsm \
  waybar \
  fuzzel \
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

**What each provides:**

| Package | Role |
|---------|------|
| `uwsm` | User-defined Wayland session manager — launches Hyprland as a user unit |
| `waybar` | Status bar |
| `fuzzel` | Wayland-native app launcher / dmenu replacement |
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
  pipewire-alsa \
  pipewire-audio \
  pavucontrol \
  mpd \
  rmpc \
  cava \
  mpd-mpris
```

> **MPD** is the Music Player Daemon — a headless music server. **rmpc** is a Rust TUI client
> for MPD with CGGX theming. **cava** is a terminal audio visualizer. **mpd-mpris** bridges MPD
> to the MPRIS D-Bus interface so media keys and Waybar can control playback.

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
  lesspipe \
  networkmanager \
  nm-connection-editor \
  network-manager-applet \
  bluez \
  bluez-utils \
  blueman \
  playerctl \
  fd \
  ripgrep \
  bat \
  tealdeer \
  zoxide \
  eza \
  atuin \
  brightnessctl \
  p7zip \
  unrar \
  xdg-utils \
  yt-dlp \
  python-mutagen
```

> **zoxide** is a smarter `cd` command (replaces `autojump`). **eza** is a modern `ls` replacement
> with colors and icons. **atuin** provides magical shell history with sync, search, and CGGX theming.

### 4.5 Media & Document Viewers

```bash
sudo pacman -S --needed \
  mpv \
  imv \
  zathura \
  zathura-pdf-mupdf
```

### 4.6 Audio Effects

```bash
sudo pacman -S --needed \
  easyeffects
```

### 4.7 Wallpaper & Display

```bash
sudo pacman -S --needed \
  hyprpaper
```

### 4.8 Browser

Vivaldi is in the AUR — installed via `yay` in [Section 5](#5-aur-packages).
Vesktop (Discord client with Vencord theming) is also in the AUR — installed alongside Vivaldi in [Section 5](#5-aur-packages).

### 4.9 Theming (Icons & Cursor)

```bash
sudo pacman -S --needed \
  papirus-icon-theme
```

> - **Papirus-Dark** is the icon theme referenced by the GTK-3/4 configs
> - **Bibata-Modern-Ice** is the cursor theme set via `XCURSOR_THEME` in `.zshenv`
> - Apply with `nwg-look` or manually via `~/.config/gtk-3.0/settings.ini`

### 4.10 Launcher

Fuzzel is the primary Wayland-native app launcher — installed with the core packages in [Section 3](#3-core-desktop-packages).

### 4.11 AUR Helper (already installed above)

---

## 5. AUR Packages

```bash
# Vivaldi browser (AUR)
yay -S vivaldi vivaldi-ffmpeg-codecs

# Vesktop — Discord client with theming support
yay -S vesktop-bin

# SwayOSD — on-screen volume/brightness display
yay -S swayosd-git

# grimblast — grim/slurp wrapper (screenshots)
yay -S grimblast-git

# GhGrab — GitHub release downloader
yay -S ghgrab-bin

# Otter Launcher — terminal-based app launcher
yay -S otter-launcher

# Wlogout — Wayland-native logout/power menu
yay -S wlogout-git

# Timeshift — system snapshot / rollback
yay -S timeshift
```

> If `grimblast-git` build fails, check community alternatives or use `grim + slurp` directly.
> `otter-launcher` requires `wl-clipboard` and a terminal emulator (kitty).

---

## 6. Fonts & Theming

### 6.1 Required Fonts

```bash
sudo pacman -S --needed \
  noto-fonts \
  noto-fonts-emoji \
  noto-fonts-cjk \
  otf-monaspace-nerd \
  ttf-monaspace-variable \
  ttf-nerd-fonts-symbols-mono \
  ttf-sharetech-mono-nerd \
  ttf-liberation
```

```bash
# AUR fonts (required by fontconfig)
yay -S ttf-rajdhani ttf-exo-2
```

> **MonaspiceNe Nerd Font Mono** is the primary font used across Waybar, Rofi,
> Fuzzel, Kitty, Hyprlock, and all app launchers. It's included in `otf-monaspace-nerd`.
> `ttf-monaspace-variable` provides the variable-width variant for modern terminals.
> `ttf-sharetech-mono-nerd` is used for Waybar module icons and labels.
> `ttf-rajdhani` and `ttf-exo-2` are required by the fontconfig (`fonts.conf`) configuration.
> Without these fonts, every app falls back to a default monospace and the aesthetic breaks.

### 6.2 Cursor & Icons (optional)

```bash
yay -S bibata-cursor-theme papirus-icon-theme
```

> These are referenced in the config but won't break anything if missing — Hyprland
> will fall back to the system default cursor/icon theme.

### 6.3 GTK Theme

The config uses **Colloid-Red-Dark** (installed via `colloid-icon-theme` or AUR).

```bash
yay -S colloid-icon-theme
```

> Set in `~/.config/gtk-3.0/settings.ini` as `gtk-theme-name=Colloid-Red-Dark`.
> Icon theme is **Papirus-Dark**. Cursor is **Bibata-Modern-Ice**.

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
cp ~/hyprarch/configs/systemd/user/*.service ~/.config/systemd/user/

# Enable and start all services
systemctl --user enable --now hyprpaper hypridle swaync cliphist mpd mpd-mpris download-organizer

# Waybar drop-in for restart-on-failure
mkdir -p ~/.config/systemd/user/waybar.service.d
cp ~/hyprarch/configs/systemd/user/waybar.service.d/*.conf ~/.config/systemd/user/waybar.service.d/

# Check logs if something isn't working
journalctl --user -u hyprpaper -f
journalctl --user -u mpd -f
```

> ⚠️ If you use these services, **remove** the corresponding `hl.exec_cmd()` lines from `hyprland.lua` (hyprpaper, hypridle, swaync, wl-paste). The included `configs/hypr/hyprland.lua` already has them commented out with a note.

### 7.3 Bluetooth Service

Enable the Bluetooth stack system-wide:

```bash
sudo systemctl enable --now bluetooth
```

### 7.4 Keyd — Keyboard Remapping Daemon (Optional)

Keyd remaps keys at the kernel level via `/dev/uinput`. Install and enable for CapsLock→Ctrl,
Esc→CapsLock, or other keyboard remappings:

```bash
yay -S keyd
sudo systemctl enable --now keyd
```

> Default config at `/etc/keyd/default.conf`. The rice does not ship a keyd config — configure to taste.

### 7.5 Tealdeer (tldr) Cache

Populate the offline cheat-sheet cache:

```bash
tldr --update
```


### 7.6 Default Applications (MIME)

Copy the provided `mimeapps.list` to register Vivaldi (browser), Zathura (PDF), imv (images), mpv (media), nvim (text/code), and Yazi (files/archives) as system defaults:

```bash
### 7.6 Default Applications (MIME)
ln -sf ~/hyprarch/configs/xdg/mimeapps.list ~/.config/xdg/mimeapps.list
```

Reload the MIME database:

```bash
xdg-mime default vivaldi-stable.desktop x-scheme-handler/https
```

### 7.7 Timeshift Backups

Timeshift creates system snapshots for rollback after bad updates or config mistakes. It uses cronie for automatic scheduling.

```bash
# Enable the scheduler
sudo systemctl enable --now cronie

# Install Timeshift (AUR)
yay -S timeshift
```

**Configuration (GUI):**

1. Launch: `pkexec timeshift-gtk`
2. Choose snapshot type:
   - **BTRFS** — if your root partition uses BTRFS
   - **RSYNC** — if ext4 (Arch default for most fresh installs)
3. Select the snapshot device (usually the root partition)
4. Set the schedule:
   - Daily:   5 snapshots, keep last **3**
   - Weekly:  3 snapshots, keep last **2**
   - Monthly: 2 snapshots, keep last 1
5. Click **Create** to take the first manual snapshot

**CLI quick reference:**

```bash
# Manual snapshot before risky operations
sudo timeshift --create --comments "before-update"

# List existing snapshots
sudo timeshift --list

# Restore from snapshot
sudo timeshift --restore
```

---

## 8. Apply Configs

### 8.1 Clone or Copy the Rice

```bash
# If you have the rice folder, copy everything:
cp -r hyprarch/configs/* ~/.config/
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
│   ├── hyprlock.conf
│   ├── hypridle.conf
│   └── scripts/
│       ├── cliphist-fuzzel.sh
│       ├── power-menu.sh
│       ├── power-profile.sh          ← ACPI platform profile switcher
│       ├── screenshot-menu.sh
│       └── screenshot-swappy.sh
├── waybar/
│   ├── config.jsonc
│   ├── style.css
│   └── modules/cggx.jsonc
├── fuzzel/
│   ├── fuzzel.ini
│   └── scripts/
│       └── power-menu.sh
├── rofi/
│   ├── config.rasi
│   └── power-profile.rasi            ← power profile switcher theme
├── wlogout/
│   ├── layout
│   ├── style.css
│   └── icons/
├── swaync/
│   ├── config.json
│   └── style.css
├── swayosd/
│   ├── config.toml
│   └── style.css
├── kitty/
│   ├── kitty.conf
│   └── rainbow-trail.conf
├── fastfetch/
│   ├── config.jsonc
│   ├── logo.txt
│   └── logo PNGs
├── btop/
│   ├── btop.conf
│   └── themes/cggx.theme
├── yazi/
│   ├── yazi.toml
│   ├── theme.toml
│   ├── keymap.toml
│   ├── init.lua
│   └── plugins/
├── mpd/
│   └── mpd.conf
├── rmpc/
│   ├── config.ron
│   ├── notify.sh
│   └── themes/
├── atuin/
│   ├── config.toml
│   └── themes/cggx.toml
├── fzf/
│   ├── fzf.zsh
│   ├── preview.sh
│   ├── open_file.sh
│   └── show_image.sh
├── ghgrab/
│   └── theme.toml
├── vesktop/
│   └── themes/Translucence.theme.css
├── otter-launcher/
│   ├── config.toml
│   └── images/
├── cliphist/
│   └── config
├── swappy/
│   └── config
├── zathura/
│   └── zathurarc
├── shell/
│   ├── .zshenv
│   ├── .zshrc
│   └── .zprofile
├── fontconfig/
│   └── fonts.conf
├── gtk-3.0/
│   └── settings.ini
├── starship.toml
├── systemd/user/                     ← user services
│   ├── cliphist.service
│   ├── hypridle.service
│   ├── hyprpaper.service
│   ├── swaync.service
│   ├── mpd.service
│   ├── mpd-mpris.service
│   ├── download-organizer.service
│   └── waybar.service.d/             ← drop-in for waybar
└── neovim/
    └── init.lua
```

### 8.5 Sudoers Rule — Power Profile Switching

The power profile switcher (`power-profile.sh`) writes to `/sys/firmware/acpi/platform_profile`
which requires root. Create a passwordless sudo rule so the script can switch profiles
without prompting:

```bash
sudo visudo -f /etc/sudoers.d/power-profile
```

Add this line (replace `nine` with your username):

```
nine ALL=(root) NOPASSWD: /usr/bin/tee /sys/firmware/acpi/platform_profile
```

> **Security:** This only allows `tee` to write to that one sysfs file — no arbitrary
> root access. `power-profile.sh` is the only script that uses it.

### 8.6 Set Up Zsh Dotfiles

```bash
# The configs/shell/ folder contains .zshenv and .zshrc
# They need to be symlinked (or copied) to $HOME

ln -sf ~/.config/shell/.zshenv ~/.zshenv
ln -sf ~/.config/shell/.zshrc ~/.zshrc
```

> **Why `ln -sf`?** `.zshenv` must live at `~/.zshenv` — Zsh reads it from `$HOME`
> regardless of `ZDOTDIR`. The `.zshrc` can also be symlinked, or you can set
> `ZDOTDIR` in `.zshenv` if you prefer all zsh files under `~/.config/zsh/`.

### 8.7 Recolor Cursor Theme (Optional)

The default **Bibata-Modern-Ice** cursors use four different colors for the diagonal resize cursors (cyan, orange, lime, yellow). This step recolors the yellow ↘ SE-resize cursor to **purple** (`#b48cff`) to match the rice palette.

> **Dependencies:** `xorg-xcursorgen` and `imagemagick` (for image processing).

```bash
sudo pacman -S --needed xorg-xcursorgen imagemagick
```

**Recolor the bottom-right (SE-resize) cursor:**

```bash
cd ~/hyprarch/cursor-retool

# Generate the recolored PNG
python3 retool.py --colors colors.json

# Build the Xcursor binary
cd output
xcursorgen <<< "24 21 21 bottom_right_corner.png" > cursors/bottom_right_corner

# Install (replace system cursor)
sudo cp cursors/bottom_right_corner /usr/share/icons/Bibata-Modern-Ice/cursors/bottom_right_corner

# Log out and back in for changes to take effect
uwsm stop
```

> **Why this works:** The `retool.py` script loads the original Xcursor images via
> `libXcursor`, recolors the fill pixels to the target color while preserving the
> black outline and white corner tip, then outputs PNGs. `xcursorgen` rebuilds them
> into Xcursor format.
>
> To recolor other cursors, edit `colors.json` and re-run the pipeline. The cursor
> image cache only invalidates on a fresh session — `hyprctl setcursor` alone won't
> show the new image.

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
cp ~/hyprarch/configs/starship.toml ~/.config/starship.toml
```

If you prefer to start from scratch and customize:

```bash
cp ~/hyprarch/configs/starship.toml ~/.config/starship.toml
# Then edit ~/.config/starship.toml to your liking
```

The included config features: red `❯` prompt character, cyan directory,
purple git branch, lime/muted git status, orange rust indicator,
cyan python indicator, command duration, and an Arch OS logo.

### 9.3 Zsh Plugins (Optional)

The `.zshrc` is minimal by design. To add syntax highlighting and autosuggestions:

```bash
mkdir -p ~/.zsh/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions   ~/.zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting   ~/.zsh/plugins/zsh-syntax-highlighting
```

Then add to `~/.zshrc` (already included in the provided `.zshrc`):

```zsh
if [[ -d "$HOME/.zsh/plugins/zsh-autosuggestions" ]]; then
  source "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
if [[ -d "$HOME/.zsh/plugins/zsh-syntax-highlighting" ]]; then
  source "$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
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
daemons at startup. Some daemons (waybar, hyprpaper, swaync, cliphist) are managed
by systemd user services instead for crash resilience:

```lua
hl.on("hyprland.start", function()
  -- Managed by systemd user service (auto-restart on crash):
  -- hl.exec_cmd("waybar")
  hl.exec_cmd("swayosd-server")                            -- On-screen display (volume/brightness)
  -- Managed by systemd user services:
  -- hl.exec_cmd("hyprpaper")
  -- hl.exec_cmd("swaync")                                  -- Notification daemon + control center
  hl.exec_cmd("nm-applet")
  hl.exec_cmd("blueman-applet")                             -- Bluetooth tray icon
  hl.exec_cmd("/usr/lib/polkit-gnome-authentication-agent-1")
  -- Managed by systemd:
  -- hl.exec_cmd("wl-paste --watch cliphist store")         -- Clipboard history daemon
  -- Set wallpaper via IPC (hyprpaper v0.8.4 config preload doesn't work at startup)
  hl.exec_cmd("hyprctl hyprpaper wallpaper eDP-1,/home/nine/.local/share/wallpapers/cggx.webp")
  hl.exec_cmd("kitty --daemon")
  hl.exec_cmd("quickshell -p ~/.config/quickshell")
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("swaync")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("hyprpm enable scrolloverview")
  hl.dsp.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.dsp.exec_cmd("wl-paste --type image --watch cliphist store")
end)
```

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
| Workspaces | `SUPER+1..5` → switch between 5 workspaces |
| App launcher | `SUPER+Super_L` (release) → Fuzzel app search pops up |
| Terminal launcher | `SUPER+Backspace` → Otter-launcher opens |
| Terminal | `SUPER+Q` → Kitty opens |
| Bar | Waybar visible at top edge, 5 workspace pills |
| Wallpaper | Hyprpaper shows CGGX wallpaper |
| Volume | Volume keys → SwayOSD popup with ♫ icon |
| Screenshots | `Print` → select region → clipboard; `SUPER+PRINT` → swappy editor |
| Music | `SUPER+D` → rmpc toggle play/pause; media keys work |
| Notification | Run `notify-send "test"` → SwayNC popup top-right |
| Clipboard | `SUPER+V` → Fuzzel clipboard picker with history |
| Power menu | `SUPER+SHIFT+Q` → Fuzzel power menu (lock/logout/reboot/shutdown) |
| Screenshot menu | `CTRL+Print` → Fuzzel screenshot menu (full/region/swappy/clipboard) |
| Bluetooth | `blueman-manager` from terminal |
| Network | nm-applet icon visible in Waybar tray |
### 11.3 Troubleshooting

If something doesn't work:

- **Logs**: `hyprctl getoption debug:enable_stdout_logs` (enable logging)
- **Config syntax**: `hyprctl systeminfo` shows loaded config files
- **Waybar**: Run `waybar` from terminal to see error output
- **SwayNC**: `swaync-client --reload-config` after config change
- **SwayOSD**: `swayosd-client --output-volume 50` to test
- **Fuzzel**: `fuzzel --log-level=debug` from terminal to debug

See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for detailed fixes.

---

## 12. Keybinds Reference

| Binding | Action |
|---------|--------|
| `SUPER + Q` | Open kitty terminal |
| `SUPER + SHIFT + Q` | Float kitty terminal |
| `SUPER + Super_L` (release) | Fuzzel launcher (app search) |
| `SUPER + Backspace` | Otter-launcher (terminal launcher) |
| `SUPER + A` | Open Vivaldi browser |
| `SUPER + E` | Open kitty + yazi file manager |
| `SUPER + D` | rmpc toggle pause (music) |
| `SUPER + SHIFT + D` | rmpc next track |
| `SUPER + CTRL + D` | rmpc previous track |
| `SUPER + 1-5` | Switch workspace |
| `SUPER + SHIFT + 1-5` | Move window to workspace |
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
---

## Full Package Checklist

Copy-paste this to install **everything at once**:

```bash
# Official repos
sudo pacman -S --needed \
  hyprland uwsm waybar fuzzel swaync kitty yazi \
  hyprlock hypridle polkit-gnome \
  polkit-kde-agent xdg-desktop-portal-hyprland xdg-desktop-portal-gtk qt5-wayland qt6-wayland \
  pipewire wireplumber pipewire-pulse pipewire-alsa pipewire-audio pavucontrol \
  mpd rmpc cava mpd-mpris \
  grim slurp swappy hyprpicker wl-clipboard cliphist \
  zsh starship btop fastfetch neovim lesspipe hyprpaper \
  networkmanager nm-connection-editor network-manager-applet \
  bluez bluez-utils blueman playerctl \
  mpv imv zathura zathura-pdf-mupdf \
  fd ripgrep bat tealdeer zoxide eza atuin easyeffects brightnessctl p7zip unrar xdg-utils cronie \
  yt-dlp python-mutagen \
  papirus-icon-theme \
  noto-fonts noto-fonts-emoji noto-fonts-cjk \
  otf-monaspace-nerd ttf-monaspace-variable ttf-nerd-fonts-symbols-mono \
  ttf-sharetech-mono-nerd ttf-liberation

# AUR
yay -S vivaldi vivaldi-ffmpeg-codecs vesktop-bin swayosd-git grimblast-git \
  ghgrab-bin otter-launcher wlogout-git \
  ttf-rajdhani ttf-exo-2 \
  bibata-cursor-theme timeshift colloid-icon-theme keyd
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

# Power profile sudoers (replace 'nine' with your username)
echo 'nine ALL=(root) NOPASSWD: /usr/bin/tee /sys/firmware/acpi/platform_profile' | \
  sudo tee /etc/sudoers.d/power-profile

# Services
systemctl --user enable --now pipewire wireplumber
sudo systemctl enable --now bluetooth NetworkManager keyd

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
