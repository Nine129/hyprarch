import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../services" as QsServices

PanelWindow {
    id: popout

    property bool shouldShow: false
    readonly property var power: QsServices.Power

    // ── Palette ──────────────────────────
    readonly property color bg:      "#0a0a0c"
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
    margins { right: 146; top: 38 }
    implicitWidth: 303
    implicitHeight: contentCol.implicitHeight + 28
    color: "transparent"
    visible: shouldShow

    // ── Escape dismiss (via hyprctl) ──
    onVisibleChanged: {
        if (visible)
            closeProc.running = true
        else
            unbindProc.running = true
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

    // ── Background ───────────────────────
    Rectangle {
        id: contentRoot
        anchors.fill: parent
        color: Qt.rgba(popout.bg.r, popout.bg.g, popout.bg.b, 0.94)
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
            columns: 2
            columnSpacing: 6
            rowSpacing: 6

            // HEALTH
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                color: popout.surface
                border.color: popout.border
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
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
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                color: popout.surface
                border.color: popout.border
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
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

            // DRAW
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                color: popout.surface
                border.color: popout.border
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 2

                    Text {
                        text: "DRAW"
                        font.family: popout.font
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 2
                        color: popout.lime
                    }
                    Text {
                        text: popout.fmtDraw(power.powerDraw)
                        font.family: popout.font
                        font.pixelSize: 16
                        font.bold: true
                        color: popout.silver
                    }
                }
            }

            // CHARGE LIMIT
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                color: popout.surface
                border.color: popout.border
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 2

                    Text {
                        text: "CHARGE LIMIT"
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

                delegate: Rectangle {
                    id: profileBlock
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    color: mouseArea.containsMouse
                        ? Qt.rgba(1, 1, 1, 0.04)
                        : (isActive ? Qt.rgba(1, 1, 1, 0.06) : popout.surface)
                    border.color: popout.border
                    border.width: 1

                    readonly property bool isActive: power.currentProfile === modelData.id
                    readonly property color accent: popout.lime

                    // Active left border
                    Rectangle {
                        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                        width: 4
                        color: isActive ? accent : "transparent"
                    }

                    // Subtle inner glow when active
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        color: "transparent"
                        border.color: isActive ? Qt.rgba(1, 1, 1, 0.06) : "transparent"
                        border.width: 1
                        visible: isActive
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 12

                        Text {
                            text: modelData.icon
                            font.family: popout.font
                            font.pixelSize: 20
                            color: popout.lime
                        }

                        Text {
                            text: modelData.label
                            font.family: popout.font
                            font.pixelSize: 12
                            font.bold: true
                            color: popout.silver
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
}
