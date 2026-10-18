import QtQuick

// One module of the control center: a rounded block of faint material on
// the glass, holding a group of controls. `title` adds a small heading.
Item {
    id: root

    property string title: ""
    property real padding: 12
    default property alias content: body.data

    implicitHeight: (title.length > 0 ? heading.implicitHeight + 8 : 0) + body.childrenRect.height + padding * 2

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: Theme.module
    }

    Text {
        id: heading
        visible: root.title.length > 0
        x: root.padding
        y: root.padding
        text: root.title
        color: Theme.text
        font.family: Theme.font
        font.weight: Font.DemiBold
        font.pixelSize: Theme.textSm
    }

    Item {
        id: body
        x: root.padding
        y: root.padding + (root.title.length > 0 ? heading.implicitHeight + 8 : 0)
        width: root.width - root.padding * 2
        height: childrenRect.height
    }
}
