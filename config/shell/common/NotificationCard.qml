import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.services

// One notification, laid out like macOS: the app icon (or the notification's
// image) on the left; the summary in bold with the time on the right, the
// body under it, and the actions as capsules at the bottom right. A close
// button shows over the icon's corner under the pointer. The card draws no
// background: NotificationBanner puts it on glass.
//
// It only asks: a click (activated) or the close button (closeRequested);
// whoever shows it takes it away, so it can animate out first.
Item {
    id: root

    required property var notification
    property QtObject colors: Theme.palette
    readonly property bool hovered: mouse.containsMouse || close.hovered || actionsHovered
    property bool actionsHovered: false

    signal activated()
    signal closeRequested()

    implicitHeight: Math.max(picture.height, column.implicitHeight) + 28

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Notifs.invokeDefault(root.notification);
            root.activated();
        }
    }

    ClippingRectangle {
        id: picture
        x: 14
        y: 14
        width: 38
        height: 38
        radius: 9
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
        anchors.rightMargin: 14
        y: 14
        spacing: 2

        Item {
            width: parent.width
            height: summary.implicitHeight

            Text {
                id: summary
                anchors.left: parent.left
                anchors.right: time.left
                anchors.rightMargin: 8
                text: root.notification.summary || root.notification.appName
                elide: Text.ElideRight
                color: root.colors.text
                font.family: Theme.font
                font.weight: Font.DemiBold
                font.pixelSize: Theme.textMd
            }

            Text {
                id: time
                anchors.right: parent.right
                anchors.baseline: summary.baseline
                text: Notifs.ago(root.notification)
                color: root.colors.textFaint
                font.family: Theme.font
                font.pixelSize: Theme.textSm
            }
        }

        Text {
            width: parent.width
            visible: text.length > 0
            text: root.notification.body
            wrapMode: Text.Wrap
            maximumLineCount: 3
            elide: Text.ElideRight
            textFormat: Text.PlainText
            color: root.colors.text
            font.family: Theme.font
            font.pixelSize: Theme.textMd
        }

        Item {
            width: parent.width
            height: actionRow.height + 6
            visible: actions.count > 0

            Row {
                id: actionRow
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                spacing: 6

                Repeater {
                    id: actions
                    model: (root.notification.actions || []).filter((a) => a.identifier !== "default")

                    delegate: Rectangle {
                        required property var modelData
                        width: actionLabel.implicitWidth + 24
                        height: 28
                        radius: 14
                        color: actionMouse.pressed ? root.colors.pressed : root.colors.hover
                        Behavior on color { ColorAnimation { duration: Theme.fast } }

                        Text {
                            id: actionLabel
                            anchors.centerIn: parent
                            text: modelData.text
                            color: root.colors.text
                            font.family: Theme.font
                            font.weight: Font.Medium
                            font.pixelSize: Theme.textMd
                        }

                        MouseArea {
                            id: actionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onContainsMouseChanged: root.actionsHovered = containsMouse
                            onClicked: {
                                modelData.invoke();
                                root.activated();
                            }
                        }
                    }
                }
            }
        }
    }

    // The close button, over the icon's top left corner while hovered.
    Rectangle {
        id: close
        readonly property bool hovered: closeMouse.containsMouse
        x: picture.x - 8
        y: picture.y - 8
        width: 20
        height: 20
        radius: 10
        color: closeMouse.pressed ? root.colors.pressed : Theme.dark ? "#4a4a50" : "#f2f2f5"
        opacity: root.hovered ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: Theme.fast } }

        Icon {
            anchors.centerIn: parent
            name: "close"
            size: 13
            color: root.colors.textDim
        }

        MouseArea {
            id: closeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.closeRequested()
        }
    }
}
