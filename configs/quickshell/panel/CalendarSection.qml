import QtQuick
import QtQuick.Layouts

// ═══════════════════════════════════════════════════════════════
// Calendar Section — cyan zone
// ═══════════════════════════════════════════════════════════════
Item {
    id: root

    readonly property color cyan:    "#00e5ff"
    readonly property color silver:  "#e8e8f0"
    readonly property color muted:   "#6a6a80"
    readonly property color border:  "#2a2a35"
    readonly property color surface: "#151518"

    implicitHeight: frame.height
    height: implicitHeight
    width: parent.width

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
        { name: "NZT", offset: 12 }
    ]
    property int dispYear:  new Date().getFullYear()
    property int dispMonth: new Date().getMonth()
    property string clockText: "00:00:00"
    property var calendarCells: []

    property var monthNames: [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    property var dayHeaders: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

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

    function tickClock() {
        var tzOff = timezones[tzIndex].offset
        clockText = fmtTime(nowInTZ(tzOff))
    }

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

    function selectTZ(idx) {
        if (idx !== tzIndex) {
            tzIndex = idx
            rebuildCalendar()
            tickClock()
        }
    }

    Component.onCompleted: {
        rebuildCalendar()
        tickClock()
    }

    // ── Clock tick timer ──
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: tickClock()
    }

    Frame {
        id: frame
        zone: "cyan"
        bodyPad: -30
        bodyHeight: content.implicitHeight

        ColumnLayout {
            id: content
            width: parent.width
            height: implicitHeight
            spacing: 0

            // ─ Clock ──
            Text {
                Layout.fillWidth: true
                text: clockText
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 42
                font.bold: true
                color: silver
                horizontalAlignment: Text.AlignHCenter
                font.letterSpacing: 1
                Layout.bottomMargin: 10
                Layout.topMargin: 16
            }

            // ── Timezone carousel ──
            Item {
                id: tzContainer
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                Layout.bottomMargin: 12
                clip: true

                readonly property real slotWidth: width / 7
                readonly property int total: root.timezones.length

                property var wrappedTZ: {
                    var r = []
                    for (var i = 0; i < 3; i++)
                        for (var j = 0; j < total; j++)
                            r.push(root.timezones[j])
                    return r
                }

                // Fade edges
                Rectangle {
                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                    width: 50
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: surface }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                Rectangle {
                    anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                    width: 50
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 1.0; color: surface }
                    }
                }

                Row {
                    id: tzInner
                    y: 0
                    height: parent.height
                    x: -((root.tzIndex + tzContainer.total) * tzContainer.slotWidth) + tzContainer.slotWidth * 3

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

                            readonly property int centerOffset: root.tzIndex + root.timezones.length
                            readonly property int dist: Math.abs(index - centerOffset)
                            property bool hovered: false

                            Text {
                                anchors.centerIn: parent
                                text: modelData.name
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.weight: index === parent.centerOffset ? Font.Bold : Font.Medium
                                color: {
                                    if (parent.hovered) return silver
                                    if (index === parent.centerOffset) return cyan
                                    if (parent.dist === 1) return silver
                                    if (parent.dist === 2) return muted
                                    return border
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -4
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: root.selectTZ(index % root.timezones.length)
                                onContainsMouseChanged: parent.hovered = containsMouse
                            }
                        }
                    }
                }
            }

            // ── Month nav ──
            RowLayout {
                Layout.fillWidth: true
                Layout.bottomMargin: 10
                Layout.preferredHeight: 20
                spacing: 12

                Item { Layout.fillWidth: true; Layout.preferredHeight: 1 }

                Text {
                    text: "◂"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    color: mouseA.containsMouse ? cyan : muted

                    MouseArea {
                        id: mouseA
                        anchors.fill: parent
                        anchors.margins: -4
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: root.prevMonth()
                    }
                }

                Text {
                    text: root.monthNames[root.dispMonth] + " " + root.dispYear
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 15
                    font.bold: true
                    font.letterSpacing: 1
                    color: cyan
                    Layout.minimumWidth: 80
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    text: "▸"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    color: mouseB.containsMouse ? cyan : muted

                    MouseArea {
                        id: mouseB
                        anchors.fill: parent
                        anchors.margins: -4
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: root.nextMonth()
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
                    model: root.dayHeaders

                    delegate: Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 9
                        font.bold: true
                        color: muted
                    }
                }
            }

            // ── Calendar grid ──
            GridLayout {
                Layout.fillWidth: true
                columns: 7
                columnSpacing: 3
                rowSpacing: 3

                Repeater {
                    model: root.calendarCells

                    delegate: Rectangle {
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        color: modelData.isToday ? cyan : modelData.isCur ? "transparent" : "transparent"
                    visible: modelData.isCur || modelData.isToday

                        Text {
                            anchors.centerIn: parent
                            text: modelData.day
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: modelData.isToday ? 14 : 11
                            font.weight: modelData.isToday ? Font.Bold : Font.Medium
                            color: {
                                if (modelData.isToday) return surface
                                if (modelData.isCur)   return silver
                                return muted
                            }
                        }
                    }
                }
            }
        }
    }
}
