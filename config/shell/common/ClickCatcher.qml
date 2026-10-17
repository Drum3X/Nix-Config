import QtQuick
import Quickshell
import Quickshell.Wayland

// An invisible full-screen layer under an open panel: a click anywhere else
// closes it. Layer shell has no "click outside" of its own.
PanelWindow {
    id: root

    property bool active: false
    signal dismissed()

    visible: active
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "no_blur"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onPressed: root.dismissed()
    }
}
