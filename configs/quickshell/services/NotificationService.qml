pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // ── Notification history model ────────
    property ListModel model: ListModel {}
    property int _nextId: 1

    // ── Spy process ───────────────────────
    property bool spyRunning: false

    Process {
        id: spyProc
        command: ["python3", "/home/nine/.local/bin/notif-snoop.py"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(data) {
                try {
                    const parsed = JSON.parse(data)
                    if (parsed && parsed.app && parsed.summary !== undefined) {
                        root.model.insert(0, {
                            nid: root._nextId++,
                            app: parsed.app || "",
                            summary: parsed.summary || "",
                            body: parsed.body || "",
                            ts: parsed.ts || 0
                        })
                        // Cap at 200
                        while (root.model.count > 200) {
                            root.model.remove(200)
                        }
                    }
                } catch (e) {
                    // Ignore malformed lines
                }
            }
        }
        onExited: {
            // Attempt restart after 2s
            root.spyRunning = false
            restartTimer.start()
        }
    }

    Timer {
        id: restartTimer
        interval: 2000
        repeat: false
        onTriggered: {
            if (!root.spyRunning) {
                spyProc.running = true
                root.spyRunning = true
            }
        }
    }

    // ── Actions ───────────────────────────
    function dismiss(nid) {
        for (let i = 0; i < root.model.count; i++) {
            if (root.model.get(i).nid === nid) {
                root.model.remove(i)
                return
            }
        }
    }

    function clearAll() {
        root.model.clear()
    }

    // ── Startup ───────────────────────────
    Component.onCompleted: {
        spyProc.running = true
        root.spyRunning = true
    }
}
