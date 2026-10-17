import QtQuick
import Quickshell

// The wallpaper: ~/.local/share/hyalo/wallpaper when Home Manager links one
// there (hyalo.wallpaper), otherwise the one bundled with the shell. The
// greeter cannot read the user's home and always shows the bundled one.
Image {
    id: root

    property bool userWallpaper: true

    readonly property string userPath: {
        const data = Quickshell.env("XDG_DATA_HOME") || ((Quickshell.env("HOME") || "") + "/.local/share");
        return "file://" + data + "/hyalo/wallpaper";
    }
    readonly property string bundled: Qt.resolvedUrl("../assets/wallpaper.svg")

    source: userWallpaper ? userPath : bundled
    onStatusChanged: {
        if (status === Image.Error && source != bundled)
            source = bundled;
    }

    fillMode: Image.PreserveAspectCrop
    asynchronous: false
    cache: true
    smooth: true
    mipmap: true
    // Rendered at the screen's size, so an SVG stays sharp.
    sourceSize: Qt.size(width * Screen.devicePixelRatio, height * Screen.devicePixelRatio)

    // Dusk over the pastel picture in the dark palette.
    Rectangle {
        anchors.fill: parent
        color: "#0b0d1f"
        opacity: Theme.dark ? 0.48 : 0
        Behavior on opacity { NumberAnimation { duration: 900 } }
    }
}
