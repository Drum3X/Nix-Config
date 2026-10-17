import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.services

// The top bar: three islands of glass on one layer surface.
//   left    network, volume, keyboard layout  -> opens the control center
//   center  workspaces and the focused window
//   right   clock, date, battery              -> opens the control center
PanelWindow {
    id: bar

    required property var modelData
    screen: modelData

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: Theme.edge + Theme.barHeight + 8
    exclusiveZone: Theme.barExclusive
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "hyalo-bar"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Only the islands take the pointer (and only they are processed as glass).
    mask: Region {
        item: left
        Region { item: center }
        Region { item: right }
    }

    StatusPill {
        id: left
        x: Theme.edge + 2
        y: Theme.edge
        height: Theme.barHeight
        onClicked: Ui.toggleControl(bar.screen.name)
    }

    WorkspacePill {
        id: center
        anchors.horizontalCenter: parent.horizontalCenter
        y: Theme.edge
        height: Theme.barHeight
        screen: bar.screen
    }

    ClockPill {
        id: right
        anchors.right: parent.right
        anchors.rightMargin: Theme.edge + 2
        y: Theme.edge
        height: Theme.barHeight
        onClicked: Ui.toggleControl(bar.screen.name)
    }
}
