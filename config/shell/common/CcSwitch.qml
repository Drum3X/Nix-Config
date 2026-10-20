import QtQuick

// A macOS switch on the Control Center's dark glass: the accent track when
// on, with a white capsule knob that slides across.
Item {
    id: root

    property bool checked: false
    signal toggled()

    implicitWidth: 46
    implicitHeight: 24

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Theme.cc.accent : Theme.cc.buttonOff
        Behavior on color { ColorAnimation { duration: Theme.fast } }
    }

    Rectangle {
        y: 2
        x: root.checked ? parent.width - width - 2 : 2
        width: 26
        height: parent.height - 4
        radius: height / 2
        color: mouse.pressed ? Theme.whitePressed : "#ffffff"
        Behavior on x { NumberAnimation { duration: Theme.fast; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
