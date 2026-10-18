import QtQuick
import QtQuick.Effects

// Text on the Control Center's dark glass (Theme.cc). In the light
// appearance that glass sits over light windows and stays light grey, so a
// soft shadow lifts the light text off it.
Text {
    property bool shadow: !Theme.dark

    color: Theme.cc.text
    font.family: Theme.font

    layer.enabled: shadow
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Qt.rgba(0, 0, 0, 0.45)
        shadowBlur: 0.35
        shadowVerticalOffset: 1
        shadowHorizontalOffset: 0
    }
}
