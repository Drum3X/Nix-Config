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
//
// Under the pointer, and while it is open, an item sits in a capsule of
// liquid glass that slides from item to item. Two surfaces with the same
// geometry, as the dock: the capsule is compositor glass ("hyalo-bar-hover"),
// the bar itself a clear layer ("no_blur") above it, so its text and icons
// never count as part of the glass silhouette.
Scope {
    id: root

    required property var modelData

    // The item the capsule is on: the one under the pointer, else an open one.
    readonly property Item litItem: {
        const items = [...leftRow.children, ...rightRow.children];
        return items.find((item) => item.visible && item.hovered)
            ?? items.find((item) => item.visible && item.active)
            ?? null;
    }
    // Where the capsule last was, so it fades out in place.
    property Item capsuleItem: null
    onLitItemChanged: if (litItem) capsuleItem = litItem

    PanelMotion {
        id: motion
        open: root.litItem !== null
        namespace: "hyalo-bar-hover"
    }

    // ----- the glass capsule ----------------------------------------------------
    PanelWindow {
        screen: root.modelData

        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: Theme.barHeight
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "hyalo-bar-hover"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        // ShojiWM applies the glass only inside the input region; the bar
        // above still gets the clicks first.
        mask: Region { item: capsule }

        GlassPanel {
            id: capsule
            readonly property Item target: root.capsuleItem
            visible: motion.shown && target !== null
            x: target ? target.parent.x + target.x : 0
            y: target ? target.parent.y + target.y : 0
            width: target ? target.width : 0
            height: target ? target.height : 0
            radius: height / 2
            squeeze: target && target.pressed ? 0.94 : 1
            // Moving to another item while shown: slide over to it.
            Behavior on x {
                enabled: motion.fade === 1
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }
            Behavior on width {
                enabled: motion.fade === 1
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }
            Behavior on squeeze { NumberAnimation { duration: Theme.fast; easing.type: Easing.OutCubic } }
        }
    }

    // ----- the bar --------------------------------------------------------------
    PanelWindow {
        id: bar
        screen: root.modelData

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

        // ----- left -------------------------------------------------------------
        Row {
            id: leftRow
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

        // ----- right ------------------------------------------------------------
        Row {
            id: rightRow
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
    }

    // One menu bar item: its content. The glass capsule under the pointer and
    // while open is drawn by the Scope, on the surface below the bar.
    component BarItem: Item {
        id: item
        default property alias content: holder.data
        property bool active: false
        readonly property bool hovered: mouse.containsMouse
        readonly property bool pressed: mouse.pressed
        signal clicked()
        signal wheel(bool up)

        implicitWidth: holder.childrenRect.width + 16
        implicitHeight: Theme.barHeight - 6
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined

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
