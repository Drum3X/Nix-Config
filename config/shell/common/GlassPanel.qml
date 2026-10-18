import QtQuick

// A piece of compositor glass. The fill is only a silhouette, nearly
// transparent (Theme.glassAlpha): ShojiWM's ISLAND_GLASS (matched on the layer
// namespace "hyalo-*") recovers the shape from its alpha, then refracts and
// lightly blurs what is behind and draws the specular rim itself. Nothing is
// painted over the glass here, so it stays clear, as on macOS.
Item {
    id: root

    property real radius: Theme.panelRadius
    default property alias content: inner.data

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: Theme.glassTint
        antialiasing: true
    }

    Item {
        id: inner
        anchors.fill: parent
    }
}
