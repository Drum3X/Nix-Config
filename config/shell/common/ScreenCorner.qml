import QtQuick
import Quickshell
import Quickshell.Wayland

// One rounded corner of the screen: a small black quarter-round mask on the
// overlay layer, over everything and click-through. `corner` counts clockwise
// from the top left (0) to the bottom left (3).
PanelWindow {
    id: root

    required property int corner

    anchors.top: corner === 0 || corner === 1
    anchors.bottom: corner === 2 || corner === 3
    anchors.left: corner === 0 || corner === 3
    anchors.right: corner === 1 || corner === 2
    implicitWidth: Theme.screenRadius
    implicitHeight: Theme.screenRadius
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "no_blur"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    mask: Region {}

    // Drawn as the top-left corner, then turned into place.
    Canvas {
        anchors.fill: parent
        rotation: root.corner * 90
        onPaint: {
            const r = width;
            const ctx = getContext("2d");
            ctx.reset();
            ctx.fillStyle = "black";
            ctx.beginPath();
            ctx.moveTo(0, 0);
            ctx.lineTo(r, 0);
            ctx.arc(r, r, r, -Math.PI / 2, Math.PI, true);
            ctx.closePath();
            ctx.fill();
        }
    }
}
