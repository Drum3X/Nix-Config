import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import qs.common
import qs.services

// New notifications, stacked under the right end of the bar. Each one leaves
// after its timeout (5 s by default, never for critical ones); hovering
// holds it. Hidden while the control center is open on this screen, which
// lists the same notifications.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData
    visible: Notifs.toasts.length > 0 && Ui.controlScreen !== modelData.name

    anchors.top: true
    anchors.right: true
    margins.top: Theme.barExclusive - 2
    margins.right: Theme.edge
    implicitWidth: 360
    implicitHeight: Math.max(1, stack.implicitHeight)
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "hyalo-notify"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    mask: Region { item: stack }

    Column {
        id: stack
        width: parent.width
        spacing: 8

        Repeater {
            model: Notifs.toasts

            delegate: GlassPanel {
                id: toast
                required property var modelData
                width: stack.width
                height: card.implicitHeight
                radius: Theme.tileRadius + 4

                NotificationCard {
                    id: card
                    anchors.fill: parent
                    notification: toast.modelData
                    onDismissed: Notifs.dismissToast(toast.modelData)
                }

                Timer {
                    interval: toast.modelData.expireTimeout > 0 ? toast.modelData.expireTimeout : 5000
                    running: toast.modelData.urgency !== NotificationUrgency.Critical && !card.hovered
                    onTriggered: Notifs.dismissToast(toast.modelData)
                }
            }
        }
    }
}
