import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.common
import qs.services

// One app in the dock: its icon, a dot per running state, and its name on
// hover. Left click focuses (or launches), middle click opens a new window,
// right click closes all of its windows.
Item {
    id: root

    required property var item
    required property var anchorWindow

    readonly property bool running: item.windows.length > 0
    readonly property bool focused: item.windows.indexOf(DockModel.activeWindow) >= 0
    readonly property bool hovered: mouse.containsMouse

    width: Theme.dockIcon
    height: Theme.dockIcon

    IconImage {
        id: icon
        anchors.centerIn: parent
        implicitSize: Theme.dockIcon
        source: root.item.icon
        asynchronous: true
        scale: mouse.pressed ? 0.92 : root.hovered ? 1.12 : 1
        transform: Translate { y: root.hovered ? -3 : 0 }
        Behavior on scale { NumberAnimation { duration: Theme.fast; easing.type: Easing.OutCubic } }
    }

    // Running indicator.
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        anchors.topMargin: 1
        width: root.focused ? 12 : 4
        height: 4
        radius: 2
        color: Theme.text
        opacity: root.running ? (root.focused ? 0.85 : 0.5) : 0
        Behavior on width { NumberAnimation { duration: Theme.normal; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: Theme.normal } }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: (event) => {
            if (event.button === Qt.MiddleButton)
                DockModel.launchNew(root.item);
            else if (event.button === Qt.RightButton)
                root.item.windows.forEach((w) => w.close());
            else
                DockModel.activate(root.item);
        }
    }

    // The name, in a small popup above the icon.
    PopupWindow {
        visible: root.hovered && !mouse.pressed
        anchor.item: root
        anchor.rect.x: root.width / 2 - implicitWidth / 2
        anchor.rect.y: -implicitHeight - 14
        implicitWidth: label.implicitWidth + 20
        implicitHeight: label.implicitHeight + 10
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: Theme.dark ? Qt.rgba(0.1, 0.11, 0.17, 0.82) : Qt.rgba(1, 1, 1, 0.78)
            border.width: 1
            border.color: Theme.glassRim

            Text {
                id: label
                anchors.centerIn: parent
                text: root.item.name
                color: Theme.text
                font.family: Theme.font
                font.weight: Font.Medium
                font.pixelSize: Theme.textSm
            }
        }
    }
}
