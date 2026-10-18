import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.common
import qs.services

// The launcher: a glass panel in the middle of the screen. Type to search
// applications; in clipboard mode (Super+V) the same list is cliphist's
// history. Up/Down select, Enter runs, Escape closes.
Scope {
    id: root

    required property var modelData
    readonly property bool open: Ui.launcherScreen === modelData.name
    readonly property bool clipboard: Ui.launcherMode === "clipboard"

    ClickCatcher {
        screen: root.modelData
        active: root.open
        onDismissed: Ui.launcherScreen = ""
    }

    PanelWindow {
        id: window
        screen: root.modelData
        visible: motion.shown

        PanelMotion {
            id: motion
            open: root.open
            namespace: "hyalo-launcher"
        }

        implicitWidth: 640
        implicitHeight: 480
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "hyalo-launcher"
        WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        mask: Region { item: panel }

        property string query: ""
        property int selected: 0
        readonly property var results: root.clipboard
            ? Clipboard.entries.filter((e) => e.text.toLowerCase().includes(query.toLowerCase()))
            : Apps.search(query)

        onQueryChanged: selected = 0

        function run(index: int): void {
            const item = results[index];
            if (!item)
                return;
            if (root.clipboard)
                Clipboard.copy(item);
            else
                Apps.launch(item);
            Ui.launcherScreen = "";
        }

        Connections {
            target: root
            function onOpenChanged(): void {
                if (root.open) {
                    window.query = "";
                    search.text = "";
                    window.selected = 0;
                    search.forceActiveFocus();
                }
            }
        }

        GlassPanel {
            id: panel
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: Math.min(parent.height, 76 + list.contentHeight + (list.count > 0 ? 12 : 0))
            radius: Theme.panelRadius

            reveal: motion.fade
            Behavior on height { NumberAnimation { duration: Theme.fast; easing.type: Easing.OutCubic } }

            // Search field.
            Item {
                id: header
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 12
                height: 52

                Rectangle {
                    anchors.fill: parent
                    radius: 16
                    color: Theme.hover
                }

                Icon {
                    id: searchIcon
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    name: root.clipboard ? "content_paste" : "search"
                    size: 22
                    color: Theme.textDim
                }

                TextInput {
                    id: search
                    anchors.left: searchIcon.right
                    anchors.right: parent.right
                    anchors.leftMargin: 12
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.text
                    selectionColor: Theme.selected
                    font.family: Theme.font
                    font.pixelSize: 18
                    clip: true
                    focus: true

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: search.text.length === 0
                        text: root.clipboard ? "Search clipboard history" : "Search apps"
                        color: Theme.textFaint
                        font: search.font
                    }

                    onTextChanged: window.query = text
                    onAccepted: window.run(window.selected)
                    Keys.onEscapePressed: Ui.launcherScreen = ""
                    Keys.onUpPressed: {
                        window.selected = Math.max(0, window.selected - 1);
                        list.positionViewAtIndex(window.selected, ListView.Contain);
                    }
                    Keys.onDownPressed: {
                        window.selected = Math.min(list.count - 1, window.selected + 1);
                        list.positionViewAtIndex(window.selected, ListView.Contain);
                    }
                    Keys.onTabPressed: Ui.openLauncher(root.modelData.name, root.clipboard ? "apps" : "clipboard")
                }
            }

            ListView {
                id: list
                anchors.top: header.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 12
                anchors.topMargin: 8
                clip: true
                spacing: 2
                model: window.results
                boundsBehavior: Flickable.StopAtBounds

                delegate: Item {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property bool isSelected: index === window.selected

                    width: list.width
                    height: root.clipboard ? 40 : 52

                    Rectangle {
                        anchors.fill: parent
                        radius: 14
                        color: row.isSelected ? Theme.selected : rowMouse.containsMouse ? Theme.hover : Theme.clear
                        Behavior on color { ColorAnimation { duration: Theme.fast } }
                    }

                    IconImage {
                        id: appIcon
                        visible: !root.clipboard
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        implicitSize: 32
                        asynchronous: true
                        source: root.clipboard ? "" : Quickshell.iconPath(row.modelData.icon || "", "application-x-executable")
                    }

                    Column {
                        anchors.left: root.clipboard ? parent.left : appIcon.right
                        anchors.leftMargin: root.clipboard ? 16 : 12
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 1

                        Text {
                            width: parent.width
                            text: root.clipboard ? row.modelData.text : row.modelData.name
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            color: Theme.text
                            font.family: Theme.font
                            font.weight: root.clipboard ? Font.Normal : Font.Medium
                            font.pixelSize: Theme.textMd
                        }

                        Text {
                            width: parent.width
                            visible: !root.clipboard && text.length > 0
                            text: root.clipboard ? "" : (row.modelData.genericName || row.modelData.comment || "")
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            color: Theme.textDim
                            font.family: Theme.font
                            font.pixelSize: Theme.textSm
                        }
                    }

                    MouseArea {
                        id: rowMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: window.selected = row.index
                        onClicked: window.run(row.index)
                    }
                }
            }
        }
    }
}
