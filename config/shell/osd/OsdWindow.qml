import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.services

// Volume / brightness, shown for a moment under the menu bar when they change.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData
    visible: Osd.shown || pill.opacity > 0

    anchors.top: true
    anchors.right: true
    // Under the menu bar on the right, where macOS Tahoe shows it.
    margins.top: Theme.barExclusive - 2
    margins.right: Theme.edge
    implicitWidth: 260
    implicitHeight: 48
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "hyalo-osd"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // The glass is applied only inside the input region.
    mask: Region { item: pill }

    GlassPanel {
        id: pill
        anchors.fill: parent
        radius: height / 2
        opacity: Osd.shown ? 1 : 0
        scale: Osd.shown ? 1 : 0.92
        Behavior on opacity { NumberAnimation { duration: Theme.normal; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: Theme.normal; easing.type: Easing.OutCubic } }

        Icon {
            id: icon
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            name: Osd.icon
            size: 20
            filled: true
        }

        Rectangle {
            id: track
            anchors.left: icon.right
            anchors.leftMargin: 12
            anchors.right: percent.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            height: 6
            radius: 3
            color: Theme.hover

            Rectangle {
                width: track.width * Math.max(0, Math.min(1, Osd.value))
                height: parent.height
                radius: 3
                color: Theme.text
                Behavior on width { NumberAnimation { duration: Theme.fast; easing.type: Easing.OutCubic } }
            }
        }

        Text {
            id: percent
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            width: 32
            horizontalAlignment: Text.AlignRight
            text: Math.round(Osd.value * 100)
            color: Theme.text
            font.family: Theme.font
            font.weight: Font.DemiBold
            font.pixelSize: Theme.textSm
            font.features: ({ "tnum": 1 })
        }
    }
}
