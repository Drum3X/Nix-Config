import QtQuick
import qs.services

// How a macOS Tahoe panel (Spotlight, Control Center) comes and goes, from a
// frame-by-frame measurement of Spotlight:
//   in   300 ms  starts ~10% too wide and fades in over the first 140 ms
//                (ease out), squeezes ~1.3% under its width by 158 ms, then
//                settles; the height barely takes part.
//   out  120 ms  fades out on an S curve while growing ~3.5% on each side.
// `fade` drives the content and, through glass.fade, the compositor glass of
// layer `namespace`: the glass cannot simply fade with the surface, since
// ShojiWM reads its shape from the surface's alpha.
Item {
    id: root

    property bool open: false
    property string namespace: ""

    readonly property real fade: entering ? Math.min(1, outQuad(t / 140)) : 1 - inOutSine(t / 120)
    readonly property real xScale: entering
        ? (t < 158 ? 1.10 - 0.113 * outQuad(t / 158) : 0.987 + 0.013 * inOutSine((t - 158) / 142))
        : 1 + 0.07 * outQuad(t / 120)
    readonly property real yScale: entering ? 1 + 0.02 * (1 - outQuad(Math.min(1, t / 120))) : xScale
    // Keep the surface mapped until the way out has finished.
    readonly property bool shown: open || anim.running
    // Open and still: the panel can take its exact input region again.
    readonly property bool settled: open && !anim.running

    property bool entering: false
    property real t: 120          // starts closed

    function outQuad(x: real): real { x = Math.max(0, Math.min(1, x)); return 1 - (1 - x) * (1 - x); }
    function inOutSine(x: real): real { x = Math.max(0, Math.min(1, x)); return (1 - Math.cos(Math.PI * x)) / 2; }

    onOpenChanged: {
        anim.stop();
        sentStep = -1;
        entering = open;
        t = 0;
        anim.to = open ? 300 : 120;
        anim.duration = anim.to;
        anim.start();
    }

    NumberAnimation {
        id: anim
        target: root
        property: "t"
        from: 0
    }

    // Tell the compositor in steps (it keeps one glass per tenth), and always
    // the end value.
    property int sentStep: 10
    onFadeChanged: {
        const step = Math.round(fade * 10);
        if (step !== sentStep) {
            sentStep = step;
            Compositor.send("glass.fade", { namespace: root.namespace, value: step / 10 });
        }
    }
}
