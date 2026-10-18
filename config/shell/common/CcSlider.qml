import QtQuick

// A macOS Control Center slider module, its own piece of glass: a title, then
// a thin track, filled in the icons' colour, between a small and a large icon.
// `value` is 0..1; `moved` reports drags and wheel turns over the whole module.
Item {
    id: root

    property string title: ""
    property string iconLow: ""
    property string iconHigh: ""
    property real value: 0
    property real reveal: 1
    signal moved(real value)

    implicitHeight: Theme.ccUnit + 4

    readonly property real clamped: Math.max(0, Math.min(1, value))

    GlassPanel {
        anchors.fill: parent
        reveal: root.reveal
        radius: 30

        Text {
            x: 18
            y: 13
            text: root.title
            color: Theme.text
            font.family: Theme.font
            font.weight: Font.DemiBold
            font.pixelSize: Theme.textMd
        }

        Icon {
            id: low
            x: 12
            anchors.verticalCenter: track.verticalCenter
            width: 20
            name: root.iconLow
            size: 15
            filled: true
        }

        Rectangle {
            id: track
            anchors.left: low.right
            anchors.leftMargin: 6
            anchors.right: high.left
            anchors.rightMargin: 6
            y: parent.height - 24 - height / 2
            // Thickens a little under the pointer and while dragged.
            height: drag.containsMouse || drag.pressed ? 10 : 8
            radius: height / 2
            color: Theme.sliderTrack
            Behavior on height { NumberAnimation { duration: Theme.fast; easing.type: Easing.OutCubic } }

            Rectangle {
                height: parent.height
                width: Math.max(parent.height, parent.width * root.clamped)
                radius: height / 2
                color: Theme.text
                Behavior on width {
                    enabled: !drag.pressed
                    NumberAnimation { duration: Theme.fast; easing.type: Easing.OutCubic }
                }
            }
        }

        Icon {
            id: high
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: track.verticalCenter
            width: 22
            name: root.iconHigh
            size: 19
            filled: true
        }
    }

    MouseArea {
        id: drag
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        function update(x: real): void {
            const from = track.x;
            root.moved(Math.max(0, Math.min(1, (x - from) / Math.max(1, track.width))));
        }
        onPressed: (event) => update(event.x)
        onPositionChanged: (event) => { if (pressed) update(event.x); }
        onWheel: (event) => root.moved(Math.max(0, Math.min(1, root.value + (event.angleDelta.y > 0 ? 0.05 : -0.05))))
    }
}
