import QtQuick
import QtQuick.Effects

// The face shared by the lock screen and the greeter.
//
// At rest it is the wallpaper, a large thin clock, the date, and a "swipe up"
// hint. A swipe, a click or any key brings up the glass card: the user's
// initial, their name and the password field. Enter submits; Escape clears
// the field, or puts the card away again when it is already empty.
Item {
    id: root

    property string userName: ""
    property string heading: userName
    property bool busy: false
    property bool failed: false
    property string message: ""
    // The greeter shows its own wallpaper only; the lock may show the user's.
    property bool userWallpaper: true

    signal submit(string password)

    property bool revealed: false
    property real reveal: revealed ? 1 : 0
    Behavior on reveal { NumberAnimation { duration: Theme.slow; easing.type: Easing.OutCubic } }

    function show(): void {
        revealed = true;
        field.forceActiveFocus();
        idle.restart();
    }
    function hide(): void {
        revealed = false;
        field.text = "";
        keys.forceActiveFocus();
    }
    function clear(): void {
        field.text = "";
    }

    // After a failed attempt the field is emptied and shaken.
    onFailedChanged: {
        if (failed) {
            field.text = "";
            shake.restart();
        }
    }

    readonly property date now: clock.now
    Timer {
        id: clock
        property date now: new Date()
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: now = new Date()
    }

    // Back to the clock after a while without input.
    Timer {
        id: idle
        interval: 30000
        onTriggered: if (!root.busy) root.hide()
    }

    // ----- backdrop ---------------------------------------------------------

    Wallpaper {
        id: wall
        anchors.fill: parent
        userWallpaper: root.userWallpaper
    }
    // What the glass refracts: the wallpaper, frosted to the same level as
    // ShojiWM's glass (radius 2, one pass). Never shown.
    MultiEffect {
        id: frosted
        anchors.fill: parent
        source: wall
        autoPaddingEnabled: false
        blurEnabled: true
        blurMax: 8
        blur: 0.5
    }
    ShaderEffectSource {
        id: backdrop
        anchors.fill: parent
        sourceItem: frosted
        hideSource: true
        visible: false
    }

    // ----- clock --------------------------------------------------------------

    Column {
        id: clockColumn
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.17 - root.reveal * parent.height * 0.06
        scale: 1 - root.reveal * 0.28
        spacing: 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(root.now, "HH:mm")
            color: Theme.onWallpaper
            font.family: Theme.fontDisplay
            font.weight: Font.Thin
            font.pixelSize: Math.round(root.height * 0.15)
            font.letterSpacing: -2
            renderType: Text.CurveRendering
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.locale("en_US").toString(root.now, "dddd, MMMM d")
            color: Theme.onWallpaper
            opacity: 0.92
            font.family: Theme.font
            font.weight: Font.Normal
            font.pixelSize: Math.round(root.height * 0.024)
        }
    }

    // ----- card ---------------------------------------------------------------

    Column {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.5 + (1 - root.reveal) * 40
        opacity: root.reveal
        visible: opacity > 0
        spacing: 14

        FrostGlass {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 88
            height: 88
            radius: 44
            backdrop: backdrop
            refraction: 14
            rimWidth: 16

            Text {
                anchors.centerIn: parent
                text: root.heading.length > 0 ? root.heading.charAt(0).toUpperCase() : ""
                color: Theme.onWallpaper
                font.family: Theme.font
                font.weight: Font.Light
                font.pixelSize: 38
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.heading
            color: Theme.onWallpaper
            font.family: Theme.font
            font.weight: Font.Medium
            font.pixelSize: 17
        }

        FrostGlass {
            id: pill
            anchors.horizontalCenter: parent.horizontalCenter
            width: 280
            height: 46
            radius: 23
            backdrop: backdrop

            transform: Translate { id: shakeOffset }

            TextInput {
                id: field
                anchors.left: parent.left
                anchors.right: submitButton.left
                anchors.leftMargin: 20
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                echoMode: TextInput.Password
                passwordCharacter: "●"
                color: Theme.onWallpaper
                selectionColor: Qt.rgba(1, 1, 1, 0.35)
                font.family: Theme.font
                font.pixelSize: 15
                font.letterSpacing: 2
                enabled: !root.busy
                clip: true

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: field.text.length === 0
                    text: root.busy ? "Checking…" : "Password"
                    color: Theme.onWallpaper
                    opacity: 0.6
                    font.family: Theme.font
                    font.pixelSize: 14
                }

                onTextEdited: idle.restart()
                onAccepted: {
                    if (text.length > 0 && !root.busy)
                        root.submit(text);
                }
                Keys.onEscapePressed: {
                    if (text.length > 0)
                        text = "";
                    else
                        root.hide();
                }
            }

            Item {
                id: submitButton
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                width: 34
                height: 34

                Rectangle {
                    anchors.fill: parent
                    radius: 17
                    color: Qt.rgba(1, 1, 1, submitMouse.containsMouse ? 0.34 : 0.2)
                }

                Icon {
                    anchors.centerIn: parent
                    name: root.busy ? "hourglass_top" : "arrow_forward"
                    color: Theme.onWallpaper
                    size: 20
                }

                MouseArea {
                    id: submitMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: field.accepted()
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 320
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: root.message
            visible: text.length > 0
            color: root.failed ? "#ffd2d8" : Theme.onWallpaper
            opacity: 0.9
            font.family: Theme.font
            font.pixelSize: 13
        }
    }

    SequentialAnimation {
        id: shake
        loops: 1
        NumberAnimation { target: shakeOffset; property: "x"; to: -12; duration: 50 }
        NumberAnimation { target: shakeOffset; property: "x"; to: 10; duration: 70 }
        NumberAnimation { target: shakeOffset; property: "x"; to: -6; duration: 60 }
        NumberAnimation { target: shakeOffset; property: "x"; to: 0; duration: 60 }
    }

    // ----- swipe hint -----------------------------------------------------------

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18
        spacing: 12
        opacity: 1 - root.reveal

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Swipe up to unlock"
            color: Theme.onWallpaper
            opacity: 0.9
            font.family: Theme.font
            font.pixelSize: 13
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 112
            height: 5
            radius: 2.5
            color: Theme.onWallpaper
            opacity: 0.85
        }
    }

    // ----- input ----------------------------------------------------------------

    // A swipe up (or a click) anywhere brings the card.
    MouseArea {
        anchors.fill: parent
        enabled: !root.revealed
        property real startY: 0
        onPressed: (event) => startY = event.y
        onReleased: (event) => {
            if (startY - event.y > 60 || Math.abs(startY - event.y) < 6)
                root.show();
        }
    }

    // Keys while the card is down: any key brings it up, and a printable one
    // is the first character of the password.
    Item {
        id: keys
        anchors.fill: parent
        focus: true
        Keys.onPressed: (event) => {
            if (root.revealed)
                return;
            root.show();
            if (event.text.length > 0 && event.text.charCodeAt(0) >= 32)
                field.insert(field.cursorPosition, event.text);
            event.accepted = true;
        }
    }

    Component.onCompleted: keys.forceActiveFocus()
}
