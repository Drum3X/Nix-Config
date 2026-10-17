pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland
import qs.common
import qs.services

// The session lock (ext-session-lock). Locked by Super+L, after five idle
// minutes, and before the machine sleeps; unlocked only by PAM
// (/etc/pam.d/hyalo-lock). There is deliberately no unlock over IPC.
Singleton {
    id: root

    property bool locked: false
    readonly property bool busy: pam.active
    property bool failed: false
    property string message: ""
    property string pending: ""

    readonly property string user: Quickshell.env("USER") || ""

    function lock(): void {
        if (root.locked)
            return;
        root.failed = false;
        root.message = "";
        Ui.closeAll();
        root.locked = true;
    }

    function tryUnlock(password: string): void {
        if (pam.active)
            return;
        root.pending = password;
        root.failed = false;
        root.message = "";
        pam.start();
    }

    WlSessionLock {
        id: session
        locked: root.locked

        surface: WlSessionLockSurface {
            color: "black"

            LockFace {
                id: face
                anchors.fill: parent
                userName: root.user
                busy: root.busy
                failed: root.failed
                message: root.message
                onSubmit: (password) => root.tryUnlock(password)

                Connections {
                    target: root
                    function onLockedChanged(): void {
                        if (root.locked)
                            face.hide();
                    }
                }
            }
        }
    }

    PamContext {
        id: pam
        config: "hyalo-lock"
        user: root.user

        onPamMessage: {
            if (responseRequired)
                respond(root.pending);
            else if (message.length > 0)
                root.message = message;
        }

        onCompleted: (result) => {
            root.pending = "";
            if (result === PamResult.Success) {
                root.locked = false;
                root.message = "";
                return;
            }
            root.failed = false;
            root.failed = true;
            root.message = result === PamResult.MaxTries ? "Too many attempts" : "Wrong password";
        }

        onError: {
            root.pending = "";
            root.failed = false;
            root.failed = true;
            root.message = "Authentication error";
        }
    }

    // Idle: lock at five minutes, screens off at ten.
    IdleMonitor {
        timeout: 300
        respectInhibitors: true
        onIsIdleChanged: if (isIdle) root.lock()
    }

    IdleMonitor {
        timeout: 600
        respectInhibitors: true
        onIsIdleChanged: Compositor.send("output.power", { mode: isIdle ? "off" : "on" })
    }

    // logind: lock before sleep, and on `loginctl lock-session`.
    Process {
        command: ["gdbus", "monitor", "--system", "--dest", "org.freedesktop.login1"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                if (line.includes("PrepareForSleep (true") || line.includes(".Session.Lock ()"))
                    root.lock();
            }
        }
    }

    IpcHandler {
        target: "session"

        function lock(): void { root.lock(); }
        function isLocked(): bool { return root.locked; }
    }
}
