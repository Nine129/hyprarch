import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../services" as QsServices

// ═══════════════════════════════════════════════════════════════
// Omni Control Panel — unified PanelWindow
// ═══════════════════════════════════════════════════════════════
PanelWindow {
    id: panel

    readonly property var audio: QsServices.Audio
    readonly property var power: QsServices.Power
    readonly property var mpris: QsServices.MprisService
    readonly property var notifs: QsServices.NotificationService

    readonly property color surface: "#151518"
    readonly property color red:     "#F9364B"
    readonly property color silver:  "#e8e8f0"
    readonly property color border:  "#2a2a35"
    readonly property color orange:  "#ff6b00"
    readonly property color cyan:    "#00e5ff"
    readonly property color lime:    "#c8ff00"

    screen: Quickshell.screens[0]
    anchors { top: true; right: true; bottom: true }
    margins { top: 2; right: 11; bottom: 100 }
    implicitWidth: panel._effectiveVisible ? 440 : 0
    color: "transparent"
    visible: true
    exclusiveZone: 0

    // ── Open state ────────────────────────
    property bool open: false
    property bool _effectiveVisible: false
    property real slideX: 500

    onOpenChanged: {
        if (open) {
            _effectiveVisible = true
            slideX = 500
            if (flickable) flickable.contentY = 0
            slideInTimer.start()
        } else {
            slideX = 500
            hideTimer.start()
        }
    }

    Timer {
        id: slideInTimer
        interval: 16
        repeat: false
        onTriggered: slideX = 0
    }

    Timer {
        id: hideTimer
        interval: 260
        repeat: false
        onTriggered: {
            if (!panel.open) panel._effectiveVisible = false
        }
    }

    // ── State file poll ───────────────────
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
        command: ["sh", "-c", "test -f /tmp/qs-control-panel && echo 1 || echo 0"]
        stdout: StdioCollector {
            onStreamFinished: {
                const now = text.trim() === "1"
                if (now !== panel.open) panel.open = now
            }
        }
    }

    // ── Close helper ──────────────────────
    function closePanel() {
        panel.open = false
        closeProc.running = true
    }

    Process {
        id: closeProc
        command: ["sh", "-c", "rm -f /tmp/qs-control-panel"]
    }

    Process {
        id: wlogoutProc
        command: ["sh", "-c", "wlogout --css ~/.config/wlogout/style.css --buttons-per-row 5 -T 410 -B 410 -L 200 -R 200"]
    }

    // ── Visual tree ───────────────────────
    Item {
        id: slideWrapper
        anchors.fill: parent
        visible: panel._effectiveVisible

        transform: Translate {
            id: slide
            x: slideX
            Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        }


        // Background surface
        Rectangle {
            anchors.fill: parent
            color: panel.surface
        }

        // Scrollable content
        Flickable {
            id: flickable
            anchors.fill: parent
            anchors.margins: 2          // keep inside gradient borders
            contentWidth: width
            contentHeight: contentCol.implicitHeight + 40
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: contentCol
                anchors { left: parent.left; right: parent.right; top: parent.top }
                anchors.margins: 12
                anchors.bottomMargin: 40
                spacing: 14

                // ── Header ──
                RowLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 8

                    Text {
                        text: "CONTROL"
                        font.family: "MonaspiceNe Nerd Font"
                        font.pixelSize: 22
                        font.bold: true
                        font.letterSpacing: 3
                        color: panel.red
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        color: Qt.rgba(1, 1, 1, 0.04)
                        border.color: panel.border
                        border.width: 1
                        scale: closeMouse.pressed ? 0.92 : 1.0

                        Behavior on scale {
                            NumberAnimation { duration: 100 }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "\u23FB" // power symbol
                            font.family: "MonaspiceNe Nerd Font"
                            font.pixelSize: 16
                            color: closeMouse.containsMouse ? panel.red : panel.silver
                        }

                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: wlogoutProc.running = true
                        }
                    }
                }

                // ── Sections ──
                NowPlayingSection { Layout.fillWidth: true }
                AudioSection { Layout.fillWidth: true }
                BatterySection { Layout.fillWidth: true }
                CalendarSection { Layout.fillWidth: true }

                // ── Notifications header ──
                Text {
                    Layout.fillWidth: true
                    text: "Notifications"
                    font.family: "MonaspiceNe Nerd Font"
                    font.pixelSize: 14
                    font.bold: true
                    font.letterSpacing: 2.5
                    color: "#F9364B"
                    textFormat: Text.PlainText
                    Layout.topMargin: 4
                    Layout.bottomMargin: -6
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: notifs.model

                        delegate: NotificationItem {
                            required property int index
                            required property string app
                            required property string summary
                            required property string body
                            required property int nid

                            Layout.fillWidth: true
                            Layout.preferredHeight: index < 30 ? implicitHeight : 0
                            visible: index < 30
                            appName: app
                            summaryText: summary
                            bodyText:    body
                            notifId: nid
                            warn: notifs.warnApps.indexOf(appName) >= 0

                            onDismissed: function(nid) { notifs.dismiss(nid) }
                        }
                    }
                }
            }
        }

        // ── Border gradients ──────────────────
        Rectangle {
            // Top border
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: 4
            z: 10
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: red }
                GradientStop { position: 0.2; color: orange }
                GradientStop { position: 0.4; color: cyan }
                GradientStop { position: 0.6; color: lime }
                GradientStop { position: 0.8; color: orange }
                GradientStop { position: 1.0; color: red }
            }
        }

        Rectangle {
            // Left border
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
            width: 4
            z: 10
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: red }
                GradientStop { position: 0.2; color: orange }
                GradientStop { position: 0.4; color: lime }
                GradientStop { position: 0.6; color: cyan }
                GradientStop { position: 0.8; color: orange }
                GradientStop { position: 1.0; color: red }
            }
        }

        Rectangle {
            // Right border
            anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
            width: 4
            z: 10
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: red }
                GradientStop { position: 0.2; color: orange }
                GradientStop { position: 0.4; color: lime }
                GradientStop { position: 0.6; color: cyan }
                GradientStop { position: 0.8; color: orange }
                GradientStop { position: 1.0; color: red }
            }
        }

        Rectangle {
            // Bottom border
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 4
            z: 10
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: red }
                GradientStop { position: 0.2; color: orange }
                GradientStop { position: 0.4; color: cyan }
                GradientStop { position: 0.6; color: lime }
                GradientStop { position: 0.8; color: orange }
                GradientStop { position: 1.0; color: red }
            }
        }
    }
}
