#!/usr/bin/env python3
"""CGGX Power Profile Switcher — GTK4 popup.

Minimal dropdown below the waybar battery module.
No input grab — click outside closes via Wayland focus events.
Click battery again toggles closed. swaync confirms the switch.
"""

import sys
import os
import subprocess
import gi
gi.require_version('Gtk', '4.0')
gi.require_version('GLib', '2.0')
from gi.repository import Gtk, GLib, Gdk, Gio

# ── Config ──────────────────────────────────────────────────────
PROFILE_FILE = "/sys/firmware/acpi/platform_profile"
PROFILES = ["low-power", "balanced", "performance"]
COLORS = {
    "low-power":   "#00e5ff",
    "balanced":    "#c8ff00",
    "performance": "#ff6b00",
}

# ── CSS — clean tab-style, no icons ─────────────────────────────
CSS = """
window {
  background-color: transparent;
  border-radius: 0;
}
.popup {
  background-color: #1a1a20;
}
.entry {
  padding: 8px 14px 8px 10px;
  font-family: "MonaspiceNe Nerd Font Mono";
  font-size: 13px;
  font-weight: 500;
  background-color: transparent;
  border-left: 4px solid transparent;
}
.entry:hover {
  background-color: rgba(255, 255, 255, 0.06);
}
.entry:active {
  background-color: rgba(255, 255, 255, 0.10);
}
"""


def read_current_profile():
    try:
        with open(PROFILE_FILE) as f:
            return f.read().strip()
    except (FileNotFoundError, PermissionError):
        return "balanced"


def write_profile(profile):
    cmd = f'echo "{profile}" | sudo tee {PROFILE_FILE} > /dev/null'
    os.system(cmd)


def get_monitor_width():
    """Get the primary monitor width via hyprctl."""
    try:
        result = subprocess.run(
            ["hyprctl", "monitors"],
            capture_output=True, text=True, timeout=2,
        )
        for line in result.stdout.splitlines():
            # Line looks like: "\t1920x1080@60.00000 at 0x0"
            if " at 0x0" in line and "x" in line:
                parts = line.strip().split("x")
                return int(parts[0])
    except Exception:
        pass
    return 1920


def send_notification(summary, body):
    os.system(
        f'notify-send -u low "{summary}" "{body}" -a "Power Profile"'
    )


class PowerProfileApp(Gtk.Application):
    def __init__(self):
        super().__init__(
            application_id='com.cggx.powerprofile',
            flags=Gio.ApplicationFlags.DEFAULT_FLAGS,
        )
        self.current_profile = read_current_profile()
        self.window = None

    def do_activate(self):
        if self.window is not None:
            self.window.destroy()
            return

        self.window = Gtk.ApplicationWindow(application=self)
        self.window.set_title("Power Profile")
        self.window.set_decorated(False)
        self.window.set_resizable(False)
        self.window.set_default_size(220, 1)
        self.window.set_hide_on_close(True)
        self.window.set_modal(False)

        # Load CSS
        provider = Gtk.CssProvider()
        provider.load_from_string(CSS)
        Gtk.StyleContext.add_provider_for_display(
            self.window.get_display(),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
        )

        GLib.timeout_add(50, self._position_window)

        self.popup_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.popup_box.set_css_classes(["popup"])

        for profile in PROFILES:
            is_active = profile == self.current_profile
            color = COLORS[profile]

            box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
            box.set_css_classes(["entry"])

            # Set colored left border for active profile
            border_color = color if is_active else "transparent"
            box_style = Gtk.CssProvider()
            box_style.load_from_string(f".entry {{ border-left: 4px solid {border_color}; }}")
            box.get_style_context().add_provider(
                box_style, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION + 1
            )

            label = Gtk.Label()
            label.set_markup(f'<span foreground="{color}">{profile}</span>')
            label.set_halign(Gtk.Align.START)
            label.set_hexpand(True)
            box.append(label)

            gesture = Gtk.GestureClick()
            gesture.connect("pressed", self.on_entry_clicked, profile)
            box.add_controller(gesture)

            self.popup_box.append(box)

        self.window.set_child(self.popup_box)

        # Close on focus loss (click outside)
        focus_controller = Gtk.EventControllerFocus()
        focus_controller.connect("leave", self.on_focus_leave)
        self.window.add_controller(focus_controller)

        # Escape to dismiss
        key_controller = Gtk.EventControllerKey()
        key_controller.connect("key-pressed", self.on_key_pressed)
        self.window.add_controller(key_controller)

        self.window.present()

    def _position_window(self):
        display = Gdk.Display.get_default()
        if not display:
            return False
        surface = self.window.get_surface()
        if not surface:
            return False
        monitor = display.get_monitor_at_surface(surface)
        if not monitor:
            return False
        geo = monitor.get_geometry()
        # Position right edge of popup ~60px from right edge of screen
        target_x = geo.width - 220 - 60
        target_y = 50  # below waybar
        self.window.move(target_x, target_y)
        return False  # one-shot

    def on_entry_clicked(self, gesture, n_press, x, y, profile):
        if profile != self.current_profile:
            write_profile(profile)
            color = COLORS[profile]
            send_notification(
                "Power Profile",
                f"Switched to <span foreground=\"{color}\">{profile}</span>",
            )
        self.shutdown()

    def on_focus_leave(self, controller):
        GLib.timeout_add(100, self.shutdown)

    def on_key_pressed(self, controller, keyval, keycode, state):
        if keyval in (Gdk.KEY_Escape,):
            self.shutdown()
            return True
        return False


if __name__ == "__main__":
    pid_file = "/tmp/cggx-power-profile.pid"
    if os.path.exists(pid_file):
        try:
            with open(pid_file) as f:
                old_pid = int(f.read().strip())
            os.kill(old_pid, 0)
            os.kill(old_pid, 15)
            os.unlink(pid_file)
            sys.exit(0)
        except (ProcessLookupError, FileNotFoundError, ValueError):
            os.unlink(pid_file)

    with open(pid_file, "w") as f:
        f.write(str(os.getpid()))

    app = PowerProfileApp()
    app.run(sys.argv)

    if os.path.exists(pid_file):
        os.unlink(pid_file)
