//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma NativeTextRendering
//@ pragma Env FREETYPE_PROPERTIES=cff:no-stem-darkening=0 autofitter:no-stem-darkening=0

// hyalo-shell: the desktop shell of Hyalo, on ShojiWM.
//
// Every surface below is built once per screen. The glass on the bar, dock
// and panels is ShojiWM's ISLAND_GLASS (matched on the "hyalo-*" layer
// namespaces); the shell draws only a translucent silhouette for it to
// refract. The lock screen draws its own glass (common/FrostGlass.qml).
//
// Text is drawn through FreeType (NativeTextRendering) with stem darkening,
// fuller and crisper than Qt's distance field text, as text is on macOS.

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
                id: wall
                anchors.fill: parent
            }

            // How light the wallpaper is under the menu bar (WallpaperTone):
            // the strip of the picture shown there, shrunk and averaged.
            // Painted but never seen.
            Canvas {
                id: tone
                width: 32
                height: 2
                opacity: 0

                readonly property string picture: wall.status === Image.Ready ? wall.source.toString() : ""
                function measure(): void {
                    if (picture === "")
                        return;
                    // Already loaded (a reload, the same wallpaper): no
                    // imageLoaded comes, so paint straight away.
                    if (isImageLoaded(picture))
                        requestPaint();
                    else
                        loadImage(picture);
                }
                onPictureChanged: measure()
                Component.onCompleted: measure()
                onImageLoaded: requestPaint()

                Connections {
                    target: wall
                    function onWidthChanged(): void { tone.requestPaint(); }
                    function onHeightChanged(): void { tone.requestPaint(); }
                }

                onPaint: {
                    if (picture === "" || !isImageLoaded(picture) || wall.width <= 0)
                        return;
                    // The part of the picture PreserveAspectCrop shows, and the
                    // bar's strip at the top of it.
                    const scale = Math.max(wall.width / wall.implicitWidth, wall.height / wall.implicitHeight);
                    const sx = (wall.implicitWidth - wall.width / scale) / 2;
                    const sy = (wall.implicitHeight - wall.height / scale) / 2;
                    const ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    ctx.drawImage(picture, sx, sy, wall.width / scale, Theme.barHeight / scale, 0, 0, width, height);
                    const data = ctx.getImageData(0, 0, width, height).data;
                    let sum = 0;
                    for (let i = 0; i < data.length; i += 4)
                        sum += 0.2126 * data[i] + 0.7152 * data[i + 1] + 0.0722 * data[i + 2];
                    WallpaperTone.setBarLuma(modelData.name, sum / (data.length / 4) / 255);
                }
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

    Variants {
        model: Quickshell.screens
        NotificationCenter {}
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
