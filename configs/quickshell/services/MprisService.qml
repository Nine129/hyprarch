pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick

Singleton {
    id: root

    // ── Player ────────────────────────────
    property var player: null
    readonly property bool hasPlayer: player !== null
    readonly property int playerCount: Mpris.players.values.length

    // ── Track info ────────────────────────
    property string trackTitle: ""
    property string trackArtist: ""
    property string trackAlbum: ""
    property real position: 0
    property real length: 0
    property bool isPlaying: false

    // ── Album art ─────────────────────────
    property string artUrl: ""
    readonly property string artCachePath: "/home/nine/.cache/hyprarch/nowplaying.png"

    // ── Internal ──────────────────────────
    property int _playerCount: 0
    property string _prevTitle: ""
    property string _prevArtist: ""

    // ── Priority-chain player discovery ───
    function findPlayer() {
        const list = Mpris.players.values  // QObjectList — .count/.get() don't exist on UntypedObjectModel
        if (list.length === 0) return null
        // 1. dbusName — most precise
        for (let i = 0; i < list.length; i++) {
            const p = list[i]
            if (p.dbusName && p.dbusName.toLowerCase().includes("mpd"))
                return p
        }
        // 2. identity — human-readable fallback
        for (let j = 0; j < list.length; j++) {
            const p = list[j]
            if (p.identity && p.identity.toLowerCase().includes("mpd"))
                return p
        }
        // 3. any playing player
        for (let k = 0; k < list.length; k++) {
            const p = list[k]
            if (p.playbackState === MprisPlaybackState.Playing)
                return p
        }
        // 4. first available
        return list[0]
    }

    function refreshPlayer() {
        const p = findPlayer()
        if (p !== root.player) {
            root.player = p
            updateTrackInfo()
            if (p) scheduleArtFetch()
        }
    }

    function updateTrackInfo() {
        if (!root.player) {
            root.trackTitle = ""
            root.trackArtist = ""
            root.trackAlbum = ""
            root.isPlaying = false
            root.position = 0
            root.length = 0
            return
        }
        root.trackTitle = root.player.trackTitle || ""
        root.trackArtist = root.player.trackArtist || ""
        root.trackAlbum = root.player.trackAlbum || ""
        root.isPlaying = root.player.isPlaying || false
        root.position = root.player.position || 0
        root.length = root.player.length || 0
    }

    // ── Discovery poll ────────────────────
    Timer {
        id: discoveryTimer
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            const c = Mpris.players.values.length
            if (c !== root._playerCount) {
                root._playerCount = c
                refreshPlayer()
            }
        }
    }

    // ── Track change poll ─────────────────
    Timer {
        id: trackPollTimer
        interval: 500
        running: root.hasPlayer
        repeat: true
        onTriggered: {
            if (!root.player) return
            const t = root.player.trackTitle || ""
            const a = root.player.trackArtist || ""
            if (t !== root._prevTitle || a !== root._prevArtist) {
                root._prevTitle = t
                root._prevArtist = a
                updateTrackInfo()
                scheduleArtFetch()
            }
            // Keep position fresh even on same track
            if (root.player.positionSupported) {
                root.position = root.player.position || 0
                root.isPlaying = root.player.isPlaying || false
            }
        }
    }

    // ── Art fetch (debounced) ─────────────
    Timer {
        id: artDebounce
        interval: 50
        repeat: false
        onTriggered: {
            if (!artFetchProc.running) artFetchProc.running = true
        }
    }

    function scheduleArtFetch() {
        artDebounce.restart()
    }

    Process {
        id: artFetchProc
        command: [
            "sh", "-c",
            "mkdir -p /home/nine/.cache/hyprarch && " +
            "rmpc albumart --output /home/nine/.cache/hyprarch/nowplaying.png 2>/dev/null && " +
            "echo ok || echo fail"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim() === "ok") {
                    root.artUrl = "file:///home/nine/.cache/hyprarch/nowplaying.png?" + Date.now()
                }
            }
        }
    }

    // ── Controls ──────────────────────────
    function togglePlaying() { if (root.player) root.player.togglePlaying() }
    function next()         { if (root.player && root.player.canGoNext)     root.player.next() }
    function previous()     { if (root.player && root.player.canGoPrevious) root.player.previous() }

    // ── Startup ───────────────────────────
    Component.onCompleted: {
        root._playerCount = Mpris.players.values.length
        refreshPlayer()
    }
}
