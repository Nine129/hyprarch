pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower as QsUPower
import QtQuick

Singleton {
    id: root

    // ── UPower (reactive via DBus) ──────────
    readonly property var upower: QsUPower.UPower
    readonly property var device: upower.displayDevice

    readonly property double batteryPercent:  isNaN(device.percentage) ? 0 : device.percentage * (device.percentage < 1 ? 100 : 1)
    readonly property double powerDraw:       isNaN(device.changeRate) ? 0 : Math.abs(device.changeRate)
    readonly property bool   onBattery:       upower.onBattery
    readonly property var    state:           device.state
    readonly property string stateLabel:
        device.state === QsUPower.UPowerDeviceState.Charging || device.state === QsUPower.UPowerDeviceState.PendingCharge ? "CHARGING" :
        device.state === QsUPower.UPowerDeviceState.Discharging || device.state === QsUPower.UPowerDeviceState.PendingDischarge ? "DISCHARGING" :
        device.state === QsUPower.UPowerDeviceState.FullyCharged ? "FULLY CHARGED" :
        "POWER"

    // ── Sysfs (poll every 5s, also on startup) ──
    property string currentProfile: "balanced"
    property int    chargeThreshold: 80
    property int    cycleCount: 0
    property double healthPercent: 0

    // ── Profile definitions ─────────────────
    readonly property var profileDefs: [
        { id: "low-power",    label: "Saver",       icon: "󰌪", color: "#00e5ff" },
        { id: "balanced",     label: "Balanced",     icon: "",  color: "#c8ff00" },
        { id: "performance",  label: "Performance",  icon: "",  color: "#ff6b00" }
    ]

    // ── Poll sysfs every 5s ─────────────────
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: runSysfsPoll()
    }

    Component.onCompleted: runSysfsPoll()

    function runSysfsPoll() {
        pollProfile.running = true
        pollThreshold.running = true
        pollCycles.running = true
        pollHealth.running = true
    }

    Process {
        id: pollProfile
        command: ["cat", "/sys/firmware/acpi/platform_profile"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim()
                if (p.length > 0) root.currentProfile = p
            }
        }
    }

    Process {
        id: pollThreshold
        command: ["cat", "/sys/class/power_supply/BAT0/charge_control_end_threshold"]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = parseInt(text.trim())
                if (!isNaN(v)) root.chargeThreshold = v
            }
        }
    }

    Process {
        id: pollCycles
        command: ["cat", "/sys/class/power_supply/BAT0/cycle_count"]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = parseInt(text.trim())
                if (!isNaN(v)) root.cycleCount = v
            }
        }
    }

    // Health = energy_full / energy_full_design × 100
    Process {
        id: pollHealth
        command: ["sh", "-c",
            "ef=$(cat /sys/class/power_supply/BAT0/energy_full) && " +
            "ed=$(cat /sys/class/power_supply/BAT0/energy_full_design) && " +
            "awk 'BEGIN{printf \"%.1f\", '${ef}'/'${ed}'*100}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = parseFloat(text.trim())
                if (!isNaN(v)) root.healthPercent = v
            }
        }
    }

    // ── Actions ─────────────────────────────
    function setProfile(profile) {
        if (profile === root.currentProfile) return
        setProfileProc.command = ["sh", "/home/nine/hyprarch/configs/quickshell/scripts/power-helper.sh", "profile", profile]
        setProfileProc.running = true
        root.currentProfile = profile
    }

    function setChargeLimit(limit) {
        setChargeProc.command = ["sh", "/home/nine/hyprarch/configs/quickshell/scripts/power-helper.sh", "charge-limit", String(limit)]
        setChargeProc.running = true
        root.chargeThreshold = limit
    }

    // ── Fire-and-forget processes ───────────
    Process { id: setProfileProc }
    Process { id: setChargeProc }
}
