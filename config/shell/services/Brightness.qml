pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// The panel backlight, through brightnessctl (the video group may write it).
// sysfs does not notify, so the value is read back after every change.
Singleton {
    id: root

    property int current: 0
    property int max: 1
    readonly property real value: max > 0 ? current / max : 0
    readonly property bool available: max > 1

    signal changed()

    function refresh(): void {
        reader.running = true;
    }

    function setValue(fraction: real): void {
        const percent = Math.round(Math.max(0.01, Math.min(1, fraction)) * 100);
        writer.command = ["brightnessctl", "-q", "set", `${percent}%`];
        writer.running = true;
    }

    // Called by the compositor's brightness keys: `brightness step 5`.
    function step(percent: int): void {
        writer.command = ["brightnessctl", "-q", "set",
                          percent >= 0 ? `${percent}%+` : `${-percent}%-`];
        writer.running = true;
    }

    Process {
        id: reader
        // "device,class,current,percent,max"
        command: ["brightnessctl", "-m", "-c", "backlight", "info"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split(",");
                if (fields.length >= 5) {
                    root.current = parseInt(fields[2]);
                    root.max = parseInt(fields[4]);
                }
            }
        }
    }

    Process {
        id: writer
        onExited: {
            root.refresh();
            root.changed();
        }
    }

    IpcHandler {
        target: "brightness"

        function step(percent: int): void { root.step(percent); }
        function set(percent: int): void { root.setValue(percent / 100); }
    }
}
