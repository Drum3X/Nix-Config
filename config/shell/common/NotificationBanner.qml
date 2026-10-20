import QtQuick
import qs.services

// A notification on its own piece of glass, as macOS shows banners and the
// Notification Center's list. It slides in from beyond the right edge of the
// screen, slowing down, and leaves the other way, speeding up. Dragged to
// the right far enough, it is swiped away. It never removes the notification itself:
// `gone` says why it went, once it is out of sight, and the owner acts on it.
GlassPanel {
    id: root

    required property var notification
    // Slide in when created; false: start in place. Read once, then.
    property bool slideIn: true
    // How far right of its rest it is: 0 in place, `offscreen` beyond the
    // right edge of the screen.
    property real shift: 0
    readonly property real offscreen: width + Theme.edge + 24
    readonly property bool hovered: card.hovered || drag.active

    // "activate" (clicked or an action), "swipe" (dragged away), or what was
    // given to leave() ("timeout", "clear").
    signal gone(string reason)

    radius: Theme.panelRadius
    height: card.implicitHeight
    // A transform rather than x: the Column it sits in sets x itself when it
    // moves the cards up after one goes, which would cut a binding on x.
    transform: Translate { x: root.shift }

    Component.onCompleted: {
        if (slideIn) {
            shift = offscreen;
            enter.start();
        }
    }

    // `delay` ms first: clearing them all sends them off one after another.
    function leave(reason: string, delay: int): void {
        if (exit.running)
            return;
        enter.stop();
        settle.stop();
        exit.reason = reason;
        exit.delay = delay || 0;
        exit.start();
    }

    NumberAnimation {
        id: enter
        target: root
        property: "shift"
        to: 0
        duration: Theme.slideIn
        easing.type: Easing.OutCubic
    }

    NumberAnimation {
        id: settle
        target: root
        property: "shift"
        to: 0
        duration: 320
        easing.type: Easing.OutCubic
    }

    SequentialAnimation {
        id: exit
        property string reason: ""
        property int delay: 0
        PauseAnimation { duration: exit.delay }
        NumberAnimation {
            target: root
            property: "shift"
            to: root.offscreen
            duration: Theme.slideOut
            easing.type: Easing.InCubic
        }
        ScriptAction { script: root.gone(exit.reason) }
    }

    NotificationCard {
        id: card
        anchors.fill: parent
        notification: root.notification
        onActivated: root.leave("activate", 0)
    }

    // Swipe to the right to dismiss.
    DragHandler {
        id: drag
        target: null
        yAxis.enabled: false
        property real startShift: 0
        onActiveChanged: {
            if (active) {
                enter.stop();
                settle.stop();
                startShift = root.shift;
            } else if (root.shift > root.width * 0.3 || centroid.velocity.x > 800) {
                root.leave("swipe", 0);
            } else {
                settle.start();
            }
        }
        onTranslationChanged: {
            if (!active)
                return;
            const dx = startShift + translation.x;
            root.shift = Math.max(0, dx);
        }
    }
}
