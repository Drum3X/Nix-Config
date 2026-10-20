import QtQuick
import qs.common

// A section of a Control Center menu: a line across, then its heading. An
// `expandable` one opens and closes the rows under it, with a chevron.
Item {
    id: root

    property string text: ""
    property bool expandable: false
    property bool expanded: false
    signal clicked()

    width: parent ? parent.width : 0
    height: 36

    Rectangle {
        x: 16
        width: parent.width - 32
        height: 1
        color: Qt.rgba(1, 1, 1, 0.14)
    }

    Rectangle {
        x: 6
        y: 3
        width: parent.width - 12
        height: parent.height - 3
        radius: height / 2
        visible: root.expandable
        color: mouse.pressed ? Theme.cc.pressed : mouse.containsMouse ? Theme.cc.hover : Theme.clear
        Behavior on color { ColorAnimation { duration: Theme.fast } }
    }

    CcText {
        x: 16
        y: 2
        height: parent.height - 2
        verticalAlignment: Text.AlignVCenter
        text: root.text
        color: Theme.dark ? Theme.cc.textDim : Theme.cc.textSoft
        font.styleName: "Semibold"
        font.pixelSize: Theme.textMd
    }

    Icon {
        anchors.right: parent.right
        anchors.rightMargin: 14
        y: 2
        height: parent.height - 2
        visible: root.expandable
        name: "chevron_right"
        size: 20
        color: Theme.dark ? Theme.cc.textDim : Theme.cc.textSoft
        rotation: root.expanded ? 90 : 0
        Behavior on rotation { NumberAnimation { duration: Theme.fast; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.expandable
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
