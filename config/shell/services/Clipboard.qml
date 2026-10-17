pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// cliphist's history, for the launcher's clipboard mode.
Singleton {
    id: root

    // [{ id, text }] newest first.
    property var entries: []

    function refresh(): void {
        lister.running = true;
    }

    function copy(entry): void {
        // cliphist decode reads the whole "<id>\t<preview>" line on stdin.
        copier.command = ["sh", "-c", "printf '%s' \"$1\" | cliphist decode | wl-copy", "sh",
                          entry.id + "\t" + entry.text];
        copier.running = true;
    }

    function wipe(): void {
        wiper.running = true;
    }

    Process {
        id: lister
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.entries = text.split("\n")
                    .filter((line) => line.length > 0)
                    .slice(0, 200)
                    .map((line) => {
                        const tab = line.indexOf("\t");
                        return { id: line.substring(0, tab), text: line.substring(tab + 1) };
                    });
            }
        }
    }

    Process { id: copier }

    Process {
        id: wiper
        command: ["cliphist", "wipe"]
        onExited: root.entries = []
    }
}
