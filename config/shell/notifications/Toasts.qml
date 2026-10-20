import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import qs.common
import qs.services

// New notifications as macOS banners, stacked under the right end of the
// bar. Each slides in from the right edge and back out after its timeout
// (5 s by default, never for critical ones); hovering holds it. Swiped away
// or timed out, it stays in the Notification Center; its close button
// dismisses it altogether. Hidden while the Notification Center or the
// Control Center is open on this screen.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData
    visible: Notifs.toasts.length > 0
        && Ui.controlScreen !== modelData.name
        && Ui.notificationsScreen !== modelData.name

    // Up to the screen edge, so a banner slides in from beyond it.
    anchors.top: true
    anchors.right: true
    margins.top: Theme.barExclusive - 2
    implicitWidth: Theme.notificationWidth + Theme.edge
    implicitHeight: Math.max(1, stack.implicitHeight)
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "hyalo-notify"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    mask: Region { item: stack }

    Column {
        id: stack
        width: Theme.notificationWidth
        spacing: 8

        move: Transition {
            NumberAnimation { properties: "y"; duration: 220; easing.type: Easing.OutCubic }
        }

        Repeater {
            // Keeps the banners already shown when one comes or goes.
            model: ScriptModel { values: Notifs.toasts }

            delegate: NotificationBanner {
                id: banner
                required property var modelData
                notification: modelData
                width: stack.width

                onGone: (reason) => {
                    if (reason === "close" || reason === "activate")
                        banner.modelData.dismiss();
                    Notifs.dismissToast(banner.modelData);
                }

                Timer {
                    interval: banner.modelData.expireTimeout > 0 ? banner.modelData.expireTimeout : 5000
                    running: banner.modelData.urgency !== NotificationUrgency.Critical && !banner.hovered
                    onTriggered: banner.leave("timeout")
                }
            }
        }
    }
}
