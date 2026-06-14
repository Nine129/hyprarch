import QtQuick
import QtQuick.Layouts
import "../services" as QsServices

// ═══════════════════════════════════════════════════════════════
// Audio Section — lime zone
// ═══════════════════════════════════════════════════════════════
Item {
    id: root

    readonly property var audio: QsServices.Audio

    readonly property color orange:  "#ff6b00"
    readonly property color lime:    "#c8ff00"
    readonly property color silver:  "#e8e8f0"
    readonly property color muted:   "#6a6a80"
    readonly property color surface2:"#1a1a20"

    implicitHeight: frame.height
    height: implicitHeight
    width: parent.width

    Frame {
        id: frame
        zone: "orange"
        header: "Audio"
        badge: audio.muted ? "MUTED" : audio.percentage + "%"
        bodyPad: -20
        bodyHeight: content.implicitHeight

        ColumnLayout {
            id: content
            width: parent.width
            spacing: 0

            // ── Master slider ─────────────
            Item {
                Layout.fillWidth: true
                height: 50
                Layout.topMargin: 10

                Row {
                    anchors.fill: parent
                    spacing: 12

                    Text {
                        text: audio.muted ? "\uf6a9" : "\uf028"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        color: orange
                        horizontalAlignment: Text.AlignHCenter
                        width: 22
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 8
                    }

                    Slider {
                        id: masterSlider
                        width: parent.width - 22 - 12
                        height: 26
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 12
                        maximum: 150
                        value: audio.percentage
                        trackHeight: 5
                        showThumb: true
                        startColor: orange
                        endColor: orange

                        onMoved: audio.setVolume(pct / 100)
                    }
                }
            }

            // ── Device meta ───────────────
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 3

                Text {
                    text: audio.defaultSinkName
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    color: muted
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
            }

            // ── Per-app streams ───────────
            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: 6
                spacing: 0

                Repeater {
                    model: audio.sinkInputs

                    delegate: Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32

                        required property var modelData

                        RowLayout {
                            anchors.fill: parent
                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 6
                                Layout.preferredHeight: 6
                                Layout.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                color: modelData.muted ? "#F9364B" : orange
                            }

                            Text {
                                text: modelData.name
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.bold: true
                                color: modelData.muted ? "#F9364B" : silver
                                Layout.preferredWidth: 90
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }

                            Slider {
                                Layout.fillWidth: true
                                maximum: 153
                                value: modelData.muted ? 0 : modelData.volume
                                trackHeight: 4
                                showThumb: false
                                startColor: orange
                                endColor: orange

                                onMoved: audio.setStreamVolume(modelData.inputIdx, pct / 100)
                            }

                            Text {
                                text: modelData.muted ? "—" : modelData.volume + "%"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                color: silver
                                Layout.preferredWidth: 34
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.topMargin: audio.sinkInputs.length === 0 ? 6 : 0
                Layout.preferredHeight: audio.sinkInputs.length === 0 ? noStreamsText.implicitHeight : 0
                visible: audio.sinkInputs.length === 0

                Text {
                    id: noStreamsText
                    anchors.centerIn: parent
                    text: "No active streams"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10
                    color: muted
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
