import QtQuick
import qs.services

// A notification on its own piece of glass, as macOS shows banners and the
// Notification Center's list. It slides in from the right edge of the screen
// and out to it when it leaves; dragged to the right far enough, it is
// swiped away. It never removes the notification itself: `gone` says why it
// went, once it is out of sight, and the owner acts on that.
GlassPanel {
    id: root

    required property var notification
    // Where it slides from and to: past the right edge of the screen.
    property real offscreen: width + Theme.edge + 24
    // Slide in when created; false: start in place.
    property bool slideIn: true
    readonly property bool hovered: card.hovered || drag.active

    // "close" (its close button), "activate" (clicked or an action),
    // "swipe" (dragged away) or "timeout" (leave("timeout")).
    signal gone(string reason)

    radius: Theme.panelRadius
    height: card.implicitHeight
    x: offscreen

    Component.onCompleted: {
        if (slideIn)
            enter.start();
        else
            x = 0;
    }

    function leave(reason: string): void {
        if (exit.running)
            return;
        enter.stop();
        settle.stop();
        exit.reason = reason;
        exit.start();
    }

    NumberAnimation {
        id: enter
        target: root
        property: "x"
        to: 0
        duration: 360
        easing.type: Easing.OutCubic
    }

    NumberAnimation {
        id: settle
        target: root
        property: "x"
        to: 0
        duration: 220
        easing.type: Easing.OutCubic
    }

    SequentialAnimation {
        id: exit
        property string reason: ""
        NumberAnimation {
            target: root
            property: "x"
            to: root.offscreen
            duration: 240
            easing.type: Easing.InCubic
        }
        ScriptAction { script: root.gone(exit.reason) }
    }

    NotificationCard {
        id: card
        anchors.fill: parent
        notification: root.notification
        onActivated: root.leave("activate")
        onCloseRequested: root.leave("close")
    }

    // Swipe to the right to dismiss; to the left it only gives a little.
    DragHandler {
        id: drag
        target: null
        yAxis.enabled: false
        property real startX: 0
        onActiveChanged: {
            if (active) {
                enter.stop();
                settle.stop();
                startX = root.x;
            } else if (root.x > root.width * 0.3 || centroid.velocity.x > 800) {
                root.leave("swipe");
            } else {
                settle.start();
            }
        }
        onTranslationChanged: {
            if (!active)
                return;
            const dx = startX + translation.x;
            root.x = dx >= 0 ? dx : dx * 0.2;
        }
    }
}
