//@ pragma Env QSG_RENDER_LOOP=threaded

// hyalo-greeter: the login screen. greetd runs it under cage, which shows
// this one window fullscreen. It looks like the lock screen (common/LockFace)
// and talks to greetd through Quickshell.Services.Greetd.
//
//   HYALO_GREETER_USER     who logs in (set by modules/nixos/desktop/greeter.nix)
//   HYALO_SESSION_COMMAND  what greetd starts on success (hyalo-session)
//   HYALO_GREETER_DEMO=1   accept any password and quit: for testing the
//                          look without greetd

import QtQuick
import Quickshell
import Quickshell.Services.Greetd
import qs.common

ShellRoot {
    id: root

    readonly property string user: Quickshell.env("HYALO_GREETER_USER") || Quickshell.env("USER") || "user"
    readonly property string session: Quickshell.env("HYALO_SESSION_COMMAND") || "hyalo-session"
    readonly property bool demo: Quickshell.env("HYALO_GREETER_DEMO") === "1"

    property string pending: ""
    property bool busy: false
    property bool failed: false
    property string message: ""

    function login(password: string): void {
        root.failed = false;
        root.message = "";
        root.busy = true;
        if (root.demo) {
            demoTimer.restart();
            return;
        }
        root.pending = password;
        Greetd.createSession(root.user);
    }

    function fail(text: string): void {
        root.pending = "";
        root.busy = false;
        root.failed = false;
        root.failed = true;
        root.message = text;
    }

    Timer {
        id: demoTimer
        interval: 700
        onTriggered: Qt.quit()
    }

    Connections {
        target: Greetd

        function onAuthMessage(message: string, error: bool, responseRequired: bool, echoResponse: bool): void {
            if (responseRequired) {
                Greetd.respond(root.pending);
                root.pending = "";
            } else if (message.length > 0) {
                root.message = message;
            }
        }

        function onAuthFailure(message: string): void {
            Greetd.cancelSession();
            root.fail(message.length > 0 && message !== "pam_authenticate" ? message : "Wrong password");
        }

        function onReadyToLaunch(): void {
            // Run it directly: the greeter user's PATH (greetd's unit) has no `sh`, which
            // made the session exit the moment it was opened.
            Greetd.launch([root.session]);
        }

        function onLaunched(): void {
            Qt.quit();
        }

        function onError(error: string): void {
            Greetd.cancelSession();
            root.fail(error);
        }
    }

    FloatingWindow {
        color: "black"
        title: "hyalo-greeter"

        LockFace {
            anchors.fill: parent
            userName: root.user
            heading: root.user.charAt(0).toUpperCase() + root.user.substring(1)
            userWallpaper: false
            // Testing aid: start with the card up (HYALO_GREETER_REVEALED=1).
            revealed: Quickshell.env("HYALO_GREETER_REVEALED") === "1"
            busy: root.busy
            failed: root.failed
            message: root.message
            onSubmit: (password) => root.login(password)
        }
    }
}
