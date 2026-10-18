import QtQuick

// A macOS Control Center slider: a capsule track with a white fill that ends
// in a round knob, and the icon inside the track on the left. `value` is
// 0..1; `moved` reports drags and wheel turns.
Item {
    id: root

    property real value: 0
    property string icon: ""
    signal moved(real value)

    implicitHeight: 28

    readonly property real clamped: Math.max(0, Math.min(1, value))

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: Theme.sliderTrack
    }

    Rectangle {
        id: fill
        height: track.height
        width: Math.max(track.height, track.height + (track.width - track.height) * root.clamped)
        radius: height / 2
        color: "#ffffff"
        opacity: Theme.dark ? 0.92 : 1
        Behavior on width {
            enabled: !drag.pressed
            NumberAnimation { duration: Theme.fast; easing.type: Easing.OutCubic }
        }

        // The knob, at the end of the fill.
        Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: track.height
            height: track.height
            radius: height / 2
            color: "#ffffff"
            border.width: 1
            border.color: Qt.rgba(0, 0, 0, 0.10)
        }
    }

    Icon {
        anchors.left: parent.left
        anchors.leftMargin: 7
        anchors.verticalCenter: parent.verticalCenter
        name: root.icon
        size: 15
        filled: true
        color: "#5d6075"
    }

    MouseArea {
        id: drag
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        function update(x: real): void {
            const span = width - track.height;
            root.moved(Math.max(0, Math.min(1, (x - track.height / 2) / Math.max(1, span))));
        }
        onPressed: (event) => update(event.x)
        onPositionChanged: (event) => { if (pressed) update(event.x); }
        onWheel: (event) => root.moved(Math.max(0, Math.min(1, root.value + (event.angleDelta.y > 0 ? 0.05 : -0.05))))
    }
}
