import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.services

// The Notification Center, as on macOS (without the widgets): under the
// clock, every notification on its own glass, newest first, and a round
// button under them that clears them all. It slides in from the right edge
// of the screen and back out to it; a notification swiped to the right is
// dismissed. Dark glass in both appearances, as the Control Center. Opened
// from the clock in the menu bar.
Scope {
    id: root

    required property var modelData
    readonly property bool open: Ui.notificationsScreen === modelData.name

    ClickCatcher {
        screen: root.modelData
        active: root.open
        onDismissed: Ui.notificationsScreen = ""
    }

    PanelWindow {
        id: window
        screen: root.modelData

        // 1 in place, 0 beyond the right edge of the screen; as the banners
        // (NotificationBanner), it overshoots a little on the way in.
        property real slide: 0
        Behavior on slide {
            NumberAnimation {
                duration: root.open ? Theme.slideIn : Theme.slideOut
                easing.type: root.open ? Easing.OutBack : Easing.InCubic
                easing.overshoot: Theme.slideOvershoot
            }
        }
        visible: root.open || slide > 0

        Connections {
            target: root
            function onOpenChanged(): void {
                window.slide = root.open ? 1 : 0;
                if (root.open)
                    list.contentY = 0;
            }
        }

        // Up to the screen edge, so the panel slides in from beyond it.
        anchors.top: true
        anchors.right: true
        margins.top: Theme.barExclusive
        implicitWidth: Theme.slideRoom + Theme.notificationWidth + Theme.edge
        implicitHeight: Math.max(1, Math.min(screen.height - Theme.barExclusive - Theme.dockHeight - Theme.edge * 3,
                                             content.implicitHeight))
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "hyalo-notification-center"
        WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        mask: Region { item: content }

        Item {
            id: content
            x: Theme.slideRoom + (1 - window.slide) * (Theme.notificationWidth + Theme.edge + 24)
            width: Theme.notificationWidth
            height: window.height
            implicitHeight: column.implicitHeight

            focus: root.open
            Keys.onEscapePressed: Ui.notificationsScreen = ""

            Flickable {
                id: list
                anchors.fill: parent
                contentHeight: column.implicitHeight
                interactive: contentHeight > height
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                Column {
                    id: column
                    width: parent.width
                    spacing: 8

                    move: Transition {
                        NumberAnimation { properties: "y"; duration: 220; easing.type: Easing.OutCubic }
                    }

                    Repeater {
                        // Newest first; the cards already shown stay when one goes.
                        model: ScriptModel { values: Notifs.list.slice().reverse() }

                        delegate: NotificationBanner {
                            id: banner
                            required property var modelData
                            notification: modelData
                            width: column.width
                            // In place when the panel opens (the panel slides);
                            // one that arrives while it is open slides in.
                            slideIn: window.slide === 1
                            onGone: banner.modelData.dismiss()
                        }
                    }

                    // Nothing to show.
                    GlassPanel {
                        visible: Notifs.count === 0
                        width: parent.width
                        height: 52
                        radius: height / 2

                        CcText {
                            anchors.centerIn: parent
                            text: "No Notifications"
                            color: Theme.cc.textSoft
                            font.family: Theme.font
                            font.weight: Font.Medium
                            font.pixelSize: Theme.textMd
                        }
                    }

                    // Clear all: a round button under the list, as macOS has
                    // next to Edit Widgets.
                    Item {
                        visible: Notifs.count > 0
                        width: parent.width
                        height: 40 + 4

                        GlassPanel {
                            id: clearAll
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            width: 40
                            height: 40
                            radius: 20
                            squeeze: clearMouse.pressed ? 0.92 : 1
                            Behavior on squeeze { NumberAnimation { duration: Theme.fast; easing.type: Easing.OutCubic } }

                            Rectangle {
                                anchors.fill: parent
                                radius: clearAll.radius
                                color: clearMouse.containsMouse ? Theme.cc.hover : Theme.clear
                                Behavior on color { ColorAnimation { duration: Theme.fast } }
                            }

                            Icon {
                                anchors.centerIn: parent
                                name: "close"
                                size: 18
                                color: Theme.cc.text
                            }

                            MouseArea {
                                id: clearMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Notifs.clearAll()
                            }
                        }
                    }
                }
            }
        }
    }
}
