import QtQuick

// A Material Symbols Rounded glyph, by name ("wifi", "volume_up", ...).
Text {
    id: root

    property string name: ""
    property real size: 18
    property bool filled: false

    text: name
    color: Theme.text
    font.family: Theme.iconFont
    font.pixelSize: size
    font.variableAxes: ({ "FILL": filled ? 1 : 0, "wght": 400, "opsz": Math.max(20, Math.min(48, size)) })
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering

    Behavior on color { ColorAnimation { duration: Theme.normal } }
}
