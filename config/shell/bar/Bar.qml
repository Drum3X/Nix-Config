import QtQuick
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Wayland
import Quickshell.WindowManager
import qs.common
import qs.services

// The menu bar, as on macOS Tahoe: fully transparent, edge to edge. On the
// left the Hyalo mark (opens the launcher), the focused app's name and the
// workspaces; on the right the status icons, the Control Center button and
// the date and time.
PanelWindow {
    id: bar

    required property var modelData
    screen: modelData

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: Theme.barHeight
    exclusiveZone: Theme.barHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    // No glass: the macOS menu bar shows the wallpaper as it is.
    WlrLayershell.namespace: "no_blur"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    readonly property var focused: ToplevelManager.activeToplevel
    readonly property string appName: {
        if (!focused)
            return "Finder";
        const entry = DockModel.lookup(focused.appId);
        return entry ? entry.name : (focused.appId || "");
    }

    readonly property var projection: screen ? WindowManager.screenProjection(screen) : null
    readonly property var workspaces: projection
        ? projection.windowsets.filter((ws) => ws.shouldDisplay || ws.active)
        : []

    readonly property var battery: UPower.displayDevice
    readonly property bool hasBattery: !!(battery && battery.isPresent && battery.isLaptopBattery)
    readonly property real level: hasBattery ? Math.max(0, Math.min(1, battery.percentage)) : 1
    readonly property bool charging: hasBattery
        && (battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.FullyCharged)

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // ----- left ---------------------------------------------------------------
    Row {
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        BarItem {
            onClicked: Ui.toggleLauncher(bar.screen.name, "apps")

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: "blur_on"
                size: 19
                filled: true
            }
        }

        BarItem {
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: bar.appName
                color: Theme.text
                font.family: Theme.font
                font.weight: Font.Bold
                font.pixelSize: Theme.textBar
            }
        }

        // Workspaces, quietly: the current one is a filled dot.
        BarItem {
            visible: bar.workspaces.length > 1

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Repeater {
                    model: bar.workspaces

                    delegate: Rectangle {
                        required property var modelData
                        anchors.verticalCenter: parent.verticalCenter
                        width: 7
                        height: 7
                        radius: 3.5
                        color: modelData.active ? Theme.text : "transparent"
                        border.width: 1.2
                        border.color: Theme.text
                        opacity: modelData.active ? 0.85 : 0.5

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -4
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (modelData.canActivate) modelData.activate()
                        }
                    }
                }
            }
        }
    }

    // ----- right --------------------------------------------------------------
    Row {
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        BarItem {
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Compositor.layoutShort
                color: Theme.text
                font.family: Theme.font
                font.weight: Font.DemiBold
                font.pixelSize: Theme.textSm
            }
        }

        // Battery, drawn like the macOS one: an outline filled to the charge.
        BarItem {
            visible: bar.hasBattery
            onClicked: Ui.toggleControl(bar.screen.name)

            Item {
                anchors.verticalCenter: parent.verticalCenter
                width: 27
                height: 13

                Rectangle {
                    id: batteryOutline
                    width: 24
                    height: 12
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 3.5
                    color: "transparent"
                    border.width: 1
                    border.color: Theme.text
                    opacity: 0.55
                }
                Rectangle {
                    x: 2
                    anchors.verticalCenter: batteryOutline.verticalCenter
                    height: 8
                    width: Math.max(2, 20 * bar.level)
                    radius: 2
                    color: bar.level < 0.15 && !bar.charging ? Theme.danger
                         : bar.battery.state === UPowerDeviceState.Charging ? "#34c759" : Theme.text
                }
                Rectangle {
                    anchors.left: batteryOutline.right
                    anchors.leftMargin: 1
                    anchors.verticalCenter: batteryOutline.verticalCenter
                    width: 1.5
                    height: 4
                    radius: 1
                    color: Theme.text
                    opacity: 0.55
                }
            }
        }

        BarItem {
            onClicked: Ui.toggleControl(bar.screen.name)
            Icon { anchors.verticalCenter: parent.verticalCenter; name: Net.icon; size: 17; filled: true }
        }

        BarItem {
            onClicked: Ui.toggleControl(bar.screen.name)
            onWheel: (up) => Audio.setVolume(Audio.volume + (up ? 0.05 : -0.05))
            Icon { anchors.verticalCenter: parent.verticalCenter; name: Audio.icon; size: 18; filled: true }
        }

        // Control Center: the two-switches glyph.
        BarItem {
            active: Ui.controlScreen === bar.screen.name
            onClicked: Ui.toggleControl(bar.screen.name)
            Icon { anchors.verticalCenter: parent.verticalCenter; name: "toggle_on"; size: 19; filled: true }
        }

        BarItem {
            onClicked: Ui.toggleControl(bar.screen.name)

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Qt.locale("en_US").toString(clock.date, "ddd MMM d  HH:mm")
                color: Theme.text
                font.family: Theme.font
                font.weight: Font.Medium
                font.pixelSize: Theme.textBar
                font.features: ({ "tnum": 1 })
            }
        }
    }

    // One menu bar item: its content, with the rounded highlight macOS shows
    // under the pointer and while open.
    component BarItem: Item {
        id: item
        default property alias content: holder.data
        property bool active: false
        signal clicked()
        signal wheel(bool up)

        implicitWidth: holder.childrenRect.width + 16
        implicitHeight: Theme.barHeight - 6
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined

        Rectangle {
            anchors.fill: parent
            radius: 6
            color: item.active || mouse.pressed
                ? (Theme.dark ? Qt.rgba(1, 1, 1, 0.22) : Qt.rgba(0, 0, 0, 0.12))
                : mouse.containsMouse ? (Theme.dark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.06)) : "transparent"
        }

        Item {
            id: holder
            x: 8
            width: childrenRect.width
            height: parent.height
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: item.clicked()
            onWheel: (event) => item.wheel(event.angleDelta.y > 0)
        }
    }
}
