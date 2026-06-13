import QtQuick

// ═══════════════════════════════════════════════════════════════
// Slider — simple horizontal draggable percentage slider
// ═══════════════════════════════════════════════════════════════
Item {
    id: root

    property real value: 0          // 0..maximum display value (external binding)
    property real maximum: 100      // logical maximum (e.g. 150 for master)
    property int trackHeight: 5
    property bool showThumb: true
    property color startColor: "#c8ff00"
    property color endColor:   "#ff6b00"
    property color thumbColor: "#F9364B"
    property color trackColor: "#1a1a20"

    signal moved(real pct)

    // Override value while dragging for responsive feedback
    property real _dragValue: -1
    readonly property real displayValue: _dragValue >= 0 ? _dragValue : value
    readonly property real frac: Math.max(0, Math.min(1, displayValue / maximum))

    height: showThumb ? 26 : trackHeight
    implicitHeight: showThumb ? 26 : trackHeight

    Rectangle {
        y: showThumb ? 16 : 0
        width: parent.width
        height: trackHeight
        color: trackColor

        Rectangle {
            width: parent.width * root.frac
            height: parent.height

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: startColor }
                GradientStop { position: 1.0; color: endColor }
            }
        }
    }

    Rectangle {
        id: thumb
        visible: showThumb
        width: 12; height: 12
        color: thumbColor
        y: showThumb ? 12 : 0
        x: Math.max(0, (parent.width * root.frac) - width / 2)
    }

    MouseArea {
        y: showThumb ? 11 : 0
        height: showThumb ? 15 : trackHeight
        width: parent.width
        cursorShape: Qt.PointingHandCursor
        preventStealing: true

        function pctFromX(mx) {
            return Math.max(0, Math.min(root.maximum, (mx / root.width) * root.maximum))
        }

        onPressed: function(mouse) {
            root._dragValue = pctFromX(mouse.x)
            root.moved(root._dragValue)
        }

        onPositionChanged: function(mouse) {
            if (pressed) {
                root._dragValue = pctFromX(mouse.x)
                root.moved(root._dragValue)
            }
        }

        onReleased: function(mouse) {
            root._dragValue = -1
        }

        onCanceled: {
            root._dragValue = -1
        }
    }
}
