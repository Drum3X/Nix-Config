pragma Singleton

import QtQuick
import Quickshell

// How light the wallpaper is behind the menu bar, per screen: measured from
// the picture itself by the wallpaper layer (shell.qml), not taken from the
// appearance, and measured again whenever the wallpaper changes. The bar
// draws its items black over a light wallpaper and white over a dark one.
Singleton {
    id: root

    // screen name -> luma (0..1) of the strip under the bar.
    property var barLuma: ({})

    function setBarLuma(screen: string, luma: real): void {
        const next = Object.assign({}, barLuma);
        next[screen] = luma;
        barLuma = next;
    }

    // Black items on `screen`'s bar. Until it is measured: black, as over the
    // bundled wallpaper.
    function blackItems(screen: string): bool {
        const luma = barLuma[screen];
        return luma === undefined || luma > 0.55;
    }
}
