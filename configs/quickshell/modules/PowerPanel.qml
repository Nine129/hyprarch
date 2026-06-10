import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../services" as QsServices

PanelWindow {
    id: popout

    property bool shouldShow: false
    property int trayWidth: 0
    readonly property var power: QsServices.Power

    // ── Palette ──────────────────────────
    readonly property color bg:      "#151518"
    readonly property color surface: "#1a1a20"
    readonly property color border:  "#2a2a35"
    readonly property color lime:    "#c8ff00"
    readonly property color silver:  "#e8e8f0"
    readonly property color muted:   "#6a6a80"
    readonly property string font:   "JetBrainsMono Nerd Font"

    // ── Format helpers ───────────────────
    function fmtPct(v) {
        if (isNaN(v) || v <= 0) return "—"
        return Math.round(v) + "%"
    }
    function fmtFloat(v) {
        if (isNaN(v) || v < 0) return "—"
        return v.toFixed(1) + "%"
    }
    function fmtDraw(v) {
        if (isNaN(v) || v < 0) return "—"
        return v.toFixed(1) + "W"
    }
    function fmtInt(v) {
        if (isNaN(v) || v <= 0) return "—"
        return String(v)
    }

    screen: Quickshell.screens[0]
    anchors { top: true; right: true }
    margins { right: 84 + trayWidth; top: 0 }
    implicitWidth: _effectiveVisible ? 303 : 0
    implicitHeight: contentCol.implicitHeight + 28
    color: "transparent"
    visible: true

    // ── Slide state ─────────────────
    property bool _effectiveVisible: false
    property bool _animOpen: false

    onShouldShowChanged: {
        if (shouldShow) {
            _effectiveVisible = true
            _animOpen = true
            closeProc.running = true
        } else {
            _animOpen = false
            unbindProc.running = true
            hideTimer.start()
        }
    }

    Timer {
        id: hideTimer
        interval: 250
        repeat: false
        onTriggered: {
            if (!shouldShow) _effectiveVisible = false
        }
    }

    Process {
        id: closeProc
        command: ["hyprctl", "keyword", "bind", "Escape", "exec",
            "sh -c 'echo 0 > /tmp/qs-power-state'"]
    }
    Process {
        id: unbindProc
        command: ["hyprctl", "keyword", "unbind", "Escape"]
    }
    Process {
        id: bgCloseProc
        // command set dynamically
    }

    Item {
        id: slideWrapper
        anchors.fill: parent
        transform: Translate {
            id: slide
            y: popout._animOpen ? 0 : -popout.height
            Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

    Rectangle {
        id: shadow
        x: 2; y: 2
        width: parent.width + 2; height: parent.height + 2
        color: Qt.rgba(0, 0, 0, 0.2)
        z: -1
    }

    // ── Background ───────────────────────
    Rectangle {
        id: contentRoot
        anchors.fill: parent
        color: popout.bg
        border.color: popout.border
        border.width: 1

        // Click background to dismiss
        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            onClicked: function(mouse) {
                popout.shouldShow = false
                bgCloseProc.command = ["sh", "-c", "echo 0 > /tmp/qs-power-state"]
                bgCloseProc.running = true
                mouse.accepted = false
            }
        }
    }

    // ── Main layout ──────────────────────
    ColumnLayout {
        id: contentCol
        anchors.fill: parent
        anchors.margins: 14
        spacing: 0

        // ── 1. Header: "63%      POWER" ──
        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 12
            spacing: 0

            Text {
                text: popout.fmtPct(power.batteryPercent)
                font.family: popout.font
                font.pixelSize: 28
                font.bold: true
                color: popout.silver
            }

            Item { Layout.fillWidth: true }

            Text {
                text: power.stateLabel
                font.family: popout.font
                font.pixelSize: 16
                font.bold: true
                font.letterSpacing: 2
                color: popout.lime
            }
        }

        // ── 2. Stats grid (2×2) ──────────
        GridLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 12
            columns: 3
            columnSpacing: 6
            rowSpacing: 6

            // HEALTH
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 52

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 0
                    anchors.topMargin: 10
                    anchors.rightMargin: 10
                    anchors.bottomMargin: 10
                    spacing: 2

                    Text {
                        text: "HEALTH"
                        font.family: popout.font
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 2
                        color: popout.lime
                    }
                    Text {
                        text: popout.fmtFloat(power.healthPercent)
                        font.family: popout.font
                        font.pixelSize: 16
                        font.bold: true
                        color: popout.silver
                    }
                }
            }

            // CYCLES
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 52

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 0
                    anchors.topMargin: 10
                    anchors.rightMargin: 10
                    anchors.bottomMargin: 10
                    spacing: 2

                    Text {
                        text: "CYCLES"
                        font.family: popout.font
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 2
                        color: popout.lime
                    }
                    Text {
                        text: popout.fmtInt(power.cycleCount)
                        font.family: popout.font
                        font.pixelSize: 16
                        font.bold: true
                        color: popout.silver
                    }
                }
            }

            // CHARGE
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 52

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 0
                    anchors.topMargin: 10
                    anchors.rightMargin: 10
                    anchors.bottomMargin: 10
                    spacing: 2

                    Text {
                        text: "CHARGE"
                        font.family: popout.font
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 2
                        color: popout.lime
                    }
                    Text {
                        text: power.chargeThreshold > 0 ? power.chargeThreshold + "%" : "—"
                        font.family: popout.font
                        font.pixelSize: 16
                        font.bold: true
                        color: popout.silver
                    }
                }
            }
        }

        // ── 3. "PERFORMANCE PROFILE" label ─
        Text {
            text: "PERFORMANCE PROFILE"
            font.family: popout.font
            font.pixelSize: 10
            font.bold: true
            font.letterSpacing: 2.5
            color: popout.lime
            Layout.bottomMargin: 6
        }

        // ── 4. Profile blocks (stacked) ──
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            Repeater {
                model: power.profileDefs

                delegate: Item {
                    id: profileBlock
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: 44

                    readonly property bool isActive: power.currentProfile === modelData.id

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 0
                        anchors.rightMargin: 14
                        spacing: 12

                        Item {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: parent.height

                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                font.family: popout.font
                                font.pixelSize: 20
                                color: mouseArea.containsMouse ? popout.silver : popout.lime
                            }
                        }

                        Text {
                            text: modelData.label
                            font.family: popout.font
                            font.pixelSize: 12
                            font.bold: true
                            color: isActive ? popout.lime : (mouseArea.containsMouse ? popout.silver : popout.muted)
                            Layout.fillWidth: true
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        anchors.margins: -4
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: power.setProfile(modelData.id)
                    }
                }
            }
        }
    }
    }  // slideWrapper
}
