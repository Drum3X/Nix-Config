pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Which panel is open, and on which screen. Panels are built per screen and
// read this; the compositor's key bindings and the bar's buttons write it.
Singleton {
    id: root

    // "" when closed.
    property string launcherScreen: ""
    property string launcherMode: "apps"   // "apps" | "clipboard"
    property string controlScreen: ""
    // The menu the Control Center opens on ("wifi", "bluetooth"), from the
    // bar; "" for its controls.
    property string controlMenu: ""
    property string notificationsScreen: ""

    readonly property bool anyOpen: launcherScreen !== "" || controlScreen !== "" || notificationsScreen !== ""

    function firstScreen(): string {
        return Quickshell.screens.length > 0 ? Quickshell.screens[0].name : "";
    }

    function openLauncher(screen: string, mode: string): void {
        root.controlScreen = "";
        root.notificationsScreen = "";
        root.launcherMode = mode;
        root.launcherScreen = screen || firstScreen();
        if (mode === "clipboard")
            Clipboard.refresh();
    }

    function toggleLauncher(screen: string, mode: string): void {
        if (root.launcherScreen !== "" && root.launcherMode === mode)
            root.launcherScreen = "";
        else
            openLauncher(screen, mode);
    }

    function toggleControl(screen: string): void {
        root.launcherScreen = "";
        root.notificationsScreen = "";
        root.controlMenu = "";
        root.controlScreen = root.controlScreen !== "" ? "" : (screen || firstScreen());
    }

    // The Control Center open on one of its menus; closed if it already is.
    function toggleControlMenu(screen: string, menu: string): void {
        root.launcherScreen = "";
        root.notificationsScreen = "";
        if (root.controlScreen !== "" && root.controlMenu === menu) {
            root.controlScreen = "";
            return;
        }
        root.controlMenu = menu;
        root.controlScreen = screen || firstScreen();
    }

    function toggleNotifications(screen: string): void {
        root.launcherScreen = "";
        root.controlScreen = "";
        root.notificationsScreen = root.notificationsScreen !== "" ? "" : (screen || firstScreen());
    }

    // The Notification Center, when open, clears them with its animation.
    signal clearNotifications()

    function closeAll(): void {
        root.launcherScreen = "";
        root.controlScreen = "";
        root.notificationsScreen = "";
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void { root.toggleLauncher("", "apps"); }
        function toggleOn(screen: string): void { root.toggleLauncher(screen, "apps"); }
        function clipboard(): void { root.toggleLauncher("", "clipboard"); }
        function clipboardOn(screen: string): void { root.toggleLauncher(screen, "clipboard"); }
        function close(): void { root.launcherScreen = ""; }
    }

    IpcHandler {
        target: "control"

        function toggle(): void { root.toggleControl(""); }
        function toggleOn(screen: string): void { root.toggleControl(screen); }
    }

    IpcHandler {
        target: "notifications"

        function toggle(): void { root.toggleNotifications(""); }
        function toggleOn(screen: string): void { root.toggleNotifications(screen); }
        function close(): void { root.notificationsScreen = ""; }
        // Clear them all; slid away if the Notification Center is open.
        function clear(): void { root.clearNotifications(); }
    }
}
