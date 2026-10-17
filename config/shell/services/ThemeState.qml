pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Light or dark. darkman owns the decision (sunrise/sunset in Istanbul, or a
// manual `darkman toggle`); its scripts call `theme set <mode>` here, and the
// shell asks it once at startup. Without darkman (the greeter) the hour
// decides.
Singleton {
    id: root

    property bool dark: {
        const hour = new Date().getHours();
        return hour < 7 || hour >= 19;
    }

    function set(mode: string): void {
        root.dark = mode === "dark";
    }

    function toggle(): void {
        toggleProc.running = true;
    }

    // The greeter has no darkman (it runs as the greeter user); the hour decides there.
    readonly property bool inGreeter: !!Quickshell.env("HYALO_GREETER_USER")

    Process {
        command: ["darkman", "get"]
        running: !root.inGreeter
        stdout: StdioCollector {
            onStreamFinished: {
                const mode = text.trim();
                if (mode === "dark" || mode === "light")
                    root.set(mode);
            }
        }
    }

    Process {
        id: toggleProc
        command: ["darkman", "toggle"]
        // No darkman (greeter, or the service is down): flip locally.
        onExited: (code) => {
            if (code !== 0)
                root.dark = !root.dark;
        }
    }

    IpcHandler {
        target: "theme"

        function set(mode: string): void { root.set(mode); }
        function toggle(): void { root.toggle(); }
        function get(): string { return root.dark ? "dark" : "light"; }
    }
}
