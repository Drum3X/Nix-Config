import QtQuick

// A round, borderless button inside glass: an icon, and a wash on hover.
Item {
    id: root

    property string icon: ""
    property real iconSize: 18
    property bool active: false
    property color color: active ? Theme.accent : Theme.text
    readonly property bool hovered: mouse.containsMouse

    signal clicked()
    signal rightClicked()

    implicitWidth: 30
    implicitHeight: 30

    Rectangle {
        anchors.fill: parent
        radius: Math.min(width, height) / 2
        color: mouse.pressed ? Theme.pressed : root.hovered ? Theme.hover : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.fast } }
    }

    Icon {
        anchors.centerIn: parent
        name: root.icon
        size: root.iconSize
        filled: root.active
        color: root.color
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: (event) => event.button === Qt.RightButton ? root.rightClicked() : root.clicked()
    }
}
