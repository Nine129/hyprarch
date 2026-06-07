import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// ═══════════════════════════════════════════════════════════════
// TimePanel — Clock + month calendar with timezone carousel
// ═══════════════════════════════════════════════════════════════
PanelWindow {
    id: popout

    property bool shouldShow: false
    property int trayWidth: 0

    // ── Palette ──
    readonly property color bg:      "#151518"
    readonly property color surface: "#1a1a20"
    readonly property color border:  "#2a2a35"
    readonly property color cyan:    "#00e5ff"
    readonly property color silver:  "#e8e8f0"
    readonly property color muted:   "#6a6a80"
    readonly property string font:   "JetBrainsMono Nerd Font"

    // ── State ──
    property int tzIndex: 0
    property var timezones: [
        { name: "Local", offset: -new Date().getTimezoneOffset() / 60 },
        { name: "HST", offset: -10 },
        { name: "AKT", offset: -9 },
        { name: "PT",  offset: -8 },
        { name: "MT",  offset: -7 },
        { name: "CT",  offset: -6 },
        { name: "ET",  offset: -5 },
        { name: "BRT", offset: -3 },
        { name: "UTC", offset: 0 },
        { name: "GMT", offset: 0 },
        { name: "CET", offset: 1 },
        { name: "MSK", offset: 3 },
        { name: "IST", offset: 5.5 },
        { name: "CST", offset: 8 },
        { name: "JST", offset: 9 },
        { name: "AET", offset: 10 },
        { name: "NZT", offset: 12 },
    ]
    property int dispYear:  new Date().getFullYear()
    property int dispMonth: new Date().getMonth()
    property string clockText: "00:00:00"
    property var calendarCells: []

    // ── Timezone helpers ──
    function getOffset(tzOff) {
        return (tzOff + new Date().getTimezoneOffset() / 60) * 3600000
    }

    function nowInTZ(tzOff) {
        return new Date(new Date().getTime() + getOffset(tzOff))
    }

    function fmtTime(d) {
        var h = d.getHours().toString()
        var m = d.getMinutes().toString()
        var s = d.getSeconds().toString()
        if (h.length < 2) h = "0" + h
        if (m.length < 2) m = "0" + m
        if (s.length < 2) s = "0" + s
        return h + ":" + m + ":" + s
    }

    // ── Rebuild TZ carousel ──
    // ── Rebuild calendar ──
    function rebuildCalendar() {
        var tzOff = timezones[tzIndex].offset
        var nowTZ = nowInTZ(tzOff)
        var todayD = nowTZ.getDate()
        var todayM = nowTZ.getMonth()
        var todayY = nowTZ.getFullYear()

        var first = new Date(dispYear, dispMonth, 1)
        var last = new Date(dispYear, dispMonth + 1, 0)
        var daysInMonth = last.getDate()
        var startDow = first.getDay()          // 0=Sun
        var adjStart = (startDow + 6) % 7      // 0=Mon
        var prevLast = new Date(dispYear, dispMonth, 0).getDate()

        var cells = []
        for (var i = adjStart - 1; i >= 0; i--)
            cells.push({ day: prevLast - i, isCur: false, isToday: false })
        for (var d = 1; d <= daysInMonth; d++) {
            cells.push({
                day: d,
                isCur: true,
                isToday: d === todayD && dispMonth === todayM && dispYear === todayY
            })
        }
        var n = 1
        while (cells.length < 42)
            cells.push({ day: n++, isCur: false, isToday: false })
        calendarCells = cells
    }

    // ── Clock tick ──
    function tickClock() {
        var tzOff = timezones[tzIndex].offset
        clockText = fmtTime(nowInTZ(tzOff))
    }

    // ── Navigate months ──
    function prevMonth() {
        dispMonth--
        if (dispMonth < 0) { dispMonth = 11; dispYear-- }
        rebuildCalendar()
    }
    function nextMonth() {
        dispMonth++
        if (dispMonth > 11) { dispMonth = 0; dispYear++ }
        rebuildCalendar()
    }

    // ── Select timezone ──
    function selectTZ(idx) {
        if (idx !== tzIndex) {
            tzIndex = idx
            rebuildCalendar()
            tickClock()
        }
    }

    // ── Escape dismiss (via hyprctl) ──
    onVisibleChanged: {
        if (visible) {
            closeProc.running = true
            // Refresh on open
            rebuildCalendar()
            tickClock()
        } else {
            unbindProc.running = true
        }
    }

    Process {
        id: closeProc
        command: ["hyprctl", "keyword", "bind", "Escape", "exec",
            "sh -c 'echo 0 > /tmp/qs-cal-state'"]
    }
    Process {
        id: unbindProc
        command: ["hyprctl", "keyword", "unbind", "Escape"]
    }
    Process {
        id: bgCloseProc
        // command set dynamically
    }

    // ── Clock tick timer ──
    Timer {
        interval: 1000
        running: popout.shouldShow
        repeat: true
        onTriggered: tickClock()
    }

    // ── Month names ──
    property var monthNames: [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    property var dayHeaders: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    // ── Layout ──
    screen: Quickshell.screens[0]
    anchors { top: true; right: true }
    margins { right: 84 + trayWidth; top: 0 }
    implicitWidth: 303
    implicitHeight: contentCol.implicitHeight + 36
    color: "transparent"
    visible: shouldShow

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
        border.color: popout.border
        border.width: 1

        // Click background to dismiss
        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            onClicked: function(mouse) {
                popout.shouldShow = false
                bgCloseProc.command = ["sh", "-c", "echo 0 > /tmp/qs-cal-state"]
                bgCloseProc.running = true
                mouse.accepted = false
            }
        }
    }

    ColumnLayout {
        id: contentCol
        anchors.fill: parent
        anchors.margins: 16
        spacing: 0

        // ── TIME title ──
        Text {
            text: "TIME"
            font.family: popout.font
            font.pixelSize: 16
            font.bold: true
            font.letterSpacing: 4
            color: popout.cyan
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 10
        }

        // ── Clock ──
        Text {
            text: popout.clockText
            font.family: popout.font
            font.pixelSize: 36
            font.bold: true
            color: popout.silver
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 8
            font.letterSpacing: 1
        }

        // ── TZ carousel ──
        Item {
            id: tzContainer
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            Layout.bottomMargin: 16
            clip: true

            readonly property real slotWidth: width / 7
            readonly property int total: popout.timezones.length

            // 3 copies for seamless circular scrolling
            property var wrappedTZ: {
                var r = []
                for (var i = 0; i < 3; i++)
                    for (var j = 0; j < total; j++)
                        r.push(popout.timezones[j])
                return r
            }

            Row {
                id: tzInner
                y: 0
                height: tzContainer.height
                x: -((popout.tzIndex + tzContainer.total) * tzContainer.slotWidth) + tzContainer.slotWidth * 3

                Behavior on x {
                    SmoothedAnimation { velocity: 400; duration: 200; easing.type: Easing.OutCubic }
                }

                Repeater {
                    model: tzContainer.wrappedTZ

                    delegate: Item {
                        required property int index
                        required property var modelData
                        width: tzContainer.slotWidth
                        height: parent.height

                        readonly property int centerOffset: popout.tzIndex + popout.timezones.length
                        readonly property int dist: Math.abs(index - centerOffset)
                        property bool hovered: false

                        Text {
                            anchors.centerIn: parent
                            text: modelData.name
                            font.family: popout.font
                            font.pixelSize: 12
                            font.weight: index === centerOffset ? Font.Bold : Font.Medium
                            color: {
                                if (hovered) return popout.silver
                                if (index === centerOffset) return popout.cyan
                                if (dist === 1) return popout.silver
                                if (dist === 2) return popout.muted
                                return popout.border
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -4
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: popout.selectTZ(index % popout.timezones.length)
                            onContainsMouseChanged: parent.hovered = containsMouse
                        }
                    }
                }
            }
        }

        // ── Month nav ──
        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 8
            Layout.preferredHeight: 20
            spacing: 12

            Item { Layout.fillWidth: true; Layout.preferredHeight: 1 }

            Text {
                text: "◂"
                font.family: popout.font
                font.pixelSize: 14
                color: mouseA.containsMouse ? popout.cyan : popout.muted
                MouseArea {
                    id: mouseA
                    anchors.fill: parent
                    anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: popout.prevMonth()
                }
            }

            Text {
                text: popout.monthNames[popout.dispMonth] + " " + popout.dispYear
                font.family: popout.font
                font.pixelSize: 16
                font.bold: true
                font.letterSpacing: 2
                color: popout.cyan
                Layout.minimumWidth: 80
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: "▸"
                font.family: popout.font
                font.pixelSize: 14
                color: mouseB.containsMouse ? popout.cyan : popout.muted
                MouseArea {
                    id: mouseB
                    anchors.fill: parent
                    anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: popout.nextMonth()
                }
            }

            Item { Layout.fillWidth: true; Layout.preferredHeight: 1 }
        }

        // ── Day-of-week headers ──
        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 3
            spacing: 0

            Repeater {
                model: popout.dayHeaders
                delegate: Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    font.family: popout.font
                    font.pixelSize: 10
                    font.bold: true
                    color: popout.muted
                }
            }
        }

        // ── Calendar grid ──
        GridLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 4
            columns: 7
            columnSpacing: 0
            rowSpacing: 2

            Repeater {
                model: popout.calendarCells

                delegate: Rectangle {
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    color: modelData.isToday ? popout.cyan : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: modelData.day
                        font.family: popout.font
                        font.pixelSize: modelData.isToday ? 14 : 13
                        font.weight: modelData.isToday ? Font.Bold : Font.Medium
                        color: {
                            if (modelData.isToday) return popout.bg
                            if (modelData.isCur)   return popout.silver
                            return popout.border
                        }
                    }
                }
            }
        }
    }
}
