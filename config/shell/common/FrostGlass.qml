import QtQuick

// Glass drawn by the shell itself, for surfaces the compositor does not
// treat as glass: the lock screen (a session-lock surface, not a layer) and
// the greeter (running under cage). It refracts `backdrop`, a full-screen
// texture of the (frosted) wallpaper the surface already owns, through a
// rounded rectangle: the rim bends the picture inward like the edge of a lens.
Item {
    id: root

    // A ShaderEffectSource (or layered item) covering the whole surface.
    required property Item backdrop
    property real radius: Theme.panelRadius
    property color tint: Theme.frostTint
    property color rimColor: Theme.glassRim
    property real refraction: 80     // px the rim pulls the picture inward (as ISLAND_GLASS)
    property real rimWidth: 80       // px over which it does
    default property alias content: inner.data

    // Where this item sits on the backdrop, kept current every frame while it
    // is visible so the glass refracts the right part even while animating.
    property rect area: Qt.rect(0, 0, 1, 1)

    function updateArea(): void {
        if (!backdrop || backdrop.width <= 0 || backdrop.height <= 0)
            return;
        const p = root.mapToItem(backdrop, 0, 0);
        const next = Qt.rect(p.x / backdrop.width, p.y / backdrop.height,
                             root.width / backdrop.width, root.height / backdrop.height);
        if (next.x !== area.x || next.y !== area.y || next.width !== area.width || next.height !== area.height)
            area = next;
    }

    FrameAnimation {
        running: root.visible && root.opacity > 0
        onTriggered: root.updateArea()
    }

    ShaderEffect {
        anchors.fill: parent

        property var source: root.backdrop
        property vector4d rect: Qt.vector4d(root.area.x, root.area.y, root.area.width, root.area.height)
        property vector2d size: Qt.vector2d(width, height)
        property real radius: root.radius
        property real refraction: root.refraction
        property real rimWidth: root.rimWidth
        property color tint: root.tint
        property color rimColor: root.rimColor
        property real ambientCeiling: Theme.glassAmbientCeiling
        property real ambientFloor: Theme.glassAmbientFloor

        fragmentShader: Qt.resolvedUrl("../shaders/frost.frag.qsb")
        onStatusChanged: {
            if (status === ShaderEffect.Error)
                console.error("FrostGlass shader:", log);
        }
    }

    Item {
        id: inner
        anchors.fill: parent
    }
}
