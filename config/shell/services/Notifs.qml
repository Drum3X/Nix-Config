pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// The notification daemon. Every notification is kept (the control center
// lists them) and new ones are also queued as toasts until they time out.
Singleton {
    id: root

    readonly property var list: server.trackedNotifications ? server.trackedNotifications.values : []
    readonly property int count: list.length
    // Shown as toasts, newest first.
    property var toasts: []
    property bool doNotDisturb: false

    function dismissToast(notification): void {
        root.toasts = root.toasts.filter((n) => n !== notification);
    }

    function invokeDefault(notification): void {
        const actions = notification.actions || [];
        for (let i = 0; i < actions.length; i++) {
            if (actions[i].identifier === "default") {
                actions[i].invoke();
                return;
            }
        }
        if (actions.length > 0)
            actions[0].invoke();
        else
            notification.dismiss();
    }

    function clearAll(): void {
        const all = root.list.slice();
        for (let i = 0; i < all.length; i++)
            all[i].dismiss();
        root.toasts = [];
    }

    NotificationServer {
        id: server

        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: false
        imageSupported: true
        persistenceSupported: true

        onNotification: (notification) => {
            notification.tracked = true;
            notification.closed.connect(() => root.dismissToast(notification));
            if (!root.doNotDisturb || notification.urgency === NotificationUrgency.Critical)
                root.toasts = [notification].concat(root.toasts).slice(0, 4);
        }
    }
}
