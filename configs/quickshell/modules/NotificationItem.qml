import QtQuick
import QtQuick.Layouts

Item {
    id: itemRoot

    signal dismissRequested(int nid)

    property string appName: ""
    property string summary: ""
    property string body: ""
    property string timeText: ""
    property int notifId: 0

    implicitHeight: infoCol.implicitHeight + 20
    implicitWidth: parent ? parent.width : 340

    opacity: 1
    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    function triggerDismiss() {
        itemRoot.opacity = 0
        dismissTimer.start()
    }

    Timer {
        id: dismissTimer
        interval: 210
        repeat: false
        onTriggered: itemRoot.dismissRequested(itemRoot.notifId)
    }

    // ── Click anywhere to dismiss ────────
    MouseArea {
        id: clickArea
        anchors.fill: parent
        anchors.margins: -4
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: itemRoot.triggerDismiss()
    }

    // ── App name row ─────────────────────
    RowLayout {
        id: headerRow
        anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: 10 }
        spacing: 6

        Text {
            id: appLabel
            text: itemRoot.appName.toUpperCase()
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 10
            font.bold: true
            font.letterSpacing: 1
            color: "#c8ff00"
        }

        Item { Layout.fillWidth: true }

        Text {
            id: timeLabel
            text: itemRoot.timeText
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 10
            font.bold: false
            color: "#e8e8f0"
        }
    }

    // ── Summary + Body ───────────────────
    ColumnLayout {
        id: infoCol
        anchors { left: parent.left; right: parent.right; top: headerRow.bottom; topMargin: 4 }
        spacing: 2

        Text {
            id: summaryText
            text: itemRoot.summary
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            font.bold: true
            color: clickArea.containsMouse ? "#ff9040" : "#ff6b00"
            Layout.fillWidth: true
            elide: Text.ElideRight
            maximumLineCount: 1
            wrapMode: Text.NoWrap
        }

        Text {
            id: bodyText
            text: itemRoot.body
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            color: "#00e5ff"
            Layout.fillWidth: true
            elide: Text.ElideRight
            maximumLineCount: 2
            wrapMode: Text.WrapAnywhere
            visible: itemRoot.body.length > 0
        }
    }
}
