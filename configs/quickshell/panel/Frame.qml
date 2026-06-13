import QtQuick
import QtQuick.Shapes

// ═══════════════════════════════════════════════════════════════
// Frame — reusable zone-colored panel wrapper with corner brackets
// ═══════════════════════════════════════════════════════════════
Rectangle {
    id: root

    required property string zone      // "orange" | "lime" | "red" | "cyan"
    property string header: ""         // left label next to dot
    property string badge: ""          // right metadata label
    property int bodyPad: 12           // horizontal body padding
    property int bodyHeight: 0         // content height (set by each section)
    property alias body: bodyItem.children

    width: parent.width
    height: headerRow.height + bodyHeight + bodyPad + 4
    color: "transparent"
    border.color: "transparent"
    border.width: 0

    readonly property color zoneColor: {
        switch (zone) {
            case "orange": return "#ff6b00"
            case "lime":   return "#c8ff00"
            case "red":    return "#F9364B"
            case "cyan":   return "#00e5ff"
            default:       return "#6a6a80"
        }
    }

    // ── Hover state ───────────────────────
    property bool hovered: false

    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }


    // ── Header row ────────────────────────
    Item {
        id: headerRow
        anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: -6 }
        height: 38

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: root.hovered = true
            onExited:  root.hovered = false
        }

        // Colored dot
        Rectangle {
            id: dot
            anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
            width: 4; height: 4
            color: root.zoneColor
        }

        // Header label
        Text {
            anchors { left: dot.right; leftMargin: 8; verticalCenter: parent.verticalCenter }
            text: root.header
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 9
            font.bold: true
            font.letterSpacing: 1.2
            color: "#6a6a80"
            textFormat: Text.PlainText
            verticalAlignment: Text.AlignVCenter
        }

        // Badge
        Rectangle {
            anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
            visible: root.badge !== ""
            width: badgeMetrics.advanceWidth + 16
            height: badgeMetrics.height + 4
            color: Qt.rgba(1, 1, 1, 0.03)

            TextMetrics {
                id: badgeMetrics
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10
                font.bold: true
                text: root.badge
            }

            Text {
                id: badgeText
                anchors.centerIn: parent
                text: root.badge
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10
                font.bold: true
                color: "#6a6a80"
                elide: Text.ElideRight
                maximumLineCount: 1
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                textFormat: Text.PlainText
            }
        }
    }

    // ── Body area ─────────────────────────
    Item {
        id: bodyItem
        anchors {
            left: parent.left
            right: parent.right
            top: headerRow.bottom
            leftMargin: root.bodyPad
            rightMargin: root.bodyPad
            topMargin: 8
        }
        height: root.bodyHeight
        clip: false
    }

    // ── Corner brackets (outside frame border) ──
    Shape {
        id: tlBracket
        anchors.fill: parent
        containsMode: Shape.FillContains

        ShapePath {
            strokeColor: root.hovered
                ? Qt.rgba(root.zoneColor.r, root.zoneColor.g, root.zoneColor.b, 0.40)
                : Qt.rgba(1, 1, 1, 0.15)
            strokeWidth: 2
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap
            joinStyle: ShapePath.MiterJoin

            Behavior on strokeColor {
                ColorAnimation { duration: 150 }
            }

            // Top-left L (┌)
            PathMove { x: -1; y: 7 }
            PathLine { x: -1; y: -1 }
            PathLine { x: 7;  y: -1 }
        }

        transform: Scale {
            origin.x: 7
            origin.y: 7
            xScale: root.hovered ? 1.5 : 1.0
            yScale: root.hovered ? 1.5 : 1.0

            Behavior on xScale { NumberAnimation { duration: 150 } }
            Behavior on yScale { NumberAnimation { duration: 150 } }
        }
    }

    Shape {
        id: brBracket
        anchors.fill: parent
        containsMode: Shape.FillContains

        ShapePath {
            strokeColor: root.hovered
                ? Qt.rgba(root.zoneColor.r, root.zoneColor.g, root.zoneColor.b, 0.40)
                : Qt.rgba(1, 1, 1, 0.15)
            strokeWidth: 2
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap
            joinStyle: ShapePath.MiterJoin

            Behavior on strokeColor {
                ColorAnimation { duration: 150 }
            }

            // Bottom-right L (┘)
            PathMove { x: root.width - 7; y: root.height + 1 }
            PathLine { x: root.width + 1; y: root.height + 1 }
            PathLine { x: root.width + 1; y: root.height - 7 }
        }

        transform: Scale {
            origin.x: root.width - 3.5
            origin.y: root.height - 3.5
            xScale: root.hovered ? 1.5 : 1.0
            yScale: root.hovered ? 1.5 : 1.0

            Behavior on xScale { NumberAnimation { duration: 150 } }
            Behavior on yScale { NumberAnimation { duration: 150 } }
        }
    }
}
