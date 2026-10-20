import QtQuick
import qs.common

// A menu a Control Center capsule grows into (Wi-Fi, Bluetooth), laid out as
// macOS lays them out: the title with a switch, then sections of rows.
// `scanning` says whether it is open, for the menu to look for what it lists.
Column {
    id: root

    property string title: ""
    property bool checked: false
    property bool scanning: false
    signal toggled()

    bottomPadding: 8

    Item {
        width: parent.width
        height: 48

        CcText {
            x: 16
            anchors.verticalCenter: parent.verticalCenter
            text: root.title
            font.styleName: "Semibold"
            font.pixelSize: Theme.textLg
        }

        CcSwitch {
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            checked: root.checked
            onToggled: root.toggled()
        }
    }
}
