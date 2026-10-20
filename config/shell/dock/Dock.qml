import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.common
import qs.services

// The dock, as on macOS: a clear glass shelf along the bottom edge with the
// app icons standing on it. Under the pointer the icons magnify in a wave and
// rise above the shelf, a dot marks the running apps, the name shows above
// the hovered icon, and a launch bounces the icon until its window appears.
//
// Two surfaces with the same geometry: the shelf is compositor glass
// ("hyalo-dock"), the icons are a separate clear layer ("no_blur") on top of
// it. Icons magnified past the shelf would otherwise count as part of the
// glass silhouette and bend its rim.
Scope {
    id: root

    required property var modelData

    // ----- layout -------------------------------------------------------------
    readonly property real base: Theme.dockIcon
    readonly property real spacing: 10
    readonly property real magnify: 1.0          // no magnification (1 = off)
    readonly property real reach: base * 2.6     // how far the wave spreads
    readonly property real lift: 5               // px a hovered icon rises
    readonly property real labelGap: 14          // hovered icon top to the label
    readonly property real headroom: base * (magnify - 1) + lift + 2   // room above the shelf for a raised icon

    // Apps, then a divider, then the trash.
    readonly property var entries: DockModel.items.concat([{ divider: true }, { trash: true }])

    // Pointer x over the icon row, in the resting row's coordinates (far off when
    // away). The row is centred the same way magnified or not, so the window's
    // centre is the common origin.
    readonly property real pointer: tracker.hovered
        ? tracker.point.position.x - (iconWindow.width - restWidth) / 2
        : -1000
    readonly property bool hovering: tracker.hovered

    // The name above the hovered icon, on a pill of glass. It is a surface of
    // its own: as a second shape on the shelf surface, its glass and the
    // shelf's ran together into one.
    property int hoveredIndex: -1
    property bool pressing: false
    readonly property var hoveredEntry: hoveredIndex >= 0 && hoveredIndex < entries.length ? entries[hoveredIndex] : null
    readonly property bool labelShown: hoveredEntry !== null && !hoveredEntry.divider && !pressing
    readonly property string labelText: !hoveredEntry ? "" : hoveredEntry.trash ? "Trash" : (hoveredEntry.name || "")
    readonly property real labelWidth: labelMetrics.width + 22
    readonly property real labelHeight: 26
    readonly property real labelX: hoveredIndex < 0 ? 0
        : Math.round((shelfWindow.width - shelfWidth) / 2 + restCentres[hoveredIndex] - labelWidth / 2)
    // Distance of the label's bottom edge from the bottom of the screen.
    readonly property real labelBottom: Theme.dockGap + Theme.dockPad + base + lift + labelGap

    TextMetrics {
        id: labelMetrics
        text: root.shownText
        font.family: Theme.font
        font.styleName: "Medium"
        font.pixelSize: Theme.textSm
    }

    // What the label shows. Held while it fades out, so it leaves with the
    // name it had.
    property string shownText: ""
    property real shownX: 0
    Binding on shownText { when: root.labelShown; value: root.labelText; restoreMode: Binding.RestoreNone }
    Binding on shownX { when: root.labelShown; value: root.labelX; restoreMode: Binding.RestoreNone }

    // 0 hidden, 1 shown: the label fades in and rises a few px into place.
    readonly property real labelRise: 4
    property real labelReveal: labelShown ? 1 : 0
    Behavior on labelReveal { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

    function slotWidth(entry): real {
        return entry.divider ? 13 : base;
    }

    // The resting row: each entry's centre without magnification.
    readonly property var restCentres: {
        const centres = [];
        let x = Theme.dockPad;
        for (let i = 0; i < entries.length; i++) {
            const w = slotWidth(entries[i]);
            centres.push(x + w / 2);
            x += w + spacing;
        }
        return centres;
    }
    readonly property real restWidth: {
        let w = Theme.dockPad * 2 - spacing;
        for (let i = 0; i < entries.length; i++)
            w += slotWidth(entries[i]) + spacing;
        return w;
    }

    function scaleAt(index: int): real {
        if (!hovering || entries[index].divider)
            return 1;
        const d = Math.abs(pointer - restCentres[index]);
        if (d >= reach)
            return 1;
        return 1 + (magnify - 1) * (1 + Math.cos(Math.PI * d / reach)) / 2;
    }

    // Shelf geometry, shared by both surfaces (they are the same size).
    readonly property real shelfWidth: iconRow.implicitWidth + Theme.dockPad * 2
    readonly property real surfaceHeight: Theme.dockHeight + Theme.dockGap + headroom

    // ----- the glass shelf ------------------------------------------------------
    PanelWindow {
        id: shelfWindow
        screen: root.modelData

        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        implicitHeight: root.surfaceHeight
        exclusiveZone: Theme.dockHeight + Theme.dockGap + 4
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "hyalo-dock"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        // ShojiWM applies the glass only inside the input region, so it must
        // cover the shelf; the icon layer above still gets the clicks first.
        mask: Region { item: shelfGlass }

        GlassPanel {
            id: shelfGlass
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.dockGap
            width: root.shelfWidth
            height: Theme.dockHeight
            radius: Theme.dockRadius
        }

    }

    // ----- the icons --------------------------------------------------------------
    PanelWindow {
        id: iconWindow
        screen: root.modelData

        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        implicitHeight: root.surfaceHeight
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "no_blur"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        // The shelf, and while hovering also the space the icons rise into.
        mask: Region {
            x: Math.round((iconWindow.width - root.shelfWidth) / 2)
            y: root.hovering ? 0 : Math.round(iconWindow.height - Theme.dockGap - Theme.dockHeight)
            width: Math.round(root.shelfWidth)
            height: root.hovering ? iconWindow.height : Theme.dockHeight + Theme.dockGap
        }

        Item {
            id: shelf
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.dockGap
            width: root.shelfWidth
            height: Theme.dockHeight

            Row {
                id: iconRow
                x: Theme.dockPad
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.dockPad
                spacing: root.spacing

                Repeater {
                    model: root.entries

                    delegate: Item {
                        id: slot
                        required property var modelData
                        required property int index

                        readonly property bool isDivider: modelData.divider === true
                        readonly property bool isTrash: modelData.trash === true
                        readonly property bool running: !isDivider && !isTrash && modelData.windows.length > 0
                        readonly property real magnification: root.scaleAt(index)
                        readonly property bool hovered: hover.containsMouse
                        // The hovered icon rises a little.
                        property real lift: hovered && !isDivider ? root.lift : 0
                        Behavior on lift { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                        width: isDivider ? 13 : root.base * magnification
                        height: root.base
                        Behavior on width {
                            enabled: !root.hovering
                            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                        }

                        // Divider.
                        Rectangle {
                            visible: slot.isDivider
                            anchors.centerIn: parent
                            width: 1
                            height: parent.height - 8
                            color: Theme.text
                            opacity: 0.2
                        }

                        IconImage {
                            id: icon
                            visible: !slot.isDivider
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: bounce.offset + slot.lift
                            implicitSize: root.base * slot.magnification
                            source: slot.isTrash ? Quickshell.iconPath("user-trash", "user-trash-full")
                                : slot.isDivider ? "" : slot.modelData.icon
                            asynchronous: true
                            mipmap: true
                            Behavior on implicitSize {
                                enabled: !root.hovering
                                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                            }

                            // A press darkens the icon a little, as on macOS.
                            Rectangle {
                                anchors.fill: parent
                                radius: width * 0.22
                                color: "black"
                                opacity: hover.pressed ? 0.25 : 0
                            }
                        }

                        // Launch bounce: until the app's first window appears.
                        QtObject {
                            id: bounce
                            property real offset: 0
                        }
                        SequentialAnimation {
                            id: bouncing
                            loops: 3
                            NumberAnimation { target: bounce; property: "offset"; to: root.base * 0.45; duration: 260; easing.type: Easing.OutQuad }
                            NumberAnimation { target: bounce; property: "offset"; to: 0; duration: 260; easing.type: Easing.InQuad }
                        }
                        onRunningChanged: if (running) bouncing.complete()

                        // Running indicator, halfway between the resting icon
                        // and the bottom of the shelf.
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.bottom
                            anchors.topMargin: (Theme.dockPad - height) / 2
                            width: 4
                            height: 4
                            radius: 2
                            color: Theme.text
                            opacity: slot.running ? 0.7 : 0
                            Behavior on opacity { NumberAnimation { duration: Theme.normal } }
                        }

                        onHoveredChanged: {
                            if (hovered)
                                root.hoveredIndex = index;
                            else if (root.hoveredIndex === index)
                                root.hoveredIndex = -1;
                        }

                        MouseArea {
                            id: hover
                            enabled: !slot.isDivider
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                            cursorShape: Qt.PointingHandCursor
                            onPressedChanged: root.pressing = pressed
                            onClicked: (event) => {
                                if (slot.isTrash) {
                                    Quickshell.execDetached(["nautilus", "trash:///"]);
                                } else if (event.button === Qt.MiddleButton) {
                                    DockModel.launchNew(slot.modelData);
                                    bouncing.restart();
                                } else {
                                    if (!slot.running)
                                        bouncing.restart();
                                    DockModel.activate(slot.modelData);
                                }
                            }
                        }
                    }
                }
            }
        }

        // Tracks the pointer for the magnification. A handler, so it sees the
        // pointer alongside the icons' own hover areas instead of taking it.
        HoverHandler {
            id: tracker
        }
    }

    // ----- the name label -----------------------------------------------------------
    PanelWindow {
        id: labelWindow
        screen: root.modelData
        visible: root.labelReveal > 0

        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        margins.bottom: root.labelBottom - root.labelRise
        implicitHeight: root.labelHeight + root.labelRise
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "hyalo-dock-label"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        mask: Region { item: labelGlass }

        GlassPanel {
            id: labelGlass
            x: root.shownX
            y: (1 - root.labelReveal) * root.labelRise
            // The compositor reads the glass from this alpha, so the glass fades too.
            opacity: root.labelReveal
            // Moving to another icon while shown: slide over to it.
            Behavior on x {
                enabled: root.labelReveal === 1
                NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
            }
            width: root.labelWidth
            height: root.labelHeight
            radius: root.labelHeight / 2

            Text {
                anchors.centerIn: parent
                text: root.shownText
                color: Theme.text
                font.family: Theme.font
                font.styleName: "Medium"
                font.pixelSize: Theme.textSm
            }
        }
    }
}
