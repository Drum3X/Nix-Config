import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.WindowManager
import qs.common

// Workspace dots (ext-workspace, as ShojiWM publishes them) and the title of
// the focused window, or the desktop's name when nothing has focus.
GlassPanel {
    id: root

    required property var screen

    readonly property var projection: screen ? WindowManager.screenProjection(screen) : null
    readonly property var workspaces: projection
        ? projection.windowsets.filter((ws) => ws.shouldDisplay || ws.active)
        : []
    readonly property var focused: ToplevelManager.activeToplevel
    readonly property string title: {
        const t = focused ? (focused.title || focused.appId || "") : "";
        return t.length > 48 ? t.substring(0, 46) + "…" : (t || "Hyalo");
    }

    radius: Theme.barRadius
    implicitWidth: row.implicitWidth + 24

    Behavior on implicitWidth { NumberAnimation { duration: Theme.normal; easing.type: Easing.OutCubic } }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 10

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5

            Repeater {
                model: root.workspaces

                delegate: Rectangle {
                    required property var modelData
                    anchors.verticalCenter: parent.verticalCenter
                    width: modelData.active ? 14 : 6
                    height: 6
                    radius: 3
                    color: modelData.active ? Theme.text : Theme.textFaint
                    opacity: modelData.active ? 0.9 : modelData.urgent ? 1 : 0.55

                    Behavior on width { NumberAnimation { duration: Theme.normal; easing.type: Easing.OutCubic } }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (modelData.canActivate) modelData.activate()
                    }
                }
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.title
            color: Theme.text
            font.family: Theme.font
            font.weight: Font.Medium
            font.pixelSize: Theme.textBar
        }
    }

    // Scroll over the pill to move between workspaces.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: (event) => {
            const list = root.workspaces;
            let current = list.findIndex((ws) => ws.active);
            const next = list[current + (event.angleDelta.y > 0 ? -1 : 1)];
            if (next && next.canActivate)
                next.activate();
        }
    }
}
