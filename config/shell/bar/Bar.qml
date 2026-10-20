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
// Its items are black over a light wallpaper and white over a dark one
// (WallpaperTone), whatever the appearance. A clicked item sits for a moment
// in a capsule of liquid glass, and as long as the panel it opened stays
// open: the dark glass of the panels at the top right, in both appearances.
// Two surfaces with the same geometry, as the dock: the capsule is
// compositor glass ("hyalo-bar-capsule-<screen>"), the bar itself a clear
// layer ("no_blur") above it, so its text and icons never count as part of
// the glass silhouette.
Scope {
    id: root

    required property var modelData

    readonly property bool blackItems: WallpaperTone.blackItems(modelData.name)
    readonly property color itemColor: blackItems ? "#1d1d1f" : "#ffffff"

    readonly property string capsuleNamespace: "hyalo-bar-capsule-" + modelData.name

    // The item the capsule is on: one just clicked, else the one that opened
    // a panel that is still open on this screen.
    readonly property Item litItem: {
        const items = [...leftRow.children, ...rightRow.children].filter((item) => item.visible);
        const opener = (panel) => {
            const candidates = items.filter((item) => item.panel === panel);
            const last = candidates.reduce((best, item) => !best || item.clickedAt > best.clickedAt ? item : best, null);
            // Opened from the keyboard: the panel's own button.
            return last && last.clickedAt > 0 ? last : candidates.find((item) => item.primary) ?? last;
        };
        return items.find((item) => item.flashing)
            ?? (Ui.controlScreen === modelData.name ? opener("control") : null)
            ?? (Ui.launcherScreen === modelData.name ? opener("launcher") : null)
            ?? (Ui.notificationsScreen === modelData.name ? opener("notifications") : null)
            ?? null;
    }
    // Where the capsule last was, so it fades out in place.
    property Item capsuleItem: null
    onLitItemChanged: if (litItem) capsuleItem = litItem

    PanelMotion {
        id: motion
        open: root.litItem !== null
        namespace: root.capsuleNamespace
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
        WlrLayershell.namespace: root.capsuleNamespace
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
            // Moving to another item while shown: slide over to it.
            Behavior on x {
                enabled: motion.fade === 1
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }
            Behavior on width {
                enabled: motion.fade === 1
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }
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
                panel: "launcher"
                primary: true
                onClicked: Ui.toggleLauncher(bar.screen.name, "apps")

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "blur_on"
                    size: 19
                    filled: true
                    color: root.itemColor
                }
            }

            BarItem {
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: bar.appName
                    color: root.itemColor
                    font.family: Theme.font
                    font.styleName: "Bold"
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
                            color: modelData.active ? root.itemColor : "transparent"
                            border.width: 1.2
                            border.color: root.itemColor
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
                    color: root.itemColor
                    font.family: Theme.font
                    font.styleName: "Semibold"
                    font.pixelSize: Theme.textSm
                }
            }

            // Battery, drawn like the macOS one: an outline filled to the charge.
            BarItem {
                visible: bar.hasBattery
                panel: "control"
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
                        border.color: root.itemColor
                        opacity: 0.55
                    }
                    Rectangle {
                        x: 2
                        anchors.verticalCenter: batteryOutline.verticalCenter
                        height: 8
                        width: Math.max(2, 20 * bar.level)
                        radius: 2
                        color: bar.level < 0.15 && !bar.charging ? Theme.danger
                             : bar.battery.state === UPowerDeviceState.Charging ? "#34c759" : root.itemColor
                    }
                    Rectangle {
                        anchors.left: batteryOutline.right
                        anchors.leftMargin: 1
                        anchors.verticalCenter: batteryOutline.verticalCenter
                        width: 1.5
                        height: 4
                        radius: 1
                        color: root.itemColor
                        opacity: 0.55
                    }
                }
            }

            BarItem {
                panel: "control"
                onClicked: Ui.toggleControlMenu(bar.screen.name, "wifi")
                Icon { anchors.verticalCenter: parent.verticalCenter; name: Net.icon; size: 17; filled: true; color: root.itemColor }
            }

            BarItem {
                panel: "control"
                onClicked: Ui.toggleControl(bar.screen.name)
                onWheel: (up) => Audio.setVolume(Audio.volume + (up ? 0.05 : -0.05))
                Icon { anchors.verticalCenter: parent.verticalCenter; name: Audio.icon; size: 18; filled: true; color: root.itemColor }
            }

            // Control Center: the two-switches glyph.
            BarItem {
                panel: "control"
                primary: true
                onClicked: Ui.toggleControl(bar.screen.name)
                Icon { anchors.verticalCenter: parent.verticalCenter; name: "toggle_on"; size: 19; filled: true; color: root.itemColor }
            }

            // The date and time open the Notification Center.
            BarItem {
                panel: "notifications"
                primary: true
                padding: 12
                reachRight: rightRow.anchors.rightMargin
                onClicked: Ui.toggleNotifications(bar.screen.name)

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Qt.locale("en_US").toString(clock.date, "ddd MMM d  HH:mm")
                    color: root.itemColor
                    font.family: Theme.font
                    font.styleName: "Medium"
                    font.pixelSize: Theme.textBar
                    font.features: ({ "tnum": 1 })
                }
            }
        }
    }

    // One menu bar item: its content. The glass capsule is drawn by the Scope,
    // on the surface below the bar.
    component BarItem: Item {
        id: item
        default property alias content: holder.data
        // The panel a click opens ("control", "launcher", "notifications"), if
        // any: the capsule stays on the item while it is open. `primary`: the
        // panel's own button, which takes the capsule when it is opened from
        // the keyboard.
        property string panel: ""
        property bool primary: false
        // When it was last clicked, to tell which item opened the panel.
        property real clickedAt: 0
        // Room on either side of the content, inside the capsule.
        property real padding: 8
        // How far past its right side a click still reaches it: the last item
        // takes the clicks up to the edge of the screen.
        property real reachRight: 0
        // Pressed, and a moment after, so a quick click still shows the capsule.
        readonly property bool flashing: mouse.pressed || flash.running
        signal clicked()
        signal wheel(bool up)

        implicitWidth: holder.childrenRect.width + padding * 2
        implicitHeight: Theme.barHeight - 6
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined

        Item {
            id: holder
            x: item.padding
            width: childrenRect.width
            height: parent.height
        }

        Timer {
            id: flash
            interval: 260
        }

        MouseArea {
            id: mouse
            // Up to the top of the screen, as on macOS: a click on the very
            // edge still lands.
            anchors.fill: parent
            anchors.topMargin: -(Theme.barHeight - item.height) / 2
            anchors.bottomMargin: -(Theme.barHeight - item.height) / 2
            anchors.rightMargin: -item.reachRight
            onReleased: flash.restart()
            onClicked: {
                item.clickedAt = Date.now();
                item.clicked();
            }
            onWheel: (event) => item.wheel(event.angleDelta.y > 0)
        }
    }
}
