import QtQuick
import QtQuick.Layouts
import "../services" as QsServices

// ═══════════════════════════════════════════════════════════════
// Notification Item — single dismissable row
// ═══════════════════════════════════════════════════════════════
Rectangle {
    id: root

    required property string appName
    required property string summaryText
    required property string bodyText
    required property int notifId
    property bool warn: false

    signal dismissed(int nid)

    width: parent.width
    implicitHeight: layout.implicitHeight + 24
    height: implicitHeight
    color: notifMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(1, 1, 1, 0.03)
    border.color: warn ? Qt.rgba(0xF9/255, 0x36/255, 0x4B/255, 0.20) : (notifMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.05))
    border.width: 1

    readonly property color accent: warn ? "#F9364B" : "#F9364B"
    readonly property color surface2: "#1a1a20"

    opacity: 1

    Behavior on opacity {
        NumberAnimation { duration: 180 }
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // Icon
        Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            color: warn ? Qt.rgba(0xF9/255, 0x36/255, 0x4B/255, 0.10) : surface2

            Text {
                anchors.centerIn: parent
                text: appName.charAt(0).toUpperCase()
                font.family: "MonaspiceNe Nerd Font"
                font.pixelSize: 15
                font.bold: true
                color: accent
            }
        }

        // Text
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Text {
                text: appName
                font.family: "MonaspiceNe Nerd Font"
                font.pixelSize: 9
                font.bold: true
                color: accent
                textFormat: Text.PlainText
            }

            Text {
                text: summaryText
                font.family: "MonaspiceNe Nerd Font"
                font.pixelSize: 11
                font.bold: true
                color: "#e8e8f0"
                Layout.fillWidth: true
                elide: Text.ElideRight
                maximumLineCount: 1
                textFormat: Text.PlainText
            }

            Text {
                text: bodyText
                font.family: "MonaspiceNe Nerd Font"
                font.pixelSize: 10
                color: "#6a6a80"
                Layout.fillWidth: true
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.Wrap
                textFormat: Text.PlainText
            }
        }
    }

    MouseArea {
        id: notifMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: {
            root.opacity = 0
            dismissTimer.start()
        }
    }

    Timer {
        id: dismissTimer
        interval: 200
        repeat: false
        onTriggered: root.dismissed(root.notifId)
    }
}
