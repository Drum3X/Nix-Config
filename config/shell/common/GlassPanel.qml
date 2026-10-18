import QtQuick

// A piece of compositor glass. The fill is only a silhouette, nearly
// transparent (Theme.glassAlpha): ShojiWM's ISLAND_GLASS (matched on the layer
// namespace "hyalo-*") recovers the shape from its alpha, then refracts and
// lightly blurs what is behind and draws the specular rim itself. Nothing is
// painted over the glass here, so it stays clear, as on macOS.
//
// `reveal` (0..1) opens and closes it. The glass is read from the alpha, so
// fading it would lose its rim halfway through, before the content has gone;
// instead the piece grows from its centre while the content fades in.
Item {
    id: root

    property real radius: Theme.panelRadius
    property real reveal: 1
    // Extra scale on top of the reveal (a pressed control).
    property real squeeze: 1
    default property alias content: inner.data

    scale: reveal * squeeze
    visible: reveal > 0.001

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: Theme.glassTint
        antialiasing: true
    }

    Item {
        id: inner
        anchors.fill: parent
        // Behind the glass: the content comes in once the piece has mostly grown.
        opacity: Math.min(1, root.reveal * root.reveal)
    }
}
