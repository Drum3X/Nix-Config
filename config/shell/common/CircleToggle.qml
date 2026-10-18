import QtQuick

// A macOS Control Center row: a round button (blue when on), a title and a
// status line. Clicking the circle toggles; clicking the text opens details
// when `expandable`.
Item {
    id: root

    property string icon: ""
    property string label: ""
    property string detail: ""
    property bool checked: false
    property bool expandable: false
    property real circle: 30

    signal toggled()
    signal detailsRequested()

    implicitHeight: Math.max(circle, texts.implicitHeight)

    Rectangle {
        id: button
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: root.circle
        height: root.circle
        radius: width / 2
        color: root.checked ? Theme.accent : Theme.buttonOff
        border.width: root.checked ? 0 : 1
        border.color: Theme.line
        scale: buttonMouse.pressed ? 0.92 : 1
        Behavior on color { ColorAnimation { duration: Theme.normal } }
        Behavior on scale { NumberAnimation { duration: Theme.fast } }

        Icon {
            anchors.centerIn: parent
            name: root.icon
            size: root.circle * 0.55
            filled: true
            color: root.checked ? "#ffffff" : Theme.text
        }

        MouseArea {
            id: buttonMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggled()
        }
    }

    Column {
        id: texts
        anchors.left: button.right
        anchors.leftMargin: 9
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        Text {
            width: parent.width
            text: root.label
            elide: Text.ElideRight
            color: Theme.text
            font.family: Theme.font
            font.weight: Font.DemiBold
            font.pixelSize: Theme.textSm
        }

        Text {
            width: parent.width
            visible: text.length > 0
            text: root.detail
            elide: Text.ElideRight
            color: Theme.textDim
            font.family: Theme.font
            font.pixelSize: Theme.textXs
        }
    }

    MouseArea {
        anchors.fill: texts
        enabled: root.expandable
        cursorShape: Qt.PointingHandCursor
        onClicked: root.detailsRequested()
    }
}
