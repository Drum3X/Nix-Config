pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// The notification daemon. Every notification is kept (the Notification
// Center lists them) and new ones are also queued as toasts until they time
// out.
Singleton {
    id: root

    readonly property var list: server.trackedNotifications ? server.trackedNotifications.values : []
    readonly property int count: list.length
    // Shown as toasts, newest first.
    property var toasts: []
    property bool doNotDisturb: false

    // When each notification arrived (id -> ms), for "2m ago". Lost on a
    // reload: those show no time.
    property var received: ({})
    // Ticks so the relative times move on.
    property real now: Date.now()
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.now = Date.now()
    }

    function ago(notification): string {
        const at = root.received[notification.id];
        if (at === undefined)
            return "";
        const minutes = Math.floor((root.now - at) / 60000);
        if (minutes < 1)
            return "now";
        if (minutes < 60)
            return minutes + "m ago";
        const hours = Math.floor(minutes / 60);
        if (hours < 24)
            return hours + "h ago";
        const days = Math.floor(hours / 24);
        return days === 1 ? "yesterday" : days + " days ago";
    }

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
            root.now = Date.now();
            const received = Object.assign({}, root.received);
            received[notification.id] = root.now;
            root.received = received;
            notification.closed.connect(() => root.dismissToast(notification));
            if (!root.doNotDisturb || notification.urgency === NotificationUrgency.Critical)
                root.toasts = [notification].concat(root.toasts).slice(0, 4);
        }
    }
}
