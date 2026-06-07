import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../services" as QsServices

PanelWindow {
    id: popout

    property bool shouldShow: false
    property bool devDropdownOpen: false
    property int trayWidth: 0
    readonly property var audio: QsServices.Audio

    readonly property color bg:      "#151518"
    readonly property color surface: "#1a1a20"
    readonly property color border:  "#2a2a35"
    readonly property color orange:  "#ff6b00"
    readonly property color pink:    "#ff6b00"
    readonly property color red:     "#ff2d55"
    readonly property color silver:  "#e8e8f0"
    readonly property color muted:   "#6a6a80"
    readonly property string font:   "JetBrainsMono Nerd Font"

    screen: Quickshell.screens[0]
    anchors { top: true; right: true }
    margins { right: 84 + trayWidth; top: 0 }
    implicitWidth: 303
    implicitHeight: contentCol.implicitHeight + 48
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
            "sh -c 'echo 0 > /tmp/qs-volume-state'"]
    }
    Process {
        id: unbindProc
        command: ["hyprctl", "keyword", "unbind", "Escape"]
    }
    Process {
        id: bgCloseProc
        // command set dynamically
    }

    Rectangle {
        id: shadow
        x: 2; y: 2
        width: parent.width + 2; height: parent.height + 2
        color: Qt.rgba(0, 0, 0, 0.2)
        z: -1
    }

    Rectangle {
        id: contentRoot
        anchors.fill: parent
        color: popout.bg

        // Click background to dismiss
        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            onClicked: function(mouse) {
                popout.shouldShow = false
                bgCloseProc.command = ["sh", "-c", "echo 0 > /tmp/qs-volume-state"]
                bgCloseProc.running = true
                mouse.accepted = false
            }
        }
    }

    ColumnLayout {
        id: contentCol
        anchors.fill: parent
        anchors.margins: 18
        anchors.bottomMargin: 28
        spacing: 0

        // ── Header ───────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 16
            Text { text: "VOLUME"; font.family: popout.font; font.pixelSize: 16; font.bold: true; color: popout.orange; font.letterSpacing: 2 }
            Item { Layout.fillWidth: true }
            Text {
                id: pctText
                text: audio.muted ? "—" : Math.min(audio.percentage, 100) + "%"
                font.family: popout.font; font.pixelSize: 28; font.bold: true
                color: audio.muted ? popout.red : popout.silver
            }
        }

        // ── Mute | Slider | − | + ────────
        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 6
            spacing: 10

            // Mute toggle
            Text {
                id: muteBtn
                text: audio.muted ? "󰝟" : "󰕾"
                font.family: popout.font; font.pixelSize: 18
                color: audio.muted ? popout.red : (muteMouse.containsMouse ? popout.orange : popout.silver)
                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                Layout.preferredWidth: 28; Layout.preferredHeight: 28

                MouseArea {
                    id: muteMouse
                    anchors.fill: parent; anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: audio.toggleMute()
                }
            }

            // Slider
            Item {
                id: sliderRoot
                Layout.fillWidth: true
                Layout.preferredHeight: 28

                property bool dragging: false
                property bool holding: false
                property real dragPct: -1
                property real basePct: audio.muted ? 0 : audio.percentage
                property real displayPct: dragPct >= 0 ? dragPct : basePct
                property real fillW: Math.max(0, Math.min(1, displayPct / 100)) * width

                Timer {
                    id: commitTimer
                    interval: 50; repeat: false
                    onTriggered: {
                        if (sliderRoot.dragPct >= 0)
                            audio.setVolume(sliderRoot.dragPct / 100)
                    }
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width; height: 6
                    color: popout.surface
                    Rectangle {
                        width: sliderRoot.fillW; height: parent.height
                        color: popout.orange
                    }
                }

                Rectangle {
                    id: thumb
                    width: 18; height: 18; color: popout.orange
                    border.color: popout.bg; border.width: 2
                    anchors.verticalCenter: parent.verticalCenter
                    x: sliderRoot.fillW - width / 2
                    z: 2
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    preventStealing: true

                    function pctFromX(mx) {
                        return Math.max(0, Math.min(100, (mx / sliderRoot.width) * 100))
                    }
                    onPressed: function(mouse) {
                        sliderRoot.dragging = true
                        sliderRoot.dragPct = pctFromX(mouse.x)
                        commitTimer.restart()
                    }
                    onPositionChanged: function(mouse) {
                        if (sliderRoot.dragging && pressed) {
                            sliderRoot.dragPct = pctFromX(mouse.x)
                            commitTimer.restart()
                        }
                    }
                    onReleased: function(mouse) {
                        if (sliderRoot.dragPct >= 0)
                            audio.setVolume(sliderRoot.dragPct / 100)
                        sliderRoot.dragging = false
                        commitTimer.stop()
                    }
                }
            }

            // −
            Text {
                text: "−"
                font.family: popout.font; font.pixelSize: 20
                color: minusMouse.containsMouse ? popout.orange : popout.silver
                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                Layout.preferredWidth: 28; Layout.preferredHeight: 28

                MouseArea {
                    id: minusMouse
                    anchors.fill: parent; anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: audio.setVolume(Math.max(0, audio.volume - 0.01))
                }
            }

            // +
            Text {
                text: "+"
                font.family: popout.font; font.pixelSize: 20
                color: plusMouse.containsMouse ? popout.orange : popout.silver
                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                Layout.preferredWidth: 28; Layout.preferredHeight: 28

                MouseArea {
                    id: plusMouse
                    anchors.fill: parent; anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: audio.setVolume(Math.min(1, audio.volume + 0.01))
                }
            }
        }

        // ── Device selector ──────────────
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: popout.border
        }

        ColumnLayout {
            Layout.fillWidth: true; spacing: 0

            RowLayout {
                Layout.fillWidth: true; Layout.preferredHeight: 40
                spacing: 8

                Text { text: "󰓃"; font.family: popout.font; font.pixelSize: 14; color: popout.orange; verticalAlignment: Text.AlignVCenter }
                Text {
                    text: audio.defaultSinkName
                    font.family: popout.font; font.pixelSize: 11; font.bold: true
                    color: devMouse.containsMouse ? popout.silver : popout.muted
                    Layout.fillWidth: true; elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    text: "▾"
                    font.family: popout.font; font.pixelSize: 10
                    color: popout.muted
                    rotation: devDropdownOpen ? 180 : 0
                    Behavior on rotation { NumberAnimation { duration: 150 } }
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    id: devMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: devDropdownOpen = !devDropdownOpen
                }
            }

            // Dropdown
            ColumnLayout {
                Layout.fillWidth: true; Layout.leftMargin: 4; Layout.rightMargin: 4; Layout.topMargin: 4; spacing: 2
                visible: devDropdownOpen
                Repeater {
                    model: audio.availableSinks
                    delegate: Item {
                        Layout.fillWidth: true; Layout.preferredHeight: 30
                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8; spacing: 6
                            Text { text: modelData.isDefault ? "●" : "○"; font.family: popout.font; font.pixelSize: 9; color: modelData.isDefault ? popout.orange : popout.muted }
                            Text { text: modelData.name; font.family: popout.font; font.pixelSize: 11; font.bold: true; color: modelData.isDefault ? popout.orange : popout.silver; Layout.fillWidth: true; elide: Text.ElideRight }
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { audio.switchSink(modelData.id); devDropdownOpen = false } }
                    }
                }
            }
        }

        // ── Streams ──────────────────────
        Text {
            text: "PLAYBACK"
            font.family: popout.font; font.pixelSize: 10; font.bold: true
            color: popout.orange; font.letterSpacing: 2
            Layout.topMargin: 18; Layout.bottomMargin: 10
        }

        Repeater {
            model: audio.sinkInputs
            delegate: Item {
                Layout.fillWidth: true; Layout.preferredHeight: 56

                ColumnLayout {
                    anchors.fill: parent; anchors.leftMargin: 0; anchors.rightMargin: 0; anchors.topMargin: 8; anchors.bottomMargin: 8
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: modelData.name
                            font.family: popout.font; font.pixelSize: 11; font.bold: true
                            color: modelData.muted ? popout.red : popout.silver
                            elide: Text.ElideRight; Layout.fillWidth: true
                        }
                        Text {
                            text: modelData.muted ? "—" : Math.min(modelData.volume, 153) + "%"
                            font.family: popout.font; font.pixelSize: 10; font.bold: true
                            color: modelData.muted ? popout.red : popout.muted
                        }
                    }

                    Item {
                        Layout.fillWidth: true; Layout.preferredHeight: 14

                        property bool dragging: false
                        property real dragPct: -1
                        property real basePct: modelData.muted ? 0 : modelData.volume
                        property real displayPct: dragPct >= 0 ? dragPct : basePct
                        property real fillW: Math.max(0, Math.min(1, displayPct / 153)) * width
                        property int inputIdx: modelData.inputIdx !== undefined ? modelData.inputIdx : -1

                        Timer {
                            id: sCommitTimer
                            interval: 50; repeat: false
                            onTriggered: {
                                if (parent.dragPct >= 0 && parent.inputIdx >= 0)
                                    audio.setStreamVolume(parent.inputIdx, parent.dragPct / 100)
                            }
                        }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width; height: 3
                            color: popout.surface
                            Rectangle {
                                width: parent.parent.fillW; height: parent.height
                                color: modelData.muted ? Qt.rgba(popout.red.r, popout.red.g, popout.red.b, 0.5) : popout.orange
                            }
                        }

                        Rectangle {
                            width: 12; height: 12
                            color: popout.orange; border.color: popout.bg; border.width: 1
                            anchors.verticalCenter: parent.verticalCenter
                            x: parent.fillW - width / 2
                            z: 2
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            preventStealing: true

                            function pctFromX(mx) {
                                return Math.max(0, Math.min(153, (mx / parent.width) * 153))
                            }
                            onPressed: function(mouse) {
                                parent.dragging = true
                                parent.dragPct = pctFromX(mouse.x)
                                sCommitTimer.restart()
                            }
                            onPositionChanged: function(mouse) {
                                if (parent.dragging && pressed) {
                                    parent.dragPct = pctFromX(mouse.x)
                                    sCommitTimer.restart()
                                }
                            }
                            onReleased: function(mouse) {
                                if (parent.dragPct >= 0 && parent.inputIdx >= 0)
                                    audio.setStreamVolume(parent.inputIdx, parent.dragPct / 100)
                                parent.dragging = false
                                sCommitTimer.stop()
                            }
                        }
                    }
                }
            }
        }

        Text {
            visible: audio.sinkInputs.length === 0
            text: "No active streams"
            font.family: popout.font; font.pixelSize: 10; color: popout.muted
            Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter
            Layout.topMargin: 6; Layout.bottomMargin: 4
        }
    }
}
