pragma Singleton

import QtQuick
import Quickshell

// The on-screen display: which value changed, and for how long to show it.
Singleton {
    id: root

    property string kind: "volume"     // "volume" | "brightness"
    property bool shown: false

    readonly property real value: kind === "volume" ? (Audio.muted ? 0 : Audio.volume) : Brightness.value
    readonly property string icon: kind === "volume" ? Audio.icon
        : Brightness.value < 0.34 ? "brightness_5"
        : Brightness.value < 0.67 ? "brightness_6" : "brightness_7"

    // Not while the control center is open: its sliders already show the value.
    function show(which: string): void {
        if (Ui.controlScreen !== "")
            return;
        root.kind = which;
        root.shown = true;
        hide.restart();
    }

    Timer {
        id: hide
        interval: 1400
        onTriggered: root.shown = false
    }

    // Volume is followed straight from PipeWire, whoever changed it. The
    // values that arrive right after startup are not a change.
    property bool armed: false
    Timer {
        interval: 1500
        running: true
        onTriggered: root.armed = true
    }

    Connections {
        target: Audio
        function onVolumeChanged(): void { if (root.armed) root.show("volume"); }
        function onMutedChanged(): void { if (root.armed) root.show("volume"); }
    }

    Connections {
        target: Brightness
        function onChanged(): void { root.show("brightness"); }
    }

    Connections {
        target: Ui
        function onControlScreenChanged(): void { if (Ui.controlScreen !== "") root.shown = false; }
    }
}
