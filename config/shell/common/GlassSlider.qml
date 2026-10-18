import QtQuick

// A line-drawn slider, as in shoji-bar-3: the icon, a hairline track, the
// filled part in the text colour and a small round knob. Nothing is filled
// behind it, so the glass stays clear. `value` is 0..1; `moved` reports drags
// and wheel turns.
Item {
    id: root

    property real value: 0
    property string icon: ""
    signal moved(real value)

    implicitHeight: 24

    readonly property real clamped: Math.max(0, Math.min(1, value))
    readonly property real knob: 12

    Icon {
        id: glyph
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 20
        name: root.icon
        size: 17
    }

    Item {
        id: track
        anchors.left: glyph.right
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: root.knob / 2
        anchors.verticalCenter: parent.verticalCenter
        height: root.knob

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 2
            radius: 1
            color: Theme.lineFaint
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * root.clamped
            height: 2
            radius: 1
            color: Theme.text
            opacity: 0.85
            Behavior on width {
                enabled: !drag.pressed
                NumberAnimation { duration: Theme.fast; easing.type: Easing.OutCubic }
            }
        }

        Rectangle {
            x: parent.width * root.clamped - width / 2
            anchors.verticalCenter: parent.verticalCenter
            width: root.knob
            height: root.knob
            radius: width / 2
            color: Theme.text
            Behavior on x {
                enabled: !drag.pressed
                NumberAnimation { duration: Theme.fast; easing.type: Easing.OutCubic }
            }
        }
    }

    MouseArea {
        id: drag
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        function update(x: real): void {
            const local = x - track.x;
            root.moved(Math.max(0, Math.min(1, local / Math.max(1, track.width))));
        }
        onPressed: (event) => update(event.x)
        onPositionChanged: (event) => { if (pressed) update(event.x); }
        onWheel: (event) => root.moved(Math.max(0, Math.min(1, root.value + (event.angleDelta.y > 0 ? 0.05 : -0.05))))
    }
}
