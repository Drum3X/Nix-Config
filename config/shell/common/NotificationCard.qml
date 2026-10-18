import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.services

// One notification: app icon (or image), summary, body and action buttons.
// Clicking runs its default action; the close button dismisses it.
Item {
    id: root

    required property var notification
    property color background: "transparent"
    // Theme.cc on the Control Center's always-dark glass.
    property QtObject colors: Theme.palette
    readonly property bool hovered: mouse.containsMouse || close.hovered

    signal dismissed()

    implicitHeight: column.implicitHeight + 24

    Rectangle {
        anchors.fill: parent
        radius: Theme.tileRadius
        color: root.background
    }

    ClippingRectangle {
        id: picture
        x: 12
        y: 12
        width: 36
        height: 36
        radius: 10
        color: "transparent"

        Image {
            anchors.fill: parent
            visible: source != ""
            source: root.notification.image || ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }

        IconImage {
            anchors.fill: parent
            visible: !root.notification.image
            source: Quickshell.iconPath(root.notification.appIcon || root.notification.desktopEntry || "", "dialog-information")
            asynchronous: true
        }
    }

    Column {
        id: column
        anchors.left: picture.right
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 34
        y: 12
        spacing: 3

        CcText {
            shadow: root.colors === Theme.cc && !Theme.dark
            width: parent.width
            text: root.notification.appName
            visible: text.length > 0
            elide: Text.ElideRight
            color: root.colors.textFaint
            font.family: Theme.font
            font.pixelSize: Theme.textXs
        }

        CcText {
            shadow: root.colors === Theme.cc && !Theme.dark
            width: parent.width
            text: root.notification.summary
            elide: Text.ElideRight
            color: root.colors.text
            font.family: Theme.font
            font.weight: Font.DemiBold
            font.pixelSize: Theme.textMd
        }

        CcText {
            shadow: root.colors === Theme.cc && !Theme.dark
            width: parent.width
            visible: text.length > 0
            text: root.notification.body
            wrapMode: Text.Wrap
            maximumLineCount: 3
            elide: Text.ElideRight
            textFormat: Text.PlainText
            color: root.colors.textDim
            font.family: Theme.font
            font.pixelSize: Theme.textSm
        }

        Row {
            spacing: 6
            topPadding: 4
            visible: actions.count > 0

            Repeater {
                id: actions
                model: (root.notification.actions || []).filter((a) => a.identifier !== "default")

                delegate: Rectangle {
                    required property var modelData
                    width: actionLabel.implicitWidth + 20
                    height: 26
                    radius: 13
                    color: actionMouse.containsMouse ? root.colors.pressed : root.colors.hover

                    CcText {
                        shadow: root.colors === Theme.cc && !Theme.dark
                        id: actionLabel
                        anchors.centerIn: parent
                        text: modelData.text
                        color: root.colors.text
                        font.family: Theme.font
                        font.weight: Font.Medium
                        font.pixelSize: Theme.textSm
                    }

                    MouseArea {
                        id: actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: modelData.invoke()
                    }
                }
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        z: -1
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Notifs.invokeDefault(root.notification);
            root.dismissed();
        }
    }

    IconButton {
        id: close
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 6
        width: 24
        height: 24
        icon: "close"
        iconSize: 16
        colors: root.colors
        color: root.colors.textDim
        onClicked: {
            root.notification.dismiss();
            root.dismissed();
        }
    }
}
