import QtQuick
import qs.common

// A row of a Control Center menu: a round icon, white with the icon in the
// accent colour when `active`, the name, then a short `detail` and a lock.
Item {
    id: root

    property string icon: ""
    property string label: ""
    property string detail: ""
    property bool active: false
    property bool locked: false
    signal clicked()

    width: parent ? parent.width : 0
    height: 38

    Rectangle {
        x: 6
        width: parent.width - 12
        height: parent.height
        radius: height / 2
        color: mouse.pressed ? Theme.cc.pressed : mouse.containsMouse ? Theme.cc.hover : Theme.clear
        Behavior on color { ColorAnimation { duration: Theme.fast } }
    }

    Rectangle {
        id: badge
        x: 14
        anchors.verticalCenter: parent.verticalCenter
        width: 28
        height: 28
        radius: 14
        color: root.active ? "#ffffff" : Qt.rgba(1, 1, 1, 0.24)
        Behavior on color { ColorAnimation { duration: Theme.fast } }

        Icon {
            anchors.centerIn: parent
            name: root.icon
            size: 17
            filled: true
            color: root.active ? Theme.cc.accent : "#ffffff"
        }
    }

    CcText {
        anchors.left: badge.right
        anchors.leftMargin: 10
        anchors.right: trailing.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        elide: Text.ElideRight
        font.pixelSize: Theme.textMd
    }

    Row {
        id: trailing
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        CcText {
            anchors.verticalCenter: parent.verticalCenter
            visible: text.length > 0
            text: root.detail
            color: Theme.dark ? Theme.cc.textDim : Theme.cc.textSoft
            font.pixelSize: Theme.textSm
        }
        Icon {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.locked
            name: "lock"
            size: 15
            filled: true
            color: Theme.dark ? Theme.cc.textDim : Theme.cc.textSoft
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
