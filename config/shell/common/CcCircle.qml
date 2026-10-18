import QtQuick

// A round macOS Control Center control, its own piece of glass. On, it fills
// white with the icon in the accent colour; off, it is only glass. `label`
// adds a short text under the icon (the battery); `alert` turns it red.
Item {
    id: root

    property string icon: ""
    property string label: ""
    property bool checked: false
    property bool alert: false
    property bool interactive: true
    property real reveal: 1
    property color iconColor: root.alert ? "#ffffff" : root.checked ? Theme.cc.accent : Theme.cc.text

    signal clicked()

    implicitWidth: Theme.ccUnit
    implicitHeight: Theme.ccUnit

    GlassPanel {
        anchors.fill: parent
        radius: width / 2
        reveal: root.reveal
        squeeze: mouse.pressed ? 0.94 : 1
        Behavior on squeeze { NumberAnimation { duration: Theme.fast; easing.type: Easing.OutCubic } }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: root.alert ? Qt.lighter(Theme.cc.danger, mouse.containsMouse ? 1.08 : 1)
                : root.checked ? (mouse.pressed ? Theme.whitePressed : mouse.containsMouse ? Theme.whiteHover : "#ffffff")
                : mouse.pressed ? Theme.cc.pressed : mouse.containsMouse ? Theme.cc.hover : Theme.clear
            Behavior on color { ColorAnimation { duration: Theme.fast } }
        }

        Column {
            anchors.centerIn: parent
            spacing: -2

            Icon {
                anchors.horizontalCenter: parent.horizontalCenter
                name: root.icon
                size: root.label.length > 0 ? 25 : 30
                filled: true
                color: root.iconColor
            }
            CcText {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: root.label.length > 0
                text: root.label
                color: Theme.cc.text
                font.family: Theme.font
                font.weight: Font.DemiBold
                font.pixelSize: Theme.textXs
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
