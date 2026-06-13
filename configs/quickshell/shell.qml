//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RENDER_LOOP=threaded

import Quickshell
import Quickshell.Io
import QtQuick
import "services" as QsServices
import "panel"

ShellRoot {
    id: root

    readonly property var audio: QsServices.Audio
    readonly property var power: QsServices.Power
    readonly property var mpris: QsServices.MprisService
    readonly property var notifs: QsServices.NotificationService

    // ── Dynamic tray-offset for panel alignment ──
    property int trayWidth: 0

    OmniPanel {
        id: omniPanel
        trayWidth: root.trayWidth
    }

    // ── Tray width monitors ─────────────────
    // Real-time: daemon listens for DBus tray signals and
    //            writes to /tmp/qs-tray-width instantly.
    // Fallback:  fast file-polling every 200ms catches
    //            any edge cases.
    Process {
        id: trayWatchDaemon
        command: ["sh", "/home/nine/hyprarch/configs/quickshell/scripts/tray-watch.sh"]
        // no stdout collector — runs in background, killed on exit
    }

    Timer {
        id: trayWidthTimer
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            trayWidthProc.running = true
        }
    }

    Process {
        id: trayWidthProc
        command: ["sh", "-c", "cat /tmp/qs-tray-width 2>/dev/null || echo 0"]
        stdout: StdioCollector {
            onStreamFinished: {
                const val = parseInt(text.trim())
                if (!isNaN(val)) root.trayWidth = val
            }
        }
    }

    Component.onCompleted: {
        console.log("CGGX QuickShell loaded")
        // Start tray daemon + get initial width immediately
        trayWatchDaemon.running = true
        trayWidthProc.running = true
    }
}
