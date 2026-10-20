import QtQuick

// A Material Symbols Rounded glyph, by name ("wifi", "volume_up", ...).
//
// The glyphs of one family keep the same footprint, as on macOS: a weak Wi-Fi
// signal shows its missing bars faded instead of a smaller fan, and the
// speaker stays where it is while its waves come and go.
Text {
    id: root

    property string name: ""
    property real size: 18
    property bool filled: false

    // The whole glyph a partial one is a part of, drawn faded beneath it.
    readonly property string whole: ({ wifi_1_bar: "wifi", wifi_2_bar: "wifi" })[name] || ""
    // How far right of the speaker in volume_up a glyph draws its own, in em.
    readonly property real offset: ({ volume_mute: 1 / 6, volume_down: 0.08 })[name] || 0

    text: name
    color: Theme.text
    font.family: Theme.iconFont
    font.pixelSize: size
    font.variableAxes: ({ "FILL": filled ? 1 : 0, "wght": 400, "opsz": Math.max(20, Math.min(48, size)) })
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering
    transform: Translate { x: -root.offset * root.size }

    Behavior on color { ColorAnimation { duration: Theme.normal } }

    Text {
        anchors.fill: parent
        z: -1
        visible: root.whole !== ""
        text: root.whole
        color: root.color
        opacity: 0.3
        font: root.font
        horizontalAlignment: root.horizontalAlignment
        verticalAlignment: root.verticalAlignment
        renderType: root.renderType
    }
}
