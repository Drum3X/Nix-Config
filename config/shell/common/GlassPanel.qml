import QtQuick

// A piece of compositor glass. The fill is only a silhouette: ShojiWM's
// ISLAND_GLASS (matched on the layer namespace "hyalo-*") recovers the shape
// from its alpha and refracts what is behind. The rim and sheen are drawn on
// top of it, inside the shape, so they do not change the silhouette.
Item {
    id: root

    property real radius: Theme.panelRadius
    property color tint: Theme.glassTint
    property bool rim: true
    default property alias content: inner.data

    Rectangle {
        id: fill
        anchors.fill: parent
        radius: root.radius
        color: root.tint
        antialiasing: true
    }

    // A faint highlight on the upper half, like light caught on the glass.
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        antialiasing: true
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.glassSheen }
            GradientStop { position: 0.5; color: "transparent" }
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: root.rim
        radius: root.radius
        color: "transparent"
        antialiasing: true
        border.width: 1
        border.color: Theme.glassRim
    }

    Item {
        id: inner
        anchors.fill: parent
    }

    Behavior on tint { ColorAnimation { duration: Theme.slow } }
}
