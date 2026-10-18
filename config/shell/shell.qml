//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QSG_DISTANCEFIELD_ANTIALIASING=gray

// hyalo-shell: the desktop shell of Hyalo, on ShojiWM.
//
// Every surface below is built once per screen. The glass on the bar, dock
// and panels is ShojiWM's ISLAND_GLASS (matched on the "hyalo-*" layer
// namespaces); the shell draws only a translucent silhouette for it to
// refract. The lock screen draws its own glass (common/FrostGlass.qml).

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.bar
import qs.common
import qs.control
import qs.dock
import qs.launcher
import qs.lock
import qs.notifications
import qs.osd
import qs.services

ShellRoot {
    // Singletons are created on first use, and these own IPC targets
    // (session, theme, brightness, launcher, control) or daemons
    // (notifications, the compositor socket) that must exist from the start.
    readonly property var singletons: [Lock, ThemeState, Brightness, Ui, Notifs, Compositor, Osd]

    // Wallpaper, under everything.
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true
            exclusionMode: ExclusionMode.Ignore
            color: "black"

            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.namespace: "no_blur"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            mask: Region {}

            Wallpaper {
                anchors.fill: parent
            }
        }
    }

    Variants {
        model: Quickshell.screens
        Bar {}
    }

    Variants {
        model: Quickshell.screens
        Dock {}
    }

    Variants {
        model: Quickshell.screens
        Launcher {}
    }

    Variants {
        model: Quickshell.screens
        ControlCenter {}
    }

    Variants {
        model: Quickshell.screens
        OsdWindow {}
    }

    Variants {
        model: Quickshell.screens
        Toasts {}
    }

    // Rounded screen corners, over everything.
    Variants {
        model: Quickshell.screens

        Scope {
            id: corners
            required property var modelData

            ScreenCorner { screen: corners.modelData; corner: 0 }
            ScreenCorner { screen: corners.modelData; corner: 1 }
            ScreenCorner { screen: corners.modelData; corner: 2 }
            ScreenCorner { screen: corners.modelData; corner: 3 }
        }
    }
}
