import QtQuick
import qs.common
import qs.services

// Network, volume and the keyboard layout.
GlassPanel {
    id: root

    signal clicked()

    radius: Theme.barRadius
    implicitWidth: row.implicitWidth + 20

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 12

        Icon {
            name: Net.icon
            size: 18
            filled: true
        }

        Icon {
            name: Audio.icon
            size: 19
            filled: true
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Compositor.layoutShort
            color: Theme.text
            font.family: Theme.font
            font.weight: Font.DemiBold
            font.pixelSize: Theme.textBar
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
        // Scrolling over the pill changes the volume.
        onWheel: (event) => Audio.setVolume(Audio.volume + (event.angleDelta.y > 0 ? 0.05 : -0.05))
    }
}
