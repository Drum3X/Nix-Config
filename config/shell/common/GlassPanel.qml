import QtQuick

// A piece of compositor glass. The fill is only a silhouette, nearly
// transparent (Theme.glassAlpha): ShojiWM's ISLAND_GLASS (matched on the layer
// namespace "hyalo-*") recovers the shape from its alpha, then refracts and
// lightly blurs what is behind and draws the specular rim itself. Nothing is
// painted over the glass here, so it stays clear, as on macOS.
//
// `reveal` (0..1) fades the content only. The silhouette has to keep its
// alpha, or the compositor would lose the shape (and its rim) halfway through
// a fade; a panel fades its glass through PanelMotion instead.
Item {
    id: root

    property real radius: Theme.panelRadius
    property real reveal: 1
    // Scale for a pressed control.
    property real squeeze: 1
    default property alias content: inner.data

    scale: squeeze

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: Theme.glassTint
        antialiasing: true
    }

    Item {
        id: inner
        anchors.fill: parent
        opacity: root.reveal
    }
}
