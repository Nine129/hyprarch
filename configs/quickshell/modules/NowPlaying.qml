import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../services" as QsServices

Item {
    id: npRoot

    readonly property var mpris: QsServices.MprisService

    implicitHeight: artCircle.height + npTitle.implicitHeight + npArtist.implicitHeight
                    + progressBar.height + npTimes.implicitHeight + npControls.implicitHeight
                    + 8 + 6 + 6 + 6 + 6 + 8 + 20
    implicitWidth: parent ? parent.width : 340

    // ── Spin state ────────────────────────
    property real _spinAngle: 0
    property string _lastTitle: ""
    property string _lastArtist: ""

    Timer {
        id: spinTimer
        interval: 16
        running: mpris.isPlaying
        repeat: true
        onTriggered: {
            npRoot._spinAngle = (npRoot._spinAngle + 0.72) % 360
        }
    }

    // Reset spin on track change
    Connections {
        target: mpris
        function onTrackTitleChanged() {
            npRoot._spinAngle = 0
        }
    }

    // ── Time formatter ────────────────────
    function fmtSecs(s) {
        if (isNaN(s) || s < 0) return "0:00"
        const mins = Math.floor(s / 60)
        const secs = Math.floor(s % 60)
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }

    // ── Progress fraction ─────────────────
    property real progressFrac: (mpris.length > 0) ? Math.min(1, Math.max(0, mpris.position / mpris.length)) : 0

    // ── Album art ─────────────────────────
    Item {
        id: artCircle
        width: 130; height: 130
        anchors { horizontalCenter: parent.horizontalCenter }

        // Background circle
        Rectangle {
            anchors.fill: parent
            radius: 65
            color: "#1a1a20"
        }

        // Spinning artwork with layer-effect circular mask
        Image {
            id: artImage
            anchors.fill: parent
            source: mpris.artUrl
            fillMode: Image.PreserveAspectCrop
            visible: mpris.artUrl !== ""
            rotation: npRoot._spinAngle

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: maskRect
            }
        }

        // Mask definition (sampled by the layer effect)
        Rectangle {
            id: maskRect
            width: 130; height: 130
            radius: 65
            color: "white"
            visible: false  // not painted but still sampled by OpacityMask
        }

        // Placeholder (music note) when no art
        Text {
            anchors.centerIn: parent
            text: "\u266B"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 48
            color: "#6a6a80"
            visible: mpris.artUrl === ""
        }
    }

    // ── Song title ────────────────────────
    Text {
        id: npTitle
        anchors { top: artCircle.bottom; topMargin: 8; horizontalCenter: parent.horizontalCenter }
        text: mpris.hasPlayer ? (mpris.trackTitle || "______") : "______"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 16
        font.bold: true
        color: "#ff6b00"
        width: parent.width - 40
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        maximumLineCount: 1
    }

    // ── Artist ────────────────────────────
    Text {
        id: npArtist
        anchors { top: npTitle.bottom; topMargin: 2; horizontalCenter: parent.horizontalCenter }
        text: mpris.hasPlayer ? (mpris.trackArtist || "______") : "______"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 13
        font.bold: true
        color: "#00e5ff"
        width: parent.width - 40
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        maximumLineCount: 1
    }

    // ── Progress bar ──────────────────────
    Rectangle {
        id: progressBar
        anchors { top: npArtist.bottom; topMargin: 8; left: parent.left; leftMargin: 20; right: parent.right; rightMargin: 20 }
        height: 6
        radius: 3
        color: "#2a2a35"

        Rectangle {
            id: progressFill
            height: parent.height
            width: parent.width * npRoot.progressFrac
            radius: 3

            gradient: Gradient {
                GradientStop { position: 0.0; color: "#ff6b00" }
                GradientStop { position: 1.0; color: "#c8ff00" }
            }
        }
    }

    // ── Time stamps ───────────────────────
    RowLayout {
        id: npTimes
        anchors { top: progressBar.bottom; topMargin: 4; left: parent.left; leftMargin: 20; right: parent.right; rightMargin: 20 }

        Text {
            text: npRoot.fmtSecs(mpris.position)
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            font.bold: true
            color: "#e8e8f0"
        }

        Item { Layout.fillWidth: true }

        Text {
            text: npRoot.fmtSecs(mpris.length)
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            font.bold: true
            color: "#e8e8f0"
        }
    }

    // ── Controls ──────────────────────────
    RowLayout {
        id: npControls
        anchors { top: npTimes.bottom; topMargin: 8; horizontalCenter: parent.horizontalCenter }
        spacing: 20

        // Previous
        Text {
            text: "\uf04a"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            color: prevMouse.containsMouse ? "#ff9040" : "#ff6b00"

            MouseArea {
                id: prevMouse
                anchors.fill: parent; anchors.margins: -6
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: mpris.previous()
            }
        }

        // Play / Pause
        Text {
            text: mpris.isPlaying ? "\uf04c" : "\uf04b"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 18
            color: toggleMouse.containsMouse ? "#40f0ff" : "#00e5ff"

            MouseArea {
                id: toggleMouse
                anchors.fill: parent; anchors.margins: -6
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: mpris.togglePlaying()
            }
        }

        // Next
        Text {
            text: "\uf04e"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            color: nextMouse.containsMouse ? "#d4ff40" : "#c8ff00"

            MouseArea {
                id: nextMouse
                anchors.fill: parent; anchors.margins: -6
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: mpris.next()
            }
        }
    }
}
