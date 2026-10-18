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

// The control center, laid out like macOS: a connectivity module (Wi-Fi,
// Bluetooth, Appearance) beside Focus and Energy tiles, then Display and
// Sound sliders, Now Playing, battery and power, and the notifications.
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
        implicitWidth: 340
        implicitHeight: Math.min(screen.height - Theme.barExclusive - Theme.dockHeight - Theme.edge * 3,
                                 content.implicitHeight + 24)
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

        readonly property var battery: UPower.displayDevice
        readonly property bool hasBattery: !!(battery && battery.isPresent && battery.isLaptopBattery)
        readonly property var adapter: Bluetooth.defaultAdapter
        readonly property var btConnected: Bluetooth.devices
            ? Bluetooth.devices.values.filter((d) => d.connected) : []

        readonly property var profiles: [
            { profile: PowerProfile.PowerSaver, icon: "eco", label: "Low Power" },
            { profile: PowerProfile.Balanced, icon: "balance", label: "Automatic" },
            { profile: PowerProfile.Performance, icon: "bolt", label: "High Power" }
        ]
        readonly property int profileIndex: Math.max(0, profiles.findIndex((p) => p.profile === PowerProfiles.profile))

        function nextProfile(): void {
            let next = (profileIndex + 1) % profiles.length;
            if (profiles[next].profile === PowerProfile.Performance && !PowerProfiles.hasPerformanceProfile)
                next = (next + 1) % profiles.length;
            PowerProfiles.profile = profiles[next].profile;
        }

        GlassPanel {
            id: panel
            anchors.fill: parent
            radius: 26
            focus: true

            opacity: root.open ? 1 : 0
            scale: root.open ? 1 : 0.97
            transformOrigin: Item.TopRight
            Behavior on opacity { NumberAnimation { duration: Theme.normal; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: Theme.normal; easing.type: Easing.OutCubic } }

            Keys.onEscapePressed: Ui.controlScreen = ""

            Flickable {
                anchors.fill: parent
                anchors.margins: 12
                contentHeight: content.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: content
                    width: parent.width
                    spacing: 10

                    // ----- connectivity + Focus / Energy --------------------------
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        CcModule {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            Layout.alignment: Qt.AlignTop

                            Column {
                                width: parent.width
                                spacing: 12

                                CircleToggle {
                                    width: parent.width
                                    icon: Net.wired ? "lan" : Net.wifiEnabled ? "wifi" : "wifi_off"
                                    label: "Wi-Fi"
                                    detail: Net.wired ? "Ethernet" : !Net.wifiEnabled ? "Off" : (Net.name || "Not Connected")
                                    checked: Net.wifiEnabled
                                    expandable: true
                                    onToggled: Net.setWifi(!Net.wifiEnabled)
                                    onDetailsRequested: {
                                        window.wifiExpanded = !window.wifiExpanded;
                                        Net.scan(window.wifiExpanded);
                                    }
                                }

                                CircleToggle {
                                    width: parent.width
                                    icon: "bluetooth"
                                    label: "Bluetooth"
                                    detail: !window.adapter ? "Unavailable" : !window.adapter.enabled ? "Off"
                                        : window.btConnected.length > 0 ? window.btConnected.map((d) => d.name).join(", ") : "On"
                                    checked: window.adapter ? window.adapter.enabled : false
                                    onToggled: if (window.adapter) window.adapter.enabled = !window.adapter.enabled
                                }

                                CircleToggle {
                                    width: parent.width
                                    icon: "contrast"
                                    label: "Appearance"
                                    detail: Theme.dark ? "Dark" : "Light"
                                    checked: Theme.dark
                                    onToggled: ThemeState.toggle()
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            Layout.fillHeight: true
                            spacing: 10

                            CcModule {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                CircleToggle {
                                    width: parent.width
                                    icon: "do_not_disturb_on"
                                    label: "Focus"
                                    detail: Notifs.doNotDisturb ? "Do Not Disturb" : "Off"
                                    checked: Notifs.doNotDisturb
                                    onToggled: Notifs.doNotDisturb = !Notifs.doNotDisturb
                                }
                            }

                            CcModule {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                CircleToggle {
                                    width: parent.width
                                    icon: window.profiles[window.profileIndex].icon
                                    label: "Energy Mode"
                                    detail: window.profiles[window.profileIndex].label
                                    checked: PowerProfiles.profile !== PowerProfile.Balanced
                                    onToggled: window.nextProfile()
                                }
                            }
                        }
                    }

                    // ----- Wi-Fi networks ------------------------------------------
                    CcModule {
                        Layout.fillWidth: true
                        visible: window.wifiExpanded && Net.wifiEnabled
                        title: "Wi-Fi"
                        padding: 8

                        Column {
                            width: parent.width
                            spacing: 2

                            Repeater {
                                model: Net.networks.slice(0, 8)

                                delegate: Item {
                                    id: netRow
                                    required property var modelData
                                    width: parent.width
                                    height: window.pskNetwork === modelData ? 74 : 34

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 10
                                        color: netMouse.containsMouse ? Theme.hover : "transparent"
                                    }

                                    Rectangle {
                                        id: netIcon
                                        x: 6
                                        y: 5
                                        width: 24
                                        height: 24
                                        radius: 12
                                        color: netRow.modelData.connected ? Theme.accent : Theme.buttonOff

                                        Icon {
                                            anchors.centerIn: parent
                                            name: netRow.modelData.signalStrength > 0.66 ? "wifi"
                                                : netRow.modelData.signalStrength > 0.33 ? "wifi_2_bar" : "wifi_1_bar"
                                            size: 14
                                            filled: true
                                            color: netRow.modelData.connected ? "#ffffff" : Theme.text
                                        }
                                    }

                                    Text {
                                        anchors.left: netIcon.right
                                        anchors.leftMargin: 10
                                        anchors.right: lock.left
                                        anchors.rightMargin: 6
                                        y: 9
                                        text: netRow.modelData.name
                                            + (netRow.modelData.stateChanging ? "  ·  Connecting…" : "")
                                        elide: Text.ElideRight
                                        color: Theme.text
                                        font.family: Theme.font
                                        font.pixelSize: Theme.textSm
                                    }

                                    Icon {
                                        id: lock
                                        anchors.right: parent.right
                                        anchors.rightMargin: 8
                                        y: 9
                                        visible: netRow.modelData.security !== WifiSecurityType.Open
                                        name: "lock"
                                        size: 14
                                        color: Theme.textDim
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
                                        height: 32
                                        radius: 10
                                        color: Theme.sliderTrack

                                        TextInput {
                                            id: psk
                                            anchors.fill: parent
                                            anchors.leftMargin: 10
                                            anchors.rightMargin: 10
                                            verticalAlignment: TextInput.AlignVCenter
                                            echoMode: TextInput.Password
                                            color: Theme.text
                                            font.family: Theme.font
                                            font.pixelSize: Theme.textSm
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
                    }

                    // ----- Display / Sound ---------------------------------------------
                    CcModule {
                        Layout.fillWidth: true
                        visible: Brightness.available
                        title: "Display"

                        GlassSlider {
                            width: parent.width
                            icon: "light_mode"
                            value: Brightness.value
                            onMoved: (value) => Brightness.setValue(value)
                        }
                    }

                    CcModule {
                        Layout.fillWidth: true
                        title: "Sound"

                        GlassSlider {
                            width: parent.width
                            icon: Audio.muted ? "volume_off" : "volume_up"
                            value: Audio.muted ? 0 : Audio.volume
                            onMoved: (value) => Audio.setVolume(value)
                        }
                    }

                    // ----- Now Playing ------------------------------------------------
                    CcModule {
                        Layout.fillWidth: true
                        visible: Media.active

                        Item {
                            width: parent.width
                            height: 48

                            ClippingRectangle {
                                id: art
                                width: 48
                                height: 48
                                radius: 10
                                color: Theme.buttonOff

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
                                    size: 22
                                    color: Theme.textDim
                                }
                            }

                            Column {
                                anchors.left: art.right
                                anchors.leftMargin: 10
                                anchors.right: controls.left
                                anchors.rightMargin: 6
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 1

                                Text {
                                    width: parent.width
                                    text: Media.title
                                    elide: Text.ElideRight
                                    color: Theme.text
                                    font.family: Theme.font
                                    font.weight: Font.DemiBold
                                    font.pixelSize: Theme.textSm
                                }
                                Text {
                                    width: parent.width
                                    text: Media.artist
                                    elide: Text.ElideRight
                                    color: Theme.textDim
                                    font.family: Theme.font
                                    font.pixelSize: Theme.textXs
                                }
                            }

                            Row {
                                id: controls
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                IconButton { icon: "fast_rewind"; onClicked: Media.previous() }
                                IconButton {
                                    icon: Media.playing ? "pause" : "play_arrow"
                                    iconSize: 24
                                    onClicked: Media.toggle()
                                }
                                IconButton { icon: "fast_forward"; onClicked: Media.next() }
                            }
                        }
                    }

                    // ----- battery and power ------------------------------------------
                    CcModule {
                        Layout.fillWidth: true
                        padding: 8

                        Item {
                            width: parent.width
                            height: 30

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 4
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 6
                                visible: window.hasBattery

                                Icon {
                                    anchors.verticalCenter: parent.verticalCenter
                                    name: window.hasBattery && window.battery.state === UPowerDeviceState.Charging
                                        ? "battery_charging_full" : "battery_full"
                                    size: 18
                                    filled: true
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: window.hasBattery ? Math.round(window.battery.percentage * 100) + "%" : ""
                                    color: Theme.text
                                    font.family: Theme.font
                                    font.weight: Font.Medium
                                    font.pixelSize: Theme.textSm
                                }
                            }

                            Row {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 6

                                PowerButton { icon: "lock"; confirm: false; onRun: Lock.lock() }
                                PowerButton { icon: "logout"; onRun: Quickshell.execDetached(["shoji_wm", "--quit"]) }
                                PowerButton { icon: "restart_alt"; onRun: Quickshell.execDetached(["systemctl", "reboot"]) }
                                PowerButton { icon: "power_settings_new"; onRun: Quickshell.execDetached(["systemctl", "poweroff"]) }
                            }
                        }
                    }

                    // ----- notifications ----------------------------------------------
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 4
                        Layout.rightMargin: 4
                        visible: Notifs.count > 0

                        Text {
                            Layout.fillWidth: true
                            text: "Notifications"
                            color: Theme.text
                            font.family: Theme.font
                            font.weight: Font.DemiBold
                            font.pixelSize: Theme.textSm
                        }

                        Text {
                            text: "Clear"
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
                            background: Theme.module
                        }
                    }
                }
            }
        }
    }

    // A round power action; all but lock ask for a second click within three seconds.
    component PowerButton: Item {
        id: button
        property string icon: ""
        property bool confirm: true
        property bool armed: false
        signal run()

        width: 30
        height: 30

        Rectangle {
            anchors.fill: parent
            radius: 15
            color: button.armed ? Theme.danger : mouse.containsMouse ? Theme.pressed : Theme.buttonOff
            Behavior on color { ColorAnimation { duration: Theme.fast } }
        }

        Icon {
            anchors.centerIn: parent
            name: button.icon
            size: 16
            color: button.armed ? "#ffffff" : Theme.text
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (!button.confirm || button.armed) {
                    button.armed = false;
                    button.run();
                } else {
                    button.armed = true;
                    disarm.restart();
                }
            }
        }

        Timer {
            id: disarm
            interval: 3000
            onTriggered: button.armed = false
        }
    }
}
