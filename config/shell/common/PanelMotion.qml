import QtQuick
import qs.services

// How a panel (Control Center, the launcher) comes and goes: a fade, nothing
// else. `fade` drives the content and, through glass.fade, the compositor
// glass of layer `namespace`: the glass cannot simply fade with the surface,
// since ShojiWM reads its shape from the surface's alpha.
Item {
    id: root

    property bool open: false
    property string namespace: ""

    property real fade: 0
    Behavior on fade {
        NumberAnimation {
            duration: root.open ? 200 : 160
            easing.type: root.open ? Easing.OutCubic : Easing.InOutSine
        }
    }
    onOpenChanged: {
        sentStep = -1;
        fade = open ? 1 : 0;
    }

    // Keep the surface mapped until the fade out has finished.
    readonly property bool shown: open || fade > 0

    // Tell the compositor in steps (it keeps one glass per tenth), and always
    // the end value.
    property int sentStep: 0
    onFadeChanged: {
        const step = Math.round(fade * 10);
        if (step !== sentStep) {
            sentStep = step;
            Compositor.send("glass.fade", { namespace: root.namespace, value: step / 10 });
        }
    }
}
