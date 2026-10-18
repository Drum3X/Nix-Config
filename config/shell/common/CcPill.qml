import QtQuick

// A wide macOS Control Center control (Wi-Fi, Focus), its own capsule of
// glass: a round button, white when on, then a title and a status line.
// The button toggles; the text opens details when `expandable`.
Item {
    id: root

    property string icon: ""
    property string label: ""
    property string detail: ""
    property bool checked: false
    property bool expandable: false

    signal toggled()
    signal detailsRequested()

    implicitWidth: Theme.ccUnit * 2 + Theme.ccGap
    implicitHeight: Theme.ccUnit

    GlassPanel {
        anchors.fill: parent
        radius: height / 2

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: textMouse.containsMouse && root.expandable ? Theme.hover : "transparent"
            Behavior on color { ColorAnimation { duration: Theme.fast } }
        }

        Rectangle {
            id: button
            x: 8
            anchors.verticalCenter: parent.verticalCenter
            width: parent.height - 16
            height: width
            radius: width / 2
            color: root.checked ? "#ffffff" : Theme.buttonOff
            scale: buttonMouse.pressed ? 0.92 : 1
            Behavior on color { ColorAnimation { duration: Theme.normal } }
            Behavior on scale { NumberAnimation { duration: Theme.fast } }

            Icon {
                anchors.centerIn: parent
                name: root.icon
                size: 24
                filled: true
                color: root.checked ? Theme.accent : Theme.text
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
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter

            Text {
                width: parent.width
                text: root.label
                elide: Text.ElideRight
                color: Theme.text
                font.family: Theme.font
                font.weight: Font.DemiBold
                font.pixelSize: Theme.textMd
            }
            Text {
                width: parent.width
                visible: text.length > 0
                text: root.detail
                elide: Text.ElideRight
                color: Theme.textDim
                font.family: Theme.font
                font.pixelSize: Theme.textSm
            }
        }

        MouseArea {
            id: textMouse
            anchors.left: button.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            enabled: root.expandable
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.detailsRequested()
        }
    }
}
