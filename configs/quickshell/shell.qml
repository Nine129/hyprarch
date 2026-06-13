//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RENDER_LOOP=threaded

import Quickshell
import Quickshell.Io
import QtQuick
import "services" as QsServices
import "panel"

ShellRoot {
    id: root

    readonly property var audio: QsServices.Audio
    readonly property var power: QsServices.Power
    readonly property var mpris: QsServices.MprisService
    readonly property var notifs: QsServices.NotificationService

    OmniPanel {
        id: omniPanel
    }

    Component.onCompleted: {
        console.log("CGGX QuickShell loaded")
    }
}
