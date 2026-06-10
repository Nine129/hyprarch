import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../services" as QsServices

PanelWindow {
    id: panel

    readonly property var notifService: QsServices.NotificationService
    readonly property var mpris: QsServices.MprisService
    property int trayWidth: 0

    screen: Quickshell.screens[0]
    anchors { top: true; bottom: true; right: true }
    margins { top: 0; right: 13 }
    implicitWidth: _effectiveVisible ? (374 + trayWidth) : 0
    implicitHeight: screen.height
    color: "transparent"
    visible: true
    exclusiveZone: 0

    // ── Open state machine ──────────────
    property bool open: false
    property bool _effectiveVisible: false

    onOpenChanged: {
        if (open) {
            _effectiveVisible = true
            // Close volume/power/time popouts when notif center opens
            closeOthersProc.running = true
        } else {
            hideTimer.start()
        }
    }

    Process {
        id: closeOthersProc
        command: ["sh", "-c", "echo 0 > /tmp/qs-volume-state; echo 0 > /tmp/qs-power-state; echo 0 > /tmp/qs-cal-state"]
    }

    Timer {
        id: hideTimer
        interval: 250
        repeat: false
        onTriggered: {
            if (!panel.open) _effectiveVisible = false
        }
    }

    // ── Palette ──────────────────────────
    readonly property color bg:     "#151518"
    readonly property color orange: "#ff6b00"
    readonly property color cyan:   "#00e5ff"
    readonly property color lime:   "#c8ff00"
    readonly property color silver: "#e8e8f0"
    readonly property color muted:  "#6a6a80"
    readonly property color dim:    "#3a3a48"
    readonly property color border: "#2a2a35"

    // ── Close helpers ───────────────────
    function closePanel() {
        panel.open = false
        closeStateProc.running = true
    }

    Process {
        id: closeStateProc
        command: ["sh", "-c", "rm -f /tmp/qs-notif-state"]
    }

    // ── Self-contained state poll ─────────
    Timer {
        id: stateTimer
        interval: 50
        running: true
        repeat: true
        onTriggered: {
            if (!pollProc.running) pollProc.running = true
        }
    }

    Process {
        id: pollProc
        command: ["sh", "-c", "test -f /tmp/qs-notif-state && echo 1 || echo 0"]
        stdout: StdioCollector {
            onStreamFinished: {
                const now = text.trim() === "1"
                if (now !== panel.open) {
                    panel.open = now
                }
            }
        }
    }

    // ── Relative time formatter ────────
    function formatRelativeTime(tsMs) {
        if (!tsMs || tsMs <= 0) return ""
        const now = Date.now()
        const diff = now - tsMs
        const secs = Math.floor(diff / 1000)
        const mins = Math.floor(secs / 60)
        const hours = Math.floor(mins / 60)
        if (secs < 60) return "just now"
        if (mins < 60) return mins + "m ago"
        if (hours < 24) return hours + "h ago"
        const d = new Date(tsMs)
        const y = new Date()
        y.setDate(y.getDate() - 1)
        if (d.getDate() === y.getDate() && d.getMonth() === y.getMonth() && d.getFullYear() === y.getFullYear()) {
            return "Yesterday " + pad2(d.getHours()) + ":" + pad2(d.getMinutes())
        }
        const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
        return months[d.getMonth()] + " " + d.getDate() + " " + pad2(d.getHours()) + ":" + pad2(d.getMinutes())
    }

    function pad2(n) { return n < 10 ? "0" + n : String(n) }

    function clearAll() { notifService.clearAll() }

    // ═══════════════════════════════════════
    //  Content wrapper — 370px right side (Item so transform works)
    // ═══════════════════════════════════════
    Item {
        id: contentPane
        anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
        implicitWidth: panel.implicitWidth

        transform: Translate {
            id: slide
            y: panel.open ? 0 : -panel.height
            Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        // Background
        Rectangle {
            anchors.fill: parent
            color: panel.bg
        }

        // ── Header ──────────────────────
        RowLayout {
            id: headerRow
            anchors { left: parent.left; right: parent.right; top: parent.top }
            anchors.margins: 20
            anchors.topMargin: 20
            spacing: 10

            Text {
                text: "inbox"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 22
                font.bold: true
                color: panel.cyan
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "clear"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                font.bold: true
                color: clearMouse.containsMouse ? "#d4ff40" : panel.lime
                MouseArea {
                    id: clearMouse
                    anchors.fill: parent; anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: panel.clearAll()
                }
            }
        }

        // ── Divider ────────────────────
        Rectangle {
            id: headerDivider
            anchors { left: parent.left; right: parent.right; top: headerRow.bottom }
            anchors.margins: 20
            anchors.topMargin: 14
            height: 1
            color: panel.border
        }

        // ── Now Playing ─────────────────
        NowPlaying {
            id: nowPlaying
            anchors { left: parent.left; right: parent.right; top: headerDivider.bottom }
            anchors.topMargin: 12
        }

        // ── Divider ────────────────────
        Rectangle {
            id: npDivider
            anchors { left: parent.left; right: parent.right; top: nowPlaying.bottom }
            anchors.margins: 20
            anchors.topMargin: 12
            height: 1
            color: panel.border
        }

        // ── Notification list ──────────
        ListView {
            id: notifList
            anchors { left: parent.left; right: parent.right; top: npDivider.bottom; bottom: parent.bottom }
            anchors.topMargin: 8
            anchors.bottomMargin: 20
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            clip: true
            spacing: 0
            model: notifService.model

            delegate: NotificationItem {
                width: notifList.width
                appName: model.app || ""
                summary: model.summary || ""
                body: model.body || ""
                timeText: panel.formatRelativeTime(model.ts || 0)
                notifId: model.nid || 0
                onDismissRequested: function(nid) { notifService.dismiss(nid) }
            }
        }
    }
}
