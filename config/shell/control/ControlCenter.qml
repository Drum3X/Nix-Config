import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.UPower
import Quickshell.Wayland
import Quickshell.Widgets
import qs.common
import qs.lock
import qs.services

// The control center, under the right end of the bar: quick toggles, Wi-Fi
// networks, sliders, the playing media, notifications and the power buttons.
Scope {
    id: root

    required property var modelData
    readonly property bool open: Ui.controlScreen === modelData.name

    ClickCatcher {
        screen: root.modelData
        active: root.open
        onDismissed: Ui.controlScreen = ""
    }

    PanelWindow {
        id: window
        screen: root.modelData
        visible: root.open || panel.opacity > 0

        anchors.top: true
        anchors.right: true
        margins.top: Theme.barExclusive - 2
        margins.right: Theme.edge
        implicitWidth: 380
        implicitHeight: Math.min(screen.height - Theme.barExclusive - Theme.dockHeight - Theme.edge * 3,
                                 content.implicitHeight + 28)
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "hyalo-control"
        WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        mask: Region { item: panel }

        property bool wifiExpanded: false
        property var pskNetwork: null

        Connections {
            target: root
            function onOpenChanged(): void {
                window.wifiExpanded = false;
                window.pskNetwork = null;
                Net.scan(false);
            }
        }

        GlassPanel {
            id: panel
            anchors.fill: parent
            radius: Theme.panelRadius
            focus: true

            opacity: root.open ? 1 : 0
            transform: Translate { y: root.open ? 0 : -10 }
            Behavior on opacity { NumberAnimation { duration: Theme.normal; easing.type: Easing.OutCubic } }

            Keys.onEscapePressed: Ui.controlScreen = ""

            Flickable {
                anchors.fill: parent
                anchors.margins: 14
                contentHeight: content.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: content
                    width: parent.width
                    spacing: 12

                    // ----- header: date and power -----------------------------
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        SystemClock {
                            id: clock
                            precision: SystemClock.Minutes
                        }

                        Column {
                            Layout.fillWidth: true
                            Text {
                                text: Qt.formatTime(clock.date, "HH:mm")
                                color: Theme.text
                                font.family: Theme.font
                                font.weight: Font.Light
                                font.pixelSize: 26
                            }
                            Text {
                                text: Qt.locale("en_US").toString(clock.date, "dddd, MMMM d")
                                color: Theme.textDim
                                font.family: Theme.font
                                font.pixelSize: Theme.textSm
                            }
                        }

                        IconButton {
                            icon: "lock"
                            onClicked: Lock.lock()
                        }
                        PowerButton {
                            icon: "logout"
                            command: ["shoji_wm", "--quit"]
                        }
                        PowerButton {
                            icon: "restart_alt"
                            command: ["systemctl", "reboot"]
                        }
                        PowerButton {
                            icon: "power_settings_new"
                            command: ["systemctl", "poweroff"]
                        }
                    }

                    // ----- toggles --------------------------------------------
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: 8
                        columnSpacing: 8

                        QuickToggle {
                            Layout.fillWidth: true
                            icon: Net.icon
                            label: "Wi-Fi"
                            detail: Net.wired ? "Ethernet" : !Net.wifiEnabled ? "Off" : (Net.name || "Not connected")
                            checked: Net.wifiEnabled
                            expandable: true
                            expanded: window.wifiExpanded
                            onToggled: Net.setWifi(!Net.wifiEnabled)
                            onExpandRequested: {
                                window.wifiExpanded = !window.wifiExpanded;
                                Net.scan(window.wifiExpanded);
                            }
                        }

                        QuickToggle {
                            readonly property var adapter: Bluetooth.defaultAdapter
                            readonly property var connected: Bluetooth.devices
                                ? Bluetooth.devices.values.filter((d) => d.connected) : []
                            Layout.fillWidth: true
                            icon: adapter && adapter.enabled ? "bluetooth" : "bluetooth_disabled"
                            label: "Bluetooth"
                            detail: !adapter ? "Unavailable" : !adapter.enabled ? "Off"
                                : connected.length > 0 ? connected.map((d) => d.name).join(", ") : "On"
                            checked: adapter ? adapter.enabled : false
                            onToggled: if (adapter) adapter.enabled = !adapter.enabled
                        }

                        QuickToggle {
                            Layout.fillWidth: true
                            icon: Theme.dark ? "dark_mode" : "light_mode"
                            label: "Dark mode"
                            detail: "Follows the sun"
                            checked: Theme.dark
                            onToggled: ThemeState.toggle()
                        }

                        QuickToggle {
                            Layout.fillWidth: true
                            icon: Notifs.doNotDisturb ? "notifications_off" : "notifications"
                            label: "Do not disturb"
                            detail: Notifs.doNotDisturb ? "On" : "Off"
                            checked: Notifs.doNotDisturb
                            onToggled: Notifs.doNotDisturb = !Notifs.doNotDisturb
                        }
                    }

                    // ----- Wi-Fi networks --------------------------------------
                    Column {
                        Layout.fillWidth: true
                        visible: window.wifiExpanded && Net.wifiEnabled
                        spacing: 2

                        Repeater {
                            model: Net.networks.slice(0, 8)

                            delegate: Item {
                                id: netRow
                                required property var modelData
                                width: parent.width
                                height: window.pskNetwork === modelData ? 84 : 40

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 12
                                    color: netMouse.containsMouse ? Theme.hover : "transparent"
                                }

                                Icon {
                                    id: netIcon
                                    x: 10
                                    y: 10
                                    name: netRow.modelData.signalStrength > 0.66 ? "wifi"
                                        : netRow.modelData.signalStrength > 0.33 ? "wifi_2_bar" : "wifi_1_bar"
                                    size: 18
                                    filled: netRow.modelData.connected
                                    color: netRow.modelData.connected ? Theme.accent : Theme.text
                                }

                                Text {
                                    anchors.left: netIcon.right
                                    anchors.leftMargin: 10
                                    anchors.right: parent.right
                                    anchors.rightMargin: 12
                                    y: 11
                                    text: netRow.modelData.name
                                        + (netRow.modelData.connected ? "  ·  Connected"
                                           : netRow.modelData.stateChanging ? "  ·  Connecting…" : "")
                                    elide: Text.ElideRight
                                    color: Theme.text
                                    font.family: Theme.font
                                    font.pixelSize: Theme.textMd
                                }

                                MouseArea {
                                    id: netMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        const network = netRow.modelData;
                                        if (network.connected)
                                            network.disconnect();
                                        else if (network.known || network.security === WifiSecurityType.Open)
                                            network.connect();
                                        else
                                            window.pskNetwork = network;
                                    }
                                }

                                // Password for a network that is not known yet.
                                Rectangle {
                                    visible: window.pskNetwork === netRow.modelData
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.margins: 6
                                    height: 36
                                    radius: 12
                                    color: Theme.hover

                                    TextInput {
                                        id: psk
                                        anchors.fill: parent
                                        anchors.leftMargin: 12
                                        anchors.rightMargin: 12
                                        verticalAlignment: TextInput.AlignVCenter
                                        echoMode: TextInput.Password
                                        color: Theme.text
                                        font.family: Theme.font
                                        font.pixelSize: Theme.textMd
                                        onVisibleChanged: if (visible) { text = ""; forceActiveFocus(); }
                                        onAccepted: {
                                            netRow.modelData.connectWithPsk(text);
                                            window.pskNetwork = null;
                                        }
                                        Keys.onEscapePressed: window.pskNetwork = null

                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            visible: psk.text.length === 0
                                            text: "Password"
                                            color: Theme.textFaint
                                            font: psk.font
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ----- power profile -------------------------------------------
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        radius: 18
                        color: Theme.hover

                        Row {
                            anchors.fill: parent
                            anchors.margins: 3

                            Repeater {
                                model: [
                                    { profile: PowerProfile.PowerSaver, icon: "eco", label: "Saver" },
                                    { profile: PowerProfile.Balanced, icon: "balance", label: "Balanced" },
                                    { profile: PowerProfile.Performance, icon: "bolt", label: "Performance" }
                                ]

                                delegate: Item {
                                    required property var modelData
                                    readonly property bool current: PowerProfiles.profile === modelData.profile
                                    readonly property bool usable: modelData.profile !== PowerProfile.Performance
                                        || PowerProfiles.hasPerformanceProfile
                                    width: parent.width / 3
                                    height: parent.height
                                    opacity: usable ? 1 : 0.4

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: height / 2
                                        color: parent.current ? Theme.selected : "transparent"
                                        Behavior on color { ColorAnimation { duration: Theme.fast } }
                                    }

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 5
                                        Icon {
                                            name: modelData.icon
                                            size: 16
                                            filled: parent.parent.current
                                        }
                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: modelData.label
                                            color: Theme.text
                                            font.family: Theme.font
                                            font.weight: parent.parent.current ? Font.DemiBold : Font.Normal
                                            font.pixelSize: Theme.textSm
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: parent.usable
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: PowerProfiles.profile = modelData.profile
                                    }
                                }
                            }
                        }
                    }

                    // ----- sliders ---------------------------------------------------
                    GlassSlider {
                        Layout.fillWidth: true
                        icon: Audio.icon
                        value: Audio.muted ? 0 : Audio.volume
                        onMoved: (value) => Audio.setVolume(value)
                    }

                    GlassSlider {
                        Layout.fillWidth: true
                        visible: Brightness.available
                        icon: "brightness_6"
                        value: Brightness.value
                        onMoved: (value) => Brightness.setValue(value)
                    }

                    // ----- media -----------------------------------------------------
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 72
                        visible: Media.active
                        radius: Theme.tileRadius
                        color: Theme.hover

                        ClippingRectangle {
                            id: art
                            x: 10
                            anchors.verticalCenter: parent.verticalCenter
                            width: 52
                            height: 52
                            radius: 10
                            color: Theme.hover

                            Image {
                                anchors.fill: parent
                                source: Media.art
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                visible: status === Image.Ready
                            }
                            Icon {
                                anchors.centerIn: parent
                                visible: Media.art.length === 0
                                name: "music_note"
                                size: 24
                                color: Theme.textDim
                            }
                        }

                        Column {
                            anchors.left: art.right
                            anchors.leftMargin: 12
                            anchors.right: controls.left
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                width: parent.width
                                text: Media.title
                                elide: Text.ElideRight
                                color: Theme.text
                                font.family: Theme.font
                                font.weight: Font.DemiBold
                                font.pixelSize: Theme.textMd
                            }
                            Text {
                                width: parent.width
                                text: Media.artist
                                elide: Text.ElideRight
                                color: Theme.textDim
                                font.family: Theme.font
                                font.pixelSize: Theme.textSm
                            }
                        }

                        Row {
                            id: controls
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            IconButton { icon: "skip_previous"; onClicked: Media.previous() }
                            IconButton {
                                icon: Media.playing ? "pause" : "play_arrow"
                                iconSize: 22
                                onClicked: Media.toggle()
                            }
                            IconButton { icon: "skip_next"; onClicked: Media.next() }
                        }
                    }

                    // ----- notifications ---------------------------------------------
                    RowLayout {
                        Layout.fillWidth: true
                        visible: Notifs.count > 0

                        Text {
                            Layout.fillWidth: true
                            text: "Notifications"
                            color: Theme.text
                            font.family: Theme.font
                            font.weight: Font.DemiBold
                            font.pixelSize: Theme.textMd
                        }

                        Text {
                            text: "Clear all"
                            color: Theme.accent
                            font.family: Theme.font
                            font.pixelSize: Theme.textSm

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -6
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Notifs.clearAll()
                            }
                        }
                    }

                    Repeater {
                        model: Notifs.list.slice().reverse().slice(0, 6)

                        delegate: NotificationCard {
                            required property var modelData
                            Layout.fillWidth: true
                            notification: modelData
                            background: Theme.hover
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        visible: Notifs.count === 0
                        horizontalAlignment: Text.AlignHCenter
                        text: "No notifications"
                        color: Theme.textFaint
                        font.family: Theme.font
                        font.pixelSize: Theme.textSm
                    }
                }
            }
        }
    }

    // A power action that asks for a second click within three seconds.
    component PowerButton: IconButton {
        id: button
        required property var command
        property bool armed: false

        active: armed
        color: armed ? Theme.danger : Theme.text
        onClicked: {
            if (armed) {
                Quickshell.execDetached(command);
                armed = false;
            } else {
                armed = true;
                disarm.restart();
            }
        }

        Timer {
            id: disarm
            interval: 3000
            onTriggered: button.armed = false
        }
    }
}
