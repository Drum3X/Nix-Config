pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// ShojiWM's own IPC socket (NDJSON). Workspaces and windows come through the
// generic Wayland protocols instead; this carries only what those do not:
// the keyboard layout, and the shell's theme so window decorations follow it.
Singleton {
    id: root

    readonly property string path: {
        const runtime = Quickshell.env("XDG_RUNTIME_DIR") || "/tmp";
        const display = Quickshell.env("WAYLAND_DISPLAY") || "wayland-0";
        return `${runtime}/shojiwm-${display}.sock`;
    }
    readonly property bool connected: socket.connected

    property string layoutName: ""
    property int layoutIndex: 0
    // "TR", "US": what the bar shows.
    readonly property string layoutShort: {
        const name = layoutName.toLowerCase();
        if (name.startsWith("turkish"))
            return "TR";
        if (name.startsWith("english"))
            return "US";
        return layoutName.length > 0 ? layoutName.substring(0, 2).toUpperCase() : "A";
    }

    property int nextId: 1

    function send(method: string, params: var): void {
        if (!socket.connected)
            return;
        const message = { id: root.nextId++, method: method };
        if (params !== undefined)
            message.params = params;
        socket.write(JSON.stringify(message) + "\n");
        socket.flush();
    }

    function sendTheme(): void {
        send("theme.set", { mode: ThemeState.dark ? "dark" : "light" });
    }

    function handle(line: string): void {
        let message;
        try {
            message = JSON.parse(line);
        } catch (e) {
            return;
        }
        let layout = null;
        if (message.event === "keyboard.layout")
            layout = message.payload;
        else if (message.result && typeof message.result.name === "string")
            layout = message.result;
        if (layout) {
            root.layoutName = layout.name;
            root.layoutIndex = layout.index;
        }
    }

    Socket {
        id: socket
        path: root.path
        connected: true

        parser: SplitParser {
            onRead: (line) => root.handle(line)
        }

        onConnectedChanged: {
            if (connected) {
                root.sendTheme();
                root.send("keyboard.get");
            }
        }
    }

    // ShojiWM closes the socket on every config reload; come back.
    Timer {
        interval: 5000
        repeat: true
        running: !socket.connected
        onTriggered: socket.connected = true
    }

    Connections {
        target: ThemeState
        function onDarkChanged(): void { root.sendTheme(); }
    }
}
