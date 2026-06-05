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
    readonly property var audio: QsServices.Audio

    readonly property color bg:      "#0a0a0c"
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
    margins { right: 146; top: 2 }
    implicitWidth: 303
    implicitHeight: contentCol.implicitHeight + 32
    color: "transparent"
    visible: shouldShow

    onVisibleChanged: {
        if (visible)
            closeProc.running = true
        else
            unbindProc.running = true
    }

    Process {
        id: closeProc
        command: ["hyprctl", "keyword", "bind", "Escape", "exec", "sh -c /home/nine/.config/quickshell/scripts/close-volume.sh"]
    }

    Process {
        id: unbindProc
        command: ["hyprctl", "keyword", "unbind", "Escape"]
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(popout.bg.r, popout.bg.g, popout.bg.b, 0.90)
    }

    ColumnLayout {
        id: contentCol
        anchors.fill: parent
        anchors.margins: 16
        anchors.bottomMargin: 32
        spacing: 0

        // ── Header ───────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 12
            Text { text: "VOLUME"; font.family: popout.font; font.pixelSize: 16; font.bold: true; color: popout.pink; font.letterSpacing: 2 }
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
            Layout.bottomMargin: 4
            spacing: 10

            Rectangle {
                id: muteBtn
                width: 28; height: 28; color: muteMouse.pressed ? Qt.rgba(popout.pink.r, popout.pink.g, popout.pink.b, 0.3) : (muteMouse.containsMouse ? Qt.rgba(popout.pink.r, popout.pink.g, popout.pink.b, 0.15) : popout.surface)
                border.color: audio.muted ? popout.red : (muteMouse.pressed ? popout.pink : popout.border); border.width: 1
                Text { anchors.centerIn: parent; text: audio.muted ? "󰝟" : "󰕾"; font.family: popout.font; font.pixelSize: 18; color: audio.muted ? popout.red : (muteMouse.pressed ? popout.pink : popout.silver) }
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
                    color: popout.surface; border.color: popout.border; border.width: 1
                    Rectangle {
                        width: sliderRoot.fillW; height: parent.height
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { color: popout.pink }
                            GradientStop { position: 1; color: popout.orange }
                        }
                    }
                    // Orange glow when holding
                    Rectangle {
                        width: sliderRoot.fillW; height: parent.height + 8
                        anchors.verticalCenter: parent.verticalCenter
                        color: "transparent"
                        border.color: sliderRoot.holding ? Qt.rgba(popout.orange.r, popout.orange.g, popout.orange.b, 0.4) : "transparent"
                        border.width: 2
                        visible: sliderRoot.holding
                    }
                }

                Rectangle {
                    id: thumb
                    width: 18; height: 18; color: popout.pink
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
                        sliderRoot.holding = true
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
                        sliderRoot.holding = false
                        commitTimer.stop()
                    }
                }
            }

            Rectangle {
                id: minusBtn
                width: 28; height: 28; color: minusMouse.pressed ? Qt.rgba(popout.pink.r, popout.pink.g, popout.pink.b, 0.3) : (minusMouse.containsMouse ? Qt.rgba(popout.pink.r, popout.pink.g, popout.pink.b, 0.15) : popout.surface)
                border.color: minusMouse.pressed ? popout.pink : popout.border; border.width: 1
                Text { anchors.centerIn: parent; text: "−"; font.family: popout.font; font.pixelSize: 20; color: popout.pressed ? popout.pink : popout.silver }
                MouseArea {
                    id: minusMouse
                    anchors.fill: parent; anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: audio.setVolume(Math.max(0, audio.volume - 0.01))
                }
            }
            Rectangle {
                id: plusBtn
                width: 28; height: 28; color: plusMouse.pressed ? Qt.rgba(popout.pink.r, popout.pink.g, popout.pink.b, 0.3) : (plusMouse.containsMouse ? Qt.rgba(popout.pink.r, popout.pink.g, popout.pink.b, 0.15) : popout.surface)
                border.color: plusMouse.pressed ? popout.pink : popout.border; border.width: 1
                Text { anchors.centerIn: parent; text: "+"; font.family: popout.font; font.pixelSize: 20; color: plusMouse.pressed ? popout.pink : popout.silver }
                MouseArea {
                    id: plusMouse
                    anchors.fill: parent; anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: audio.setVolume(Math.min(1, audio.volume + 0.01))
                }
            }
        }

        // ── Ticks ────────────────────────
        Item {
            Layout.fillWidth: true; Layout.preferredHeight: 14
            Layout.leftMargin: 38; Layout.rightMargin: 76; Layout.bottomMargin: 14

            // 0 at slider 0%
            Text { text: "0"; font.family: popout.font; font.pixelSize: 9; color: popout.muted; anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter }
            // 25 at slider 25%
            Text { text: "25"; font.family: popout.font; font.pixelSize: 9; color: popout.muted; anchors.horizontalCenter: parent.horizontalCenter; anchors.horizontalCenterOffset: -parent.width * 0.25 - 2; anchors.verticalCenter: parent.verticalCenter }
            // 50 at slider 50%
            Text { text: "50"; font.family: popout.font; font.pixelSize: 9; color: popout.muted; anchors.horizontalCenter: parent.horizontalCenter; anchors.horizontalCenterOffset: -2; anchors.verticalCenter: parent.verticalCenter }
            // 75 at slider 75%
            Text { text: "75"; font.family: popout.font; font.pixelSize: 9; color: popout.muted; anchors.horizontalCenter: parent.horizontalCenter; anchors.horizontalCenterOffset: parent.width * 0.25; anchors.verticalCenter: parent.verticalCenter }
            // 100 at slider 100%
            Text { text: "100"; font.family: popout.font; font.pixelSize: 9; color: popout.muted; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter }
        }

        // ── Device selector ──────────────
        ColumnLayout {
            Layout.fillWidth: true; spacing: 0
            Rectangle {
                id: devBtn
                Layout.fillWidth: true; Layout.preferredHeight: 36
                color: devMouse.pressed ? popout.border : (devMouse.containsMouse ? Qt.rgba(popout.pink.r, popout.pink.g, popout.pink.b, 0.15) : popout.surface)
                border.color: devDropdownOpen ? popout.pink : (devMouse.pressed ? popout.pink : popout.border); border.width: 1
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10; spacing: 8
                    Text { text: "󰓃"; font.family: popout.font; font.pixelSize: 14; color: popout.pink }
                    Text { text: audio.defaultSinkName; font.family: popout.font; font.pixelSize: 11; font.bold: true; color: devMouse.containsMouse ? popout.silver : popout.muted; Layout.fillWidth: true; elide: Text.ElideRight }
                    Text { text: "▾"; font.family: popout.font; font.pixelSize: 10; color: popout.muted; rotation: devDropdownOpen ? 180 : 0; Behavior on rotation { NumberAnimation { duration: 150 } } }
                }
                MouseArea {
                    id: devMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: devDropdownOpen = !devDropdownOpen
                }
            }
            ColumnLayout {
                Layout.fillWidth: true; Layout.leftMargin: 4; Layout.rightMargin: 4; Layout.topMargin: 4; spacing: 2
                visible: devDropdownOpen
                Repeater {
                    model: audio.availableSinks
                    delegate: Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: 30
                        color: modelData.isDefault ? Qt.rgba(popout.pink.r, popout.pink.g, popout.pink.b, 0.15) : "transparent"
                        border.color: modelData.isDefault ? popout.pink : "transparent"; border.width: 1
                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8; spacing: 6
                            Text { text: modelData.isDefault ? "●" : "○"; font.family: popout.font; font.pixelSize: 9; color: modelData.isDefault ? popout.pink : popout.muted }
                            Text { text: modelData.name; font.family: popout.font; font.pixelSize: 11; font.bold: true; color: modelData.isDefault ? popout.pink : popout.silver; Layout.fillWidth: true; elide: Text.ElideRight }
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { audio.switchSink(modelData.id); devDropdownOpen = false } }
                    }
                }
            }
        }

        // ── Streams ──────────────────────
        RowLayout {
            Layout.fillWidth: true; Layout.bottomMargin: 8
            Text { text: "PLAYBACK"; font.family: popout.font; font.pixelSize: 10; font.bold: true; color: popout.pink; font.letterSpacing: 2; Layout.topMargin: 8 }
        }

        Repeater {
            model: audio.sinkInputs
            delegate: Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 52
                color: popout.surface
                border.color: modelData.muted ? Qt.rgba(popout.red.r, popout.red.g, popout.red.b, 0.5) : popout.border; border.width: 1

                ColumnLayout {
                    anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10; anchors.topMargin: 6; anchors.bottomMargin: 6
                    spacing: 4

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
                        property bool holding: false
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
                            color: popout.border
                            Rectangle {
                                width: parent.parent.fillW; height: parent.height
                                color: modelData.muted ? Qt.rgba(popout.red.r, popout.red.g, popout.red.b, 0.5) : popout.orange
                            }
                            // Orange glow when holding
                            Rectangle {
                                width: parent.parent.fillW; height: parent.height + 6
                                anchors.verticalCenter: parent.verticalCenter
                                color: "transparent"
                                border.color: parent.parent.holding ? Qt.rgba(popout.orange.r, popout.orange.g, popout.orange.b, 0.4) : "transparent"
                                border.width: 1
                                visible: parent.parent.holding
                            }
                        }

                        Rectangle {
                            width: 12; height: 12
                            color: popout.pink; border.color: popout.bg; border.width: 1
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
                                parent.holding = true
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
                                parent.holding = false
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
            Layout.topMargin: 4; Layout.bottomMargin: 4
        }
    }
}
