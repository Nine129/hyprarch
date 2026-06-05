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
    readonly property var power: QsServices.Power

    VolumePopout {
        id: volumePopout
    }

    PowerPanel {
        id: powerPanel
    }

    // ── Single process for writing state files ──
    Process { id: writeProc }

    // ── Combined state polling (single tick, atomic read) ──
    Timer {
        id: stateTimer
        interval: 200
        running: true
        repeat: true
        property bool volLast: false
        property bool powerLast: false
        onTriggered: {
            readStateProc.running = true
        }
    }

    Process {
        id: readStateProc
        command: ["sh", "-c", "awk 'NR==1{print} NR==2{print}' /tmp/qs-volume-state /tmp/qs-power-state 2>/dev/null || printf '0\n0'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("\n")
                const volNow = parts[0] === "1"
                const powerNow = parts[1] === "1"

                // Mutual exclusion: only one can be open
                if (volNow && powerNow) {
                    // Both toggled — honor the one that just changed
                    if (volNow !== stateTimer.volLast && powerNow === stateTimer.powerLast) {
                        // Volume just changed, power was already on → open volume, close power
                        stateTimer.volLast = volNow
                        stateTimer.powerLast = false
                        volumePopout.shouldShow = true
                        powerPanel.shouldShow = false
                        writeProc.command = ["sh", "-c", "echo 0 > /tmp/qs-power-state"]
                        writeProc.running = true
                    } else if (powerNow !== stateTimer.powerLast && volNow === stateTimer.volLast) {
                        // Power just changed, volume was already on → open power, close volume
                        stateTimer.powerLast = powerNow
                        stateTimer.volLast = false
                        powerPanel.shouldShow = true
                        volumePopout.shouldShow = false
                        writeProc.command = ["sh", "-c", "echo 0 > /tmp/qs-volume-state"]
                        writeProc.running = true
                    } else {
                        // Both changed simultaneously (unlikely) — default to volume
                        stateTimer.volLast = true
                        stateTimer.powerLast = false
                        volumePopout.shouldShow = true
                        powerPanel.shouldShow = false
                        writeProc.command = ["sh", "-c", "echo 0 > /tmp/qs-power-state"]
                        writeProc.running = true
                    }
                } else {
                    // Normal: at most one is requesting to open
                    if (volNow !== stateTimer.volLast) {
                        stateTimer.volLast = volNow
                        volumePopout.shouldShow = volNow
                        if (volNow) {
                            stateTimer.powerLast = false
                            powerPanel.shouldShow = false
                            writeProc.command = ["sh", "-c", "echo 0 > /tmp/qs-power-state"]
                            writeProc.running = true
                        }
                    }
                    if (powerNow !== stateTimer.powerLast) {
                        stateTimer.powerLast = powerNow
                        powerPanel.shouldShow = powerNow
                        if (powerNow) {
                            stateTimer.volLast = false
                            volumePopout.shouldShow = false
                            writeProc.command = ["sh", "-c", "echo 0 > /tmp/qs-volume-state"]
                            writeProc.running = true
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("CGGX QuickShell loaded")
    }
}
