import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.common
import qs.services

// The dock: one pill of glass along the bottom edge. Pinned apps, then the
// rest of what is running, then the trash.
PanelWindow {
    id: dock

    required property var modelData
    screen: modelData

    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    // Room above the pill for the hover lift.
    implicitHeight: Theme.dockHeight + Theme.edge + 16
    exclusiveZone: Theme.dockHeight + Theme.edge + 4
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "hyalo-dock"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    mask: Region { item: pill }

    GlassPanel {
        id: pill
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.edge
        height: Theme.dockHeight
        width: row.implicitWidth + Theme.dockPad * 2
        radius: Theme.dockRadius

        Behavior on width { NumberAnimation { duration: Theme.normal; easing.type: Easing.OutCubic } }

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 6

            Repeater {
                model: DockModel.items

                delegate: DockItem {
                    required property var modelData
                    item: modelData
                    anchorWindow: dock
                }
            }

            // Divider.
            Item {
                width: 13
                height: Theme.dockIcon

                Rectangle {
                    anchors.centerIn: parent
                    width: 1
                    height: parent.height - 12
                    color: Theme.text
                    opacity: 0.18
                }
            }

            // Trash.
            Item {
                width: Theme.dockIcon
                height: Theme.dockIcon

                Rectangle {
                    anchors.fill: parent
                    radius: 11
                    color: trashMouse.containsMouse ? Theme.hover : "transparent"
                }

                IconImage {
                    anchors.centerIn: parent
                    implicitSize: Theme.dockIcon - 4
                    source: Quickshell.iconPath("user-trash", "user-trash-full")
                    scale: trashMouse.containsMouse ? 1.08 : 1
                    Behavior on scale { NumberAnimation { duration: Theme.fast } }
                }

                MouseArea {
                    id: trashMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Quickshell.execDetached(["nautilus", "trash:///"])
                }
            }
        }
    }
}
