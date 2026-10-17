import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.common
import qs.services

// Time, date and battery.
GlassPanel {
    id: root

    signal clicked()

    readonly property var battery: UPower.displayDevice
    readonly property bool hasBattery: battery && battery.isPresent && battery.isLaptopBattery
    readonly property real level: hasBattery ? Math.max(0, Math.min(1, battery.percentage)) : 1
    readonly property bool charging: hasBattery
        && (battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.FullyCharged)

    radius: Theme.barRadius
    implicitWidth: row.implicitWidth + 24

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 10

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatTime(clock.date, "HH:mm")
            color: Theme.text
            font.family: Theme.font
            font.weight: Font.DemiBold
            font.pixelSize: Theme.textBar
            font.features: ({ "tnum": 1 })
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.locale("en_US").toString(clock.date, "ddd, MMMM d")
            color: Theme.text
            font.family: Theme.font
            font.weight: Font.Medium
            font.pixelSize: Theme.textBar
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.hasBattery
            spacing: 5

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Math.round(root.level * 100) + "%"
                color: Theme.text
                font.family: Theme.font
                font.weight: Font.Medium
                font.pixelSize: Theme.textBar
            }

            // A small battery drawn to the charge level.
            Item {
                anchors.verticalCenter: parent.verticalCenter
                width: 24
                height: 12

                Rectangle {
                    id: shell
                    width: 21
                    height: 12
                    radius: 3.5
                    color: "transparent"
                    border.width: 1.2
                    border.color: Theme.text
                    opacity: 0.85

                    Rectangle {
                        x: 2
                        y: 2
                        height: parent.height - 4
                        width: Math.max(2, (parent.width - 4) * root.level)
                        radius: 1.8
                        color: root.level < 0.15 && !root.charging ? Theme.danger
                             : root.charging ? Theme.success : Theme.text
                    }
                }

                Rectangle {
                    anchors.left: shell.right
                    anchors.leftMargin: 1
                    anchors.verticalCenter: parent.verticalCenter
                    width: 2
                    height: 4
                    radius: 1
                    color: Theme.text
                    opacity: 0.6
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
