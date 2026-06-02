#!/usr/bin/env python3
"""CGGX Power Menu — GTK4 popup.

Shutdown, Reboot, Lock, Log Out, Suspend.
No input grab, click outside dismisses on Wayland.
"""

import sys
import os
import gi
gi.require_version('Gtk', '4.0')
gi.require_version('GLib', '2.0')
from gi.repository import Gtk, GLib, Gdk, Gio

# ── Entries ─────────────────────────────────────────────────────
ENTRIES = [
    ("\u23fb  Shutdown",  "systemctl poweroff"),
    ("\u28b4  Reboot",    "systemctl reboot"),
    ("\uf023  Lock",      "hyprlock"),
    ("\ueb5c  Log Out",   "hyprctl dispatch exit"),
    ("\uf0e7  Suspend",   "systemctl suspend"),
]

# ── Waybar-matching CSS ─────────────────────────────────────────
CSS = """
window {
  background-color: transparent;
}
.popup {
  background-color: #1a1a20;
}
.entry {
  padding: 7px 14px;
  font-family: "JetBrainsMonoNL Nerd Font Mono";
  font-size: 13px;
  font-weight: 500;
  background-color: transparent;
  border-bottom: 1px solid #2a2a35;
}
.entry:last-child {
  border-bottom: none;
}
.entry:hover {
  background-color: rgba(255, 255, 255, 0.06);
}
.entry:active {
  background-color: rgba(255, 45, 85, 0.15);
}
"""


class PowerMenuApp(Gtk.Application):
    def __init__(self):
        super().__init__(
            application_id='com.cggx.powermenu',
            flags=Gio.ApplicationFlags.DEFAULT_FLAGS,
        )
        self.window = None

    def do_activate(self):
        if self.window is not None:
            self.window.destroy()
            return

        self.window = Gtk.ApplicationWindow(application=self)
        self.window.set_title("Power Menu")
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

        for label_text, command in ENTRIES:
            box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
            box.set_css_classes(["entry"])

            label = Gtk.Label(label=label_text)
            label.set_halign(Gtk.Align.START)
            label.set_hexpand(True)

            gesture = Gtk.GestureClick()
            gesture.connect("pressed", self.on_entry_clicked, command)
            box.add_controller(gesture)

            box.append(label)
            self.popup_box.append(box)

        self.window.set_child(self.popup_box)

        # Close on focus loss
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
        target_x = geo.width - 220 - 60
        target_y = 48
        self.window.move(target_x, target_y)
        return False

    def on_entry_clicked(self, gesture, n_press, x, y, command):
        self.shutdown()
        os.system(f"nohup {command} &>/dev/null &")

    def on_focus_leave(self, controller):
        GLib.timeout_add(150, self.shutdown)

    def on_key_pressed(self, controller, keyval, keycode, state):
        if keyval in (Gdk.KEY_Escape,):
            self.shutdown()
            return True
        return False


if __name__ == "__main__":
    pid_file = "/tmp/cggx-power-menu.pid"
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

    app = PowerMenuApp()
    app.run(sys.argv)

    if os.path.exists(pid_file):
        os.unlink(pid_file)
