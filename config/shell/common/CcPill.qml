import QtQuick

// A wide macOS Control Center control (Wi-Fi, Focus), its own capsule of
// glass: a round button, white when on, then a title and a status line.
// The button toggles; the rest of the capsule opens details when
// `expandable`, and otherwise toggles too.
Item {
    id: root

    property string icon: ""
    property string label: ""
    property string detail: ""
    property bool checked: false
    property bool expandable: false

    property real reveal: 1
    signal toggled()
    signal detailsRequested()

    implicitWidth: Theme.ccUnit * 2 + Theme.ccGap
    implicitHeight: Theme.ccUnit

    GlassPanel {
        anchors.fill: parent
        reveal: root.reveal
        radius: height / 2

        // The capsule's own wash, for the text side.
        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: pillMouse.pressed ? Theme.cc.pressed : pillMouse.containsMouse ? Theme.cc.hover : Theme.clear
            Behavior on color { ColorAnimation { duration: Theme.fast } }
        }

        Rectangle {
            id: button
            x: 8
            anchors.verticalCenter: parent.verticalCenter
            width: parent.height - 16
            height: width
            radius: width / 2
            color: root.checked
                ? (buttonMouse.pressed ? Theme.whitePressed : buttonMouse.containsMouse ? Theme.whiteHover : "#ffffff")
                : Qt.rgba(1, 1, 1, Theme.cc.buttonOff.a + (buttonMouse.pressed ? 0.16 : buttonMouse.containsMouse ? 0.08 : 0))
            scale: buttonMouse.pressed ? 0.94 : 1
            Behavior on color { ColorAnimation { duration: Theme.fast } }
            Behavior on scale { NumberAnimation { duration: Theme.fast; easing.type: Easing.OutCubic } }

            Icon {
                anchors.centerIn: parent
                name: root.icon
                size: 27
                filled: true
                color: root.checked ? Theme.cc.accent : Theme.cc.text
            }
        }

        Column {
            anchors.left: button.right
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter

            Text {
                width: parent.width
                text: root.label
                elide: Text.ElideRight
                color: Theme.cc.text
                font.family: Theme.font
                font.weight: Font.DemiBold
                font.pixelSize: Theme.textMd
            }
            Text {
                width: parent.width
                visible: text.length > 0
                text: root.detail
                elide: Text.ElideRight
                color: Theme.cc.textDim
                font.family: Theme.font
                font.pixelSize: Theme.textSm
            }
        }

        MouseArea {
            id: pillMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expandable ? root.detailsRequested() : root.toggled()
        }

        // Above the capsule's area, so the button gets its own hover.
        MouseArea {
            id: buttonMouse
            anchors.fill: button
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggled()
        }
    }
}
