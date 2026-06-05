//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RENDER_LOOP=threaded

import Quickshell
import Quickshell.Io
import QtQuick
import "services" as QsServices
import "modules"

ShellRoot {
    id: root

    readonly property var audio: QsServices.Audio

    VolumePopout {
        id: volumePopout
    }

    // Watch trigger file from waybar
    Timer {
        id: triggerTimer
        interval: 200
        running: true
        repeat: true
        property bool lastState: false
        onTriggered: {
            checkProc.running = true
        }
    }

    Process {
        id: checkProc
        command: ["cat", "/tmp/qs-volume-state"]
        stdout: StdioCollector {
            onStreamFinished: {
                const newState = text.trim() === "1"
                if (newState !== triggerTimer.lastState) {
                    triggerTimer.lastState = newState
                    volumePopout.shouldShow = newState
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("CGGX QuickShell loaded")
    }
}
