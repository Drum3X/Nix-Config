import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.UPower
import Quickshell.Wayland
import Quickshell.Widgets
import qs.common
import qs.lock
import qs.services

// The control center, laid out like macOS Tahoe: no panel, every control is
// its own piece of glass on a grid of round cells (Theme.ccUnit). Wi-Fi and
// Focus are capsules, Now Playing a square; Bluetooth, Appearance, Energy and
// the battery are circles; then the Display and Sound sliders, the session
// actions and the notifications.
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
        margins.top: Theme.barExclusive
        margins.right: Theme.edge
        implicitWidth: window.span(4)
        implicitHeight: Math.min(screen.height - Theme.barExclusive - Theme.dockHeight - Theme.edge * 3,
                                 content.implicitHeight)
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "hyalo-control"
        WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        mask: Region { item: panel }

        // Width of `cells` grid cells and the gaps between them.
        function span(cells: int): real {
            return Theme.ccUnit * cells + Theme.ccGap * (cells - 1);
        }

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

        Item {
            id: panel
            anchors.fill: parent
            focus: true

            opacity: root.open ? 1 : 0
            scale: root.open ? 1 : 0.97
            transformOrigin: Item.TopRight
            Behavior on opacity { NumberAnimation { duration: Theme.normal; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: Theme.normal; easing.type: Easing.OutCubic } }

            Keys.onEscapePressed: Ui.controlScreen = ""

            Flickable {
                anchors.fill: parent
                contentHeight: content.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: content
                    width: parent.width
                    spacing: Theme.ccGap

                    // ----- Wi-Fi, Bluetooth, Appearance | Now Playing ------------
                    Row {
                        spacing: Theme.ccGap

                        Column {
                            spacing: Theme.ccGap

                            CcPill {
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

                            Row {
                                spacing: Theme.ccGap

                                CcCircle {
                                    icon: "bluetooth"
                                    checked: window.adapter ? window.adapter.enabled : false
                                    interactive: !!window.adapter
                                    onClicked: window.adapter.enabled = !window.adapter.enabled
                                }

                                CcCircle {
                                    icon: "contrast"
                                    checked: Theme.dark
                                    onClicked: ThemeState.toggle()
                                }
                            }
                        }

                        NowPlaying {}
                    }

                    // ----- Focus | Energy, battery -------------------------------
                    Row {
                        spacing: Theme.ccGap

                        CcPill {
                            icon: "dark_mode"
                            label: "Focus"
                            detail: Notifs.doNotDisturb ? "Do Not Disturb" : ""
                            checked: Notifs.doNotDisturb
                            onToggled: Notifs.doNotDisturb = !Notifs.doNotDisturb
                        }

                        CcCircle {
                            icon: window.profiles[window.profileIndex].icon
                            checked: PowerProfiles.profile !== PowerProfile.Balanced
                            onClicked: window.nextProfile()
                        }

                        CcCircle {
                            interactive: false
                            icon: !window.hasBattery ? "power"
                                : window.battery.state === UPowerDeviceState.Charging ? "battery_charging_full" : "battery_full"
                            label: window.hasBattery ? Math.round(window.battery.percentage * 100) + "%" : "AC"
                        }
                    }

                    // ----- Wi-Fi networks ----------------------------------------
                    GlassPanel {
                        width: parent.width
                        height: networks.implicitHeight + 16
                        radius: 26
                        visible: window.wifiExpanded && Net.wifiEnabled

                        Column {
                            id: networks
                            x: 8
                            y: 8
                            width: parent.width - 16
                            spacing: 2

                            Text {
                                x: 8
                                height: 26
                                verticalAlignment: Text.AlignVCenter
                                text: "Wi-Fi"
                                color: Theme.text
                                font.family: Theme.font
                                font.weight: Font.DemiBold
                                font.pixelSize: Theme.textMd
                            }

                            Repeater {
                                model: Net.networks.slice(0, 8)

                                delegate: Item {
                                    id: netRow
                                    required property var modelData
                                    width: parent.width
                                    height: window.pskNetwork === modelData ? 74 : 34

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 17
                                        color: netMouse.containsMouse ? Theme.hover : "transparent"
                                    }

                                    Rectangle {
                                        id: netIcon
                                        x: 6
                                        y: 5
                                        width: 24
                                        height: 24
                                        radius: 12
                                        color: netRow.modelData.connected ? "#ffffff" : Theme.buttonOff

                                        Icon {
                                            anchors.centerIn: parent
                                            name: netRow.modelData.signalStrength > 0.66 ? "wifi"
                                                : netRow.modelData.signalStrength > 0.33 ? "wifi_2_bar" : "wifi_1_bar"
                                            size: 14
                                            filled: true
                                            color: netRow.modelData.connected ? Theme.accent : Theme.text
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
                                        anchors.rightMargin: 10
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
                                        radius: 16
                                        color: Theme.sliderTrack

                                        TextInput {
                                            id: psk
                                            anchors.fill: parent
                                            anchors.leftMargin: 12
                                            anchors.rightMargin: 12
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

                    // ----- Display / Sound ---------------------------------------
                    CcSlider {
                        width: parent.width
                        visible: Brightness.available
                        title: "Display"
                        iconLow: "brightness_low"
                        iconHigh: "brightness_high"
                        value: Brightness.value
                        onMoved: (value) => Brightness.setValue(value)
                    }

                    CcSlider {
                        width: parent.width
                        title: "Sound"
                        iconLow: Audio.muted ? "volume_off" : "volume_mute"
                        iconHigh: "volume_up"
                        value: Audio.muted ? 0 : Audio.volume
                        onMoved: (value) => Audio.setVolume(value)
                    }

                    // ----- session -----------------------------------------------
                    Row {
                        spacing: Theme.ccGap

                        PowerCircle { icon: "lock"; confirm: false; onRun: Lock.lock() }
                        PowerCircle { icon: "logout"; onRun: Quickshell.execDetached(["shoji_wm", "--quit"]) }
                        PowerCircle { icon: "restart_alt"; onRun: Quickshell.execDetached(["systemctl", "reboot"]) }
                        PowerCircle { icon: "power_settings_new"; onRun: Quickshell.execDetached(["systemctl", "poweroff"]) }
                    }

                    // ----- notifications -----------------------------------------
                    Item {
                        width: parent.width
                        height: 22
                        visible: Notifs.count > 0

                        Text {
                            x: 6
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Notifications"
                            color: Theme.text
                            font.family: Theme.font
                            font.weight: Font.DemiBold
                            font.pixelSize: Theme.textSm
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
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

                        delegate: GlassPanel {
                            id: card
                            required property var modelData
                            width: content.width
                            height: notification.implicitHeight
                            radius: Theme.panelRadius

                            NotificationCard {
                                id: notification
                                anchors.fill: parent
                                notification: card.modelData
                            }
                        }
                    }
                }
            }
        }
    }

    // Now Playing: a square of glass two cells wide, with the cover, the
    // track and the transport controls; "Not Playing" without a player.
    component NowPlaying: GlassPanel {
        width: Theme.ccUnit * 2 + Theme.ccGap
        height: Theme.ccUnit * 2 + Theme.ccGap
        radius: 28

        ClippingRectangle {
            id: art
            x: 14
            y: 14
            width: 44
            height: 44
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
            x: 14
            anchors.top: art.bottom
            anchors.topMargin: 8
            width: parent.width - 28

            Text {
                width: parent.width
                text: Media.active ? Media.title : "Not Playing"
                elide: Text.ElideRight
                color: Theme.text
                font.family: Theme.font
                font.weight: Font.DemiBold
                font.pixelSize: Theme.textMd
            }
            Text {
                width: parent.width
                visible: text.length > 0
                text: Media.active ? Media.artist : ""
                elide: Text.ElideRight
                color: Theme.textDim
                font.family: Theme.font
                font.pixelSize: Theme.textSm
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            spacing: 2
            enabled: Media.active
            opacity: Media.active ? 1 : 0.4

            IconButton { icon: "fast_rewind"; iconSize: 24; active: true; color: Theme.text; onClicked: Media.previous() }
            IconButton {
                icon: Media.playing ? "pause" : "play_arrow"
                iconSize: 28
                active: true
                color: Theme.text
                onClicked: Media.toggle()
            }
            IconButton { icon: "fast_forward"; iconSize: 24; active: true; color: Theme.text; onClicked: Media.next() }
        }
    }

    // A session action; all but lock ask for a second click within three seconds.
    component PowerCircle: CcCircle {
        id: button
        property bool confirm: true
        property bool armed: false
        signal run()

        alert: armed
        onClicked: {
            if (!button.confirm || button.armed) {
                button.armed = false;
                button.run();
            } else {
                button.armed = true;
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
