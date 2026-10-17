import QtQuick

// A thick rounded slider with its icon inside the track, as on the
// control center. `value` is 0..1; `moved` reports drags and wheel turns.
Item {
    id: root

    property real value: 0
    property string icon: ""
    signal moved(real value)

    implicitHeight: 40

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: Theme.hover
        clip: true

        Rectangle {
            width: Math.max(track.height, track.width * Math.max(0, Math.min(1, root.value)))
            height: parent.height
            radius: height / 2
            color: Theme.dark ? Qt.rgba(1, 1, 1, 0.82) : Qt.rgba(1, 1, 1, 0.95)
            Behavior on width {
                enabled: !drag.pressed
                NumberAnimation { duration: Theme.fast; easing.type: Easing.OutCubic }
            }
        }
    }

    Icon {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        name: root.icon
        size: 19
        filled: true
        color: Theme.dark && root.value > 0.08 ? "#262838" : Theme.text
    }

    MouseArea {
        id: drag
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        function update(x: real): void {
            root.moved(Math.max(0, Math.min(1, x / width)));
        }
        onPressed: (event) => update(event.x)
        onPositionChanged: (event) => { if (pressed) update(event.x); }
        onWheel: (event) => root.moved(Math.max(0, Math.min(1, root.value + (event.angleDelta.y > 0 ? 0.05 : -0.05))))
    }
}
