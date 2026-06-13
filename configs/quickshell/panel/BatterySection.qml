import QtQuick
import QtQuick.Layouts
import "../services" as QsServices

// ═══════════════════════════════════════════════════════════════
// Battery Section — red zone
// ═══════════════════════════════════════════════════════════════
Item {
    id: root

    readonly property var power: QsServices.Power

    readonly property color red:     "#F9364B"
    readonly property color lime:    "#c8ff00"
    readonly property color silver:  "#e8e8f0"
    readonly property color muted:   "#6a6a80"
    readonly property color surface2:"#1a1a20"
    readonly property color border:  "#2a2a35"

    implicitHeight: frame.height
    height: implicitHeight
    width: parent.width

    function fmtPct(v) {
        if (isNaN(v) || v <= 0) return "—"
        return Math.round(v) + "%"
    }

    function fmtInt(v) {
        if (isNaN(v) || v <= 0) return "—"
        return String(v)
    }

    Frame {
        id: frame
        zone: "lime"
        header: "Battery"
        bodyPad: 0
        bodyHeight: content.implicitHeight

        ColumnLayout {
            id: content
            width: parent.width
            height: implicitHeight
        spacing: 0

        // ── Top: hero + stats ─────────
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            spacing: 0

            // Hero square
            Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 100
                color: surface2

                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(lime.r, lime.g, lime.b, 0.06)
                }

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.color: Qt.rgba(lime.r, lime.g, lime.b, 0.12)
                    border.width: 1
                }

                Text {
                    anchors.centerIn: parent
                    text: fmtPct(power.batteryPercent)
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 22
                    font.bold: true
                    color: lime
                }
            }

            // Stats column
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                Repeater {
                    model: [
                        { label: "Health", value: fmtPct(power.healthPercent) },
                        { label: "Cycles", value: fmtInt(power.cycleCount) },
                        { label: "Charge Limit", value: power.chargeThreshold > 0 ? power.chargeThreshold + "%" : "—" }
                    ]

                    delegate: Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        required property int index
                        required property var modelData

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16

                            Text {
                                text: modelData.label
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 9
                                font.bold: true
                                color: muted
                                textFormat: Text.PlainText
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: modelData.value
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 14
                                font.bold: true
                                color: silver
                            }
                        }

                        // Separator
                        Rectangle {
                            visible: index < 2
                            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                            height: 1
                            color: Qt.rgba(1, 1, 1, 0.06)
                        }
                    }
                }
            }
        }

        // ── Profile buttons ───────────
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            Layout.bottomMargin: -44
            spacing: 0

            Repeater {
                model: power.profileDefs

                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: index > 0 ? -1 : 0
                    color: isActive ? Qt.rgba(lime.r, lime.g, lime.b, 0.10) : Qt.rgba(1, 1, 1, 0.03)
                    border.color: isActive ? Qt.rgba(lime.r, lime.g, lime.b, 0.35) : Qt.rgba(1, 1, 1, 0.06)
                    border.width: 1

                    required property int index
                    required property var modelData
                    readonly property bool isActive: power.currentProfile === modelData.id

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: modelData.icon
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 18
                            color: lime
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: modelData.label
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 9
                            font.bold: true
                            color: isActive ? lime : silver
                            textFormat: Text.PlainText
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: power.setProfile(modelData.id)
                    }
                }
            }
        }
        }
    }
}
