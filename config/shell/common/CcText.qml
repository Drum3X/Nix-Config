import QtQuick
import QtQuick.Effects

// Text on the Control Center's dark glass (Theme.cc). In the light
// appearance that glass sits over light windows and stays light grey, so a
// soft shadow lifts the light text off it.
Text {
    property bool shadow: !Theme.dark

    color: Theme.cc.text
    font.family: Theme.font

    // Only once there is something to draw: a layer made while the text is
    // empty (a time that comes later) stays empty.
    layer.enabled: shadow && width > 0 && height > 0
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Qt.rgba(0, 0, 0, 0.25)
        shadowBlur: 0.3
        shadowVerticalOffset: 1
        shadowHorizontalOffset: 0
    }
}
