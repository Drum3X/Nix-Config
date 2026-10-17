import QtQuick

// A control center tile: icon, label and a detail line; filled with the
// accent while on. The chevron (when `expandable`) opens its details.
Item {
    id: root

    property string icon: ""
    property string label: ""
    property string detail: ""
    property bool checked: false
    property bool expandable: false
    property bool expanded: false

    signal toggled()
    signal expandRequested()

    implicitHeight: 58

    Rectangle {
        anchors.fill: parent
        radius: Theme.tileRadius
        color: root.checked ? Theme.accent : mouse.containsMouse ? Theme.pressed : Theme.hover
        Behavior on color { ColorAnimation { duration: Theme.normal } }
    }

    Rectangle {
        id: badge
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: 36
        height: 36
        radius: 18
        color: root.checked ? Qt.rgba(1, 1, 1, 0.22) : Theme.hover

        Icon {
            anchors.centerIn: parent
            name: root.icon
            size: 20
            filled: root.checked
            color: root.checked ? Theme.accentText : Theme.text
        }
    }

    Column {
        anchors.left: badge.right
        anchors.leftMargin: 10
        anchors.right: chevron.visible ? chevron.left : parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1

        Text {
            width: parent.width
            text: root.label
            elide: Text.ElideRight
            color: root.checked ? Theme.accentText : Theme.text
            font.family: Theme.font
            font.weight: Font.DemiBold
            font.pixelSize: Theme.textMd
        }

        Text {
            width: parent.width
            visible: text.length > 0
            text: root.detail
            elide: Text.ElideRight
            color: root.checked ? Qt.rgba(1, 1, 1, 0.82) : Theme.textDim
            font.family: Theme.font
            font.pixelSize: Theme.textXs
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }

    IconButton {
        id: chevron
        visible: root.expandable
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        width: 28
        height: 28
        icon: root.expanded ? "expand_less" : "chevron_right"
        color: root.checked ? Theme.accentText : Theme.textDim
        onClicked: root.expandRequested()
    }
}
