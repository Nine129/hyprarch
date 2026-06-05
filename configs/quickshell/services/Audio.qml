pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // ── Output (sink) ───────────────────────
    property bool ready: false
    property bool muted: false
    property real volume: 0.5
    readonly property int percentage: Math.round(volume * 100)

    // ── Input (source) ──────────────────────
    property bool sourceReady: false
    property bool sourceMuted: false
    property real sourceVolume: 0.5
    readonly property int sourcePercentage: Math.round(sourceVolume * 100)

    // ── Default sink info ───────────────────
    property string defaultSinkName: "Built-in Audio"
    property string defaultSinkAlsaName: ""
    property string defaultSinkDescription: ""

    // ── Available sinks ─────────────────────
    property var availableSinks: []
    property int activeSinkIndex: 0

    // ── Sink inputs (app streams) ───────────
    property var sinkInputs: []

    // ── Poll output volume ──────────────────
    Timer {
        interval: 250
        running: true
        repeat: true
        onTriggered: {
            if (!getSink.running) getSink.running = true
            if (!getSource.running) getSource.running = true
        }
    }

    Process {
        id: getSink
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                const s = text.trim()
                const m = s.match(/Volume:\s*([0-9.]+)/)
                if (m) {
                    const v = parseFloat(m[1])
                    if (!isNaN(v)) {
                        root.ready = true
                        root.volume = Math.max(0, Math.min(1.5, v))
                    }
                }
                root.muted = /\[MUTED\]/.test(s)
            }
        }
    }

    Process {
        id: getSource
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]
        stdout: StdioCollector {
            onStreamFinished: {
                const s = text.trim()
                const m = s.match(/Volume:\s*([0-9.]+)/)
                if (m) {
                    const v = parseFloat(m[1])
                    if (!isNaN(v)) {
                        root.sourceReady = true
                        root.sourceVolume = Math.max(0, Math.min(1.5, v))
                    }
                }
                root.sourceMuted = /\[MUTED\]/.test(s)
            }
        }
    }

    // ── Poll default sink name ──────────────
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            if (!getDefaultSinkName.running) getDefaultSinkName.running = true
        }
    }

    Process {
        id: getDefaultSinkName
        command: ["wpctl", "inspect", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n")
                for (let i = 0; i < lines.length; i++) {
                    const line = lines[i].trim()
                    if (line.startsWith("alsa.name")) {
                        const m = line.match(/alsa\.name\s*=\s*"(.+?)"/)
                        if (m) root.defaultSinkAlsaName = m[1]
                    }
                    if (line.startsWith("node.description")) {
                        const m = line.match(/node\.description\s*=\s*"(.+?)"/)
                        if (m) root.defaultSinkDescription = m[1]
                    }
                }
                // Build display name: prefer alsa.name, fall back to description
                if (root.defaultSinkAlsaName) {
                    root.defaultSinkName = root.defaultSinkAlsaName
                } else if (root.defaultSinkDescription) {
                    root.defaultSinkName = root.defaultSinkDescription
                }
            }
        }
    }

    // ── Poll available sinks ────────────────
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            if (!listSinksProc.running) listSinksProc.running = true
        }
    }

    Process {
        id: listSinksProc
        command: ["wpctl", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                const sinks = []
                let inSinks = false
                const lines = text.split("\n")
                for (let i = 0; i < lines.length; i++) {
                    const line = lines[i]
                    if (/^\s*├─ Sinks:/.test(line) || /^\s*\*  Sinks:/.test(line)) {
                        inSinks = true
                        continue
                    }
                    if (inSinks) {
                        if (/^\s*[├└]─/.test(line)) { inSinks = false; continue }
                        // Parse: "│  *   57. Built-in Audio Analog Stereo        [vol: 0.40]"
                        const trimmed = line.replace(/[│║]/g, "").trim()
                        const starIdx = trimmed.indexOf("*")
                        const isDef = starIdx >= 0
                        const clean = isDef ? trimmed.replace("*", "").trim() : trimmed
                        const dotIdx = clean.indexOf(".")
                        const bracketIdx = clean.indexOf("[vol:")
                        if (dotIdx > 0 && bracketIdx > dotIdx) {
                            const id = parseInt(clean.substring(0, dotIdx).trim())
                            let name = clean.substring(dotIdx + 1, bracketIdx).trim()
                            const volStr = clean.substring(bracketIdx + 5, clean.indexOf("]", bracketIdx)).trim()
                            if (!isNaN(id)) {
                                if (name === "Built-in Audio Analog Stereo") name = root.defaultSinkAlsaName || "Built-in Audio"
                                else if (name.includes("Bluetooth")) name = name.replace("BluetoothA2DP", "").trim() || "Bluetooth"
                                sinks.push({ id: id, name: name, isDefault: isDef })
                            }
                        }
                    }
                }
                if (sinks.length > 0) {
                    root.availableSinks = sinks
                    for (let i = 0; i < sinks.length; i++) {
                        if (sinks[i].isDefault) { root.activeSinkIndex = i; break }
                    }
                }
            }
        }
    }

    // ── Poll sink inputs (app streams) ──────
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (!listSinkInputsProc.running) listSinkInputsProc.running = true
        }
    }

    Process {
        id: listSinkInputsProc
        command: ["pactl", "list", "sink-inputs"]
        stdout: StdioCollector {
            onStreamFinished: {
                var inputs = []
                var idx = -1
                var curApp = ""
                var curDesc = ""
                var curVol = 100
                var curMute = false
                var hasEntry = false
                var lines = text.split("\n")
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i]
                    if (line.indexOf("Sink Input #") === 0) {
                        if (hasEntry && curApp.length > 0) {
                            inputs.push({ inputIdx: idx, name: curApp, description: curDesc.length > 0 ? curDesc : curApp, volume: curVol, muted: curMute })
                        }
                        var hashMatch = line.match(/Sink Input #(\d+)/)
                        idx = hashMatch ? parseInt(hashMatch[1]) : -1
                        curApp = ""; curDesc = ""; curVol = 100; curMute = false
                        hasEntry = true
                    }
                    if (line.indexOf("application.name") >= 0) {
                        var m = line.match(/"(.+?)"/)
                        if (m) curApp = m[1]
                    }
                    if (line.indexOf("device.description") >= 0) {
                        var d = line.match(/"(.+?)"/)
                        if (d) curDesc = d[1]
                    }
                    if (line.indexOf("front-left") >= 0) {
                        var v = line.match(/\/\s*(\d+)%/)
                        if (v) curVol = parseInt(v[1])
                    }
                    if (line.indexOf("Mute:") === 0) {
                        curMute = line.indexOf("yes") >= 0
                    }
                }
                if (hasEntry && curApp.length > 0) {
                    inputs.push({ inputIdx: idx, name: curApp, description: curDesc.length > 0 ? curDesc : curApp, volume: curVol, muted: curMute })
                }
                root.sinkInputs = inputs
            }
        }
    }

    // ── Output controls ─────────────────────
    function setVolume(v) {
        setMute(false)
        setVolProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", Math.max(0, Math.min(1.5, v)).toFixed(3)]
        setVolProc.running = true
    }

    function increaseVolume() { setVolume(volume + 0.05) }
    function decreaseVolume() { setVolume(volume - 0.05) }

    function toggleMute() {
        setMuteProc.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
        setMuteProc.running = true
    }

    function setMute(m) {
        setMuteProc.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", m ? "1" : "0"]
        setMuteProc.running = true
    }

    // ── Device switching ────────────────────
    function switchSink(sinkId) {
        switchSinkProc.command = ["wpctl", "set-default", String(sinkId)]
        switchSinkProc.running = true
    }

    // ── Stream volume control ───────────────
    function setStreamVolume(sinkInputIdx, vol) {
        var v = Math.max(0, Math.min(1.53, vol))
        var pctStr = String(Math.round(v * 100)) + "%"
        setStreamVolProc.command = ["pactl", "set-sink-input-volume", String(sinkInputIdx), pctStr]
        setStreamVolProc.running = true
    }

    // ── Input controls ──────────────────────
    function setSourceVolume(v) {
        setSourceMute(false)
        setSourceVolProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@", Math.max(0, Math.min(1.5, v)).toFixed(3)]
        setSourceVolProc.running = true
    }

    function toggleSourceMute() {
        setSourceMuteProc.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]
        setSourceMuteProc.running = true
    }

    function setSourceMute(m) {
        setSourceMuteProc.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", m ? "1" : "0"]
        setSourceMuteProc.running = true
    }

    // ── Fire-and-forget processes ───────────
    Process { id: setVolProc }
    Process { id: setMuteProc }
    Process { id: setSourceVolProc }
    Process { id: setSourceMuteProc }
    Process { id: switchSinkProc }
    Process { id: setStreamVolProc }
}
