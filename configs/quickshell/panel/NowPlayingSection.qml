import QtQuick
import QtQuick.Layouts
import "../services" as QsServices

// ═══════════════════════════════════════════════════════════════
// Now Playing Section — orange zone
// ═══════════════════════════════════════════════════════════════
Item {
    id: root

    readonly property var mpris: QsServices.MprisService
    readonly property bool hasPlayer: mpris.hasPlayer

    readonly property color orange:  "#ff6b00"
    readonly property color cyan:    "#00e5ff"
    readonly property color lime:    "#c8ff00"
    readonly property color red:     "#F9364B"
    readonly property color silver:  "#e8e8f0"
    readonly property color muted:   "#6a6a80"
    readonly property color surface2:"#1a1a20"

    implicitHeight: frame.height
    height: implicitHeight
    width: parent.width

    function fmtSecs(s) {
        if (isNaN(s) || s < 0) return "0:00"
        const mins = Math.floor(s / 60)
        const secs = Math.floor(s % 60)
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }

    Frame {
        id: frame
        zone: "orange"
        header: "Now Playing"
        badge: "MPD"
        bodyPad: -20
        bodyHeight: content.implicitHeight

        RowLayout {
            id: content
            width: parent.width
            height: implicitHeight
            spacing: 16
            Layout.topMargin: 16

            // ── Cover ─────────────────────
            Rectangle {
                Layout.preferredWidth: 110
                Layout.preferredHeight: 110
                color: surface2

                Image {
                    anchors.fill: parent
                    source: mpris.artUrl
                    fillMode: Image.PreserveAspectCrop
                    visible: mpris.artUrl !== ""
                }

                Text {
                    anchors.centerIn: parent
                    visible: mpris.artUrl === ""
                    text: "\u266B"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 40
                    color: muted
                }
            }

            // ── Info ──────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: hasPlayer ? (mpris.trackTitle || "______") : "______"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 16
                    font.bold: true
                    color: orange
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Text {
                    Layout.fillWidth: true
                    Layout.topMargin: 3
                    text: hasPlayer ? (mpris.trackArtist || "______") : "______"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    font.bold: true
                    color: cyan
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                // Progress bar
                Item {
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    Layout.preferredHeight: 5

                    readonly property real frac: (mpris.length > 0)
                        ? Math.min(1, Math.max(0, mpris.position / mpris.length))
                        : 0

                    Rectangle {
                        anchors.fill: parent
                        color: surface2
                    }

                    Rectangle {
                        width: parent.width * parent.frac
                        height: parent.height

                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: orange }
                            GradientStop { position: 1.0; color: red }
                        }
                    }
                }

                // Times
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 4

                    Text {
                        text: fmtSecs(mpris.position)
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                        font.bold: true
                        color: muted
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: fmtSecs(mpris.length)
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                        font.bold: true
                        color: muted
                    }
                }

                // Controls
                RowLayout {
                    Layout.topMargin: 10
                    spacing: 18

                    Text {
                        text: "\uf04a" // previous
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        color: prevMouse.containsMouse ? "#ff9040" : orange

                        MouseArea {
                            id: prevMouse
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: mpris.previous()
                        }
                    }

                    Text {
                        text: mpris.isPlaying ? "\uf04c" : "\uf04b" // pause/play
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 18
                        color: toggleMouse.containsMouse ? "#40f0ff" : cyan

                        MouseArea {
                            id: toggleMouse
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: mpris.togglePlaying()
                        }
                    }

                    Text {
                        text: "\uf04e" // next
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        color: nextMouse.containsMouse ? "#d4ff40" : lime

                        MouseArea {
                            id: nextMouse
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: mpris.next()
                        }
                    }
                }
            }
        }
    }
}
