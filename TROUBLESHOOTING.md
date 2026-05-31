# CGGX Troubleshooting

> Common issues with the CGGX Hyprland rice and how to fix them.

---

## 1. Hyprland

### "Lua config not loading" / Hyprland starts with defaults

**Cause:** Config file is `hyprland.conf` instead of `hyprland.lua`.
**Fix:** Rename or recreate as `~/.config/hypr/hyprland.lua`. Hyprland 0.55+ only reads `.lua`.

---

### `require("settings")` fails

**Cause:** The Lua files aren't in the same directory as `hyprland.lua`.
**Fix:** Ensure all 5 files are in `~/.config/hypr/`:

```
~/.config/hypr/
├── hyprland.lua
├── settings.lua
├── binds.lua
├── rules.lua
└── animations.lua
```

---

### `hyprctl` returns "command not found"

**Fix:** Hyprland must be running for `hyprctl` to work. Verify with:

```bash
ps aux | grep hyprland
```

If not running, start uwsm:

```bash
uwsm start hyprland
```

---

### Workspace assignments don't work

**Cause:** Window rules may not match the application's `class` name.
**Fix:** Find the actual class name:

```bash
hyprctl clients | grep class
```

Then update `rules.lua`:

```lua
hl.window_rule({ class = "firefox",    workspace = 1 })
hl.window_rule({ class = "kitty",      workspace = 2 })
hl.window_rule({ class = "kitty",      workspace = 3, title = "nvim" })
```

---

## 2. Waybar

### Waybar shows blank / no modules

**Cause:** Missing `modules/cggx.jsonc` or incorrect include path.
**Fix:** Verify file structure:

```
~/.config/waybar/
├── config.jsonc
├── style.css
├── modules/
│   └── cggx.jsonc
└── colors/
    └── cggx.css
```

The `config.jsonc` includes:

```jsonc
"include": ["modules/cggx.jsonc", "colors/cggx.css"],
```

Restart Waybar:

```bash
killall waybar; waybar &
```

---

### Workspace numbers not showing

**Cause:** The `wlr/workspaces` module needs the `all-outputs` setting for a single-monitor setup.
**Fix:** In `modules/cggx.jsonc`, ensure:

```jsonc
"wlr/workspaces": {
    "format": "{icon}",
    "on-click": "activate",
    "all-outputs": true,
    "format-icons": {
        "1": "1", "2": "2", "3": "3", "4": "4",
        "5": "5", "6": "6", "7": "7", "8": "8", "9": "9"
    }
}
```

---

### Icons missing / squares instead of text

**Cause:** Missing or incorrect Nerd Font.
**Fix:** Install a Nerd Font:

```bash
sudo pacman -S nerd-fonts
# or specific: ttf-nerd-fonts-symbols
```

---

## 3. Rofi

### Rofi doesn't match the mockup

**Common causes:**

| Symptom | Fix |
|---------|-----|
| Rounded corners | Set `corner-radius: 0;` in `config.rasi` |
| Footer visible | `configuration { show-icons: true; }` — ensure no mode-switcher |
| No blur | Rofi doesn't support `backdrop-filter`. The glass effect uses `background-color: rgba(10,10,12,0.70);` |
| App names not cyan | Verify `element-text { text-color: @secondary; }` is in your `config.rasi` script section |
| Wrong colors | Check `@base`, `@primary`, `@secondary` values match the CGGX palette |

---

### Rofi won't open / "Failed to open display"

**Fix:** Rofi needs a running Wayland compositor:

```bash
echo $WAYLAND_DISPLAY
```

If empty, Rofi may fall back to X11. Ensure Hyprland is running.

---

### "Mode drun not found" error

**Cause:** Rofi's `drun` mode needs `.desktop` files.
**Fix:**

```bash
# Update desktop file cache
sudo update-desktop-database
# Or verify desktop files exist
ls /usr/share/applications/
```

---

## 4. Hyprpaper

### Wallpaper not showing

**Cause:** hyprlang format not supported (old hyprpaper version).
**Fix:** Check version:

```bash
hyprpaper --version
```

If < 0.8.4, the config uses the old syntax. Upgrade:

```bash
sudo pacman -Syu hyprpaper
```

---

### `hyprctl hyprpaper` not working

**Cause:** `ipc = false` or hyprpaper not running.
**Fix:**

```bash
# Check if running
ps aux | grep hyprpaper
# Enable IPC in config
echo "ipc = true" >> ~/.config/hypr/hyprpaper.conf
# Restart
killall hyprpaper; hyprpaper &
```

---

## 5. SwayNC

### No notification popups appear

**Symptom:** Media keys work, apps send notifications, but no popup shows.

**Fix:** Verify swaync is running:
```bash
pgrep -x swaync        # Should return a PID
# If not running:
swaync &
```

Then reload config:
```bash
swaync-client --reload-config
swaync-client --reload-css
```

Send a test notification:
```bash
notify-send "CGGX Test" "SwayNC is working!" -u normal
```

### Control center panel won't open

**Symptom:** `swaync-client -t -sw` produces no visible panel (or errors).

**Fix:** 
```bash
# Check if swaync is running
pgrep -x swaync
# If running, check for errors
swaync-client -t -sw
# Check config syntax validity
```

Common causes:
- **No widgets configured** → `"widgets"` array in `config.json` must include `"notifications"` at minimum
- **Missing `control-center-exclusive-zone`** → set to `false` so panel overlays Waybar
- **Control center hidden behind windows** → set `"control-center-layer": "overlay"` in config

### Popups/panel have rounded corners

**Symptom:** Notifications have pill/capsule shapes instead of sharp rectangles.

**Fix:** Add `--border-radius: 0` in `~/.config/swaync/style.css`:
```css
:root {
  --border-radius: 0;
}
```
Then reload CSS:
```bash
swaync-client --reload-css
```

### Notifications appear underneath Waybar

**Symptom:** Popups are hidden behind the Waybar bar at the top.

**Fix:** Ensure `"layer": "overlay"` in `config.json`:
```jsonc
{
  "layer": "overlay",        // Popups above all windows
  "control-center-layer": "top"
}
```
Also check that notification position doesn't overlap bar. Adjust in config:
```jsonc
{
  "positionX": "right",
  "positionY": "top"
}
```

### Media player (MPRIS) not showing in control center

**Symptom:** The control center opens but "Now Playing" section is empty even when music plays.

**Fix:**
```bash
# Check if mpris widget is in widgets array
# Required in config.json:
# "widgets": ["title", "dnd", "mpris", "notifications"]

# Check playerctl works standalone
playerctl metadata

# Ensure the player isn't blacklisted
# Default blacklist excludes "playerctld" — remove if not needed
```

### DND toggle has no effect

**Symptom:** Flipping Do Not Disturb doesn't suppress notifications.

**Fix:** Ensure `dnd` widget is in the config:
```jsonc
"widgets": ["title", "dnd", "mpris", "notifications"]
```
The DND state persists across restarts (stored in GSettings).

### Notifications not grouping by app

**Symptom:** Every notification appears as its own row instead of stacking by app.

**Fix:**
```jsonc
{
  "notification-grouping": true
}
```
Grouping is enabled by default. If it's still not working, ensure the notifications come from the same `desktop-entry`.

### Waybar notification module shows wrong count

**Symptom:** The icon/notification count in Waybar doesn't match actual notifications.

**Fix:** The Waybar module command should be:
```jsonc
"custom/notification": {
  "exec": "swaync-client -swb",
  "on-click": "swaync-client -t -sw",
  "return-type": "json"
}
```
The `-swb` flag outputs JSON with notification count + state.

### Notifications disappear too fast / too slow

**Symptom:** Popups vanish before you can read them (or linger forever).

**Fix:** Adjust timeout in `config.json`:
```jsonc
{
  "timeout": 10,          // normal urgency (seconds)
  "timeout-low": 5,       // low urgency
  "timeout-critical": 0   // 0 = persists until dismissed
}
```

### `swaync: command not found`

**Symptom:** Terminal says command not found.

**Fix:** Install from Arch repos:
```bash
sudo pacman -S swaync
```

---

## 6. Kitty

### Font not found — squares/fallback font shown

**Cause:** `Share Tech Mono` not installed.
**Fix:**

```bash
# From AUR
yay -S ttf-share-tech-mono
# Or use a Nerd Font fallback
# In kitty.conf:
font_family      JetBrainsMono Nerd Font
```

---

### Background opacity not working

**Cause:** Requires a compositor (Hyprland has one built-in, so this should work).
**Fix:** Ensure no `background` override in a theme file loaded after the opacity setting. In `kitty.conf`:

```conf
background_opacity 0.92
background         #0a0a0c
```

The `background` line must come **after** `background_opacity`.

---

### Colors don't match the palette

**Fix:** Ensure the 16 color values are correctly set. Verify with:

```bash
# Print current color table
kitty +run-shell 'printf "\e]4;0;?\e\\"'
```

If they're wrong, a later `include` may be overriding them. Place colors **last** in the config.

---

## 7. Zsh

### Prompt shows `$(git_prompt_info)` literally

**Cause:** `setopt PROMPT_SUBST` is missing.
**Fix:** Ensure this line is in `.zshrc`:

```zsh
setopt PROMPT_SUBST
```

---

### History not shared between terminals

**Cause:** Missing history options.
**Fix:** Ensure these are in `.zshrc`:

```zsh
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
```

---

### Aliases not working

**Cause:** Aliases defined after a command uses them, or the alias isn't sourced.
**Fix:** `source ~/.zshrc` to reload, or open a new terminal.

---

### Screenshot aliases fail (`grim: command not found`)

**Fix:** Install required tools:

```bash
sudo pacman -S grim slurp swappy jq
```

---

## 8. SwayOSD

### OSD popup doesn't appear

**Symptom:** Volume/brightness keys work but no overlay pops up.

**Fix:** Verify swayosd-server is running:
```bash
pgrep -x swayosd-server    # Should return a PID
# If not running:
killall swayosd-server 2>/dev/null; swayosd-server &
# Or restart Hyprland session
hyprctl reload config
```

Check that keybinds use `swayosd-client`, not raw `wpctl`:
```bash
# Should show swayosd-client commands
grep swayosd-client ~/.config/hypr/binds.lua
```

### OSD has rounded corners (doesn't match CGGX aesthetic)

**Symptom:** Popup bubbles have pill/capsule shape instead of sharp rectangles.

**Fix:** Edit `~/.config/swayosd/style.css` and ensure all `border-radius` values are `0`:
```css
window#osd {
  border-radius: 0;
}
progressbar {
  border-radius: 0;
}
trough, progress {
  border-radius: 0;
}
```
Then restart swayosd-server.

### `swayosd-client: command not found`

**Symptom:** Terminal says command not found when pressing media keys.

**Fix:** swayosd is not installed:
```bash
sudo pacman -S swayosd
```

### Volume jumps to 100% (won't go higher)

**Symptom:** `--max-volume 150` doesn't work.

**Fix:** Ensure `swayosd-client` uses the `--max-volume` flag:
```bash
swayosd-client --output-volume raise --max-volume 150
```
Also verify wireplumber allows >100%:
```bash
wpctl status | grep "Volume:"
```

### OSD on wrong monitor

**Symptom:** Popup appears on the wrong display in multi-monitor setup.

**Fix:** Pass the focused monitor name:
```bash
swayosd-client --monitor "$(hyprctl monitors -j | jq -r '.[] | select(.focused == true).name')" --output-volume raise
```

### Volume bar doesn't match the CGGX palette

**Symptom:** Progress bar uses system theme colors (blue/green) instead of red.

**Fix:** Update `style.css` with the correct CGGX colors:
```css
trough  { background: #6a6a80; }   /* Muted track */
progress { background: #ff2d55; }  /* Red accent fill */
```

---

## 9. General

### Config changes not taking effect

| Tool | Reload command |
|------|---------------|
| Hyprland | `hyprctl reload config` |
| Waybar | `killall waybar; waybar &` |
| Rofi | *(config read on launch)* |
| Hyprpaper | `killall hyprpaper; hyprpaper &` |
| SwayNC | `swaync-client --reload-config; swaync-client --reload-css` |
| Kitty | `kitty @ load-config` or `Ctrl+Shift+R` |
| Fastfetch | *(config read on launch)* |
| Zsh | `source ~/.zshrc` |

### Color mismatch between tools

All CGGX colors should be identical. Verify each tool against the reference:

```
  Base       #0a0a0c   ██████
  Surface    #1a1a20   ██████
  Red        #ff2d55   ██████
  Cyan       #00e5ff   ██████
  Lime       #c8ff00   ██████
  Orange     #ff6b00   ██████
  Silver     #e8e8f0   ██████
  Muted      #6a6a80   ██████
  Border     #2a2a35   ██████
```

### Still stuck?

Open the [showcase HTML](./hyprland-rice-showcase.html) and compare your config files to the reference configs displayed there, card by card.

---

## 10. Clipboard

### Clipboard history shows empty

**Cause:** The `cliphist store` daemon isn't running. It should autostart via Hyprland, but if you opened a terminal before Hyprland finished loading, or if the daemon crashed:

**Fix:**

```bash
# Check if running
ps aux | grep cliphist

# Start it manually
wl-paste --watch cliphist store &

# Verify
echo "test" | wl-copy
cliphist list | head -1
```

---

### Clipboard picker shows numbers (IDs) before each item

**Fix:** The script now passes `-display-columns 2` to hide the IDs. If your entry still shows them, ensure your `cliphist-rofi.sh` has:

```bash
rofi -dmenu -display-columns 2 -theme ~/.config/rofi/config.rasi
```

---

### "cliphist: unknown option" when running the picker

**Fix:** You may have an older cliphist version that doesn't support `-display-columns`. Run `cliphist version` and upgrade to the latest release from the [releases page](https://github.com/sentriz/cliphist/releases).

---

### `cliphist: command not found`

**Fix:**

```bash
sudo pacman -S cliphist
# Also need wl-clipboard
sudo pacman -S wl-clipboard
```

---

### Rofi clipboard picker script doesn't run

**Fix:** Ensure the script is executable:

```bash
chmod +x ~/.config/hypr/scripts/cliphist-rofi.sh
```

Also verify the path in `binds.lua` — it must use the absolute path `~/.config/hypr/scripts/cliphist-rofi.sh`.

---

### Copy stops working after app closes

**Expected behavior** — Wayland data device protocol drops clipboard data when the source app exits. This is why `cliphist` exists. If the cliphist daemon isn't running:

```bash
wl-paste --watch cliphist store &
```

If it IS running but copying still breaks, reinstall cliphist:

```bash
sudo pacman -S cliphist
```
