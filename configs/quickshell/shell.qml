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

    TimePanel {
        id: timePanel
    }

    // ── Single process for writing state files ──
    Process { id: writeProc }
    Process { id: forceCloseProc }

    // ── Combined state polling (single tick, atomic read) ──
    Timer {
        id: stateTimer
        interval: 200
        running: true
        repeat: true
        property bool volLast: false
        property bool powerLast: false
        property bool calLast: false
        onTriggered: {
            readStateProc.running = true
        }
    }

    Process {
        id: readStateProc
        command: ["sh", "-c", "awk 'NR==1{print} NR==2{print} NR==3{print}' /tmp/qs-volume-state /tmp/qs-power-state /tmp/qs-cal-state 2>/dev/null || printf '0\n0\n0'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("\n")
                const volNow = parts[0] === "1"
                const powerNow = parts[1] === "1"
                const calNow = parts[2] === "1"

                // ── Helper: close others when one opens ──
                function forceClose(exclude) {
                    var cmds = []
                    if (exclude !== "vol") {
                        stateTimer.volLast = false
                        volumePopout.shouldShow = false
                        cmds.push("echo 0 > /tmp/qs-volume-state")
                    }
                    if (exclude !== "power") {
                        stateTimer.powerLast = false
                        powerPanel.shouldShow = false
                        cmds.push("echo 0 > /tmp/qs-power-state")
                    }
                    if (exclude !== "cal") {
                        stateTimer.calLast = false
                        timePanel.shouldShow = false
                        cmds.push("echo 0 > /tmp/qs-cal-state")
                    }
                    if (cmds.length > 0) {
                        forceCloseProc.command = ["sh", "-c", cmds.join("; ")]
                        forceCloseProc.running = true
                    }
                }

                // Volume changed
                if (volNow !== stateTimer.volLast) {
                    stateTimer.volLast = volNow
                    volumePopout.shouldShow = volNow
                    if (volNow) forceClose("vol")
                }
                // Power changed (only if volume didn't change)
                else if (powerNow !== stateTimer.powerLast) {
                    stateTimer.powerLast = powerNow
                    powerPanel.shouldShow = powerNow
                    if (powerNow) forceClose("power")
                }
                // Calendar changed (only if neither above changed)
                else if (calNow !== stateTimer.calLast) {
                    stateTimer.calLast = calNow
                    timePanel.shouldShow = calNow
                    if (calNow) forceClose("cal")
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("CGGX QuickShell loaded")
    }

}
