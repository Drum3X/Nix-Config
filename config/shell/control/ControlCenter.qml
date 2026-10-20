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
// the battery are circles; then the Display and Sound sliders and the session
// actions. Notifications are in the Notification Center.
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
        visible: motion.shown

        PanelMotion {
            id: motion
            open: root.open
            namespace: "hyalo-control"
        }
        // The content of every piece of glass fades with the panel.
        readonly property real reveal: motion.fade

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

        // The list open under the toggles: "", "wifi" or "bluetooth".
        property string expanded: ""
        property var pskNetwork: null

        Connections {
            target: root
            function onOpenChanged(): void {
                window.expand("");
            }
        }

        readonly property var battery: UPower.displayDevice
        readonly property bool hasBattery: !!(battery && battery.isPresent && battery.isLaptopBattery)
        readonly property var adapter: Bluetooth.defaultAdapter
        readonly property bool btEnabled: adapter ? adapter.enabled : false
        readonly property var btConnected: Bluetooth.devices
            ? Bluetooth.devices.values.filter((d) => d.connected) : []
        // Paired devices first, then the ones found by scanning, unnamed ones left out.
        readonly property var btDevices: Bluetooth.devices
            ? Bluetooth.devices.values.filter((d) => d.paired || d.name.length > 0)
                .sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name))
            : []

        // Opens one list (or none), scanning for what it shows while it is open.
        function expand(which: string): void {
            expanded = which;
            pskNetwork = null;
            Net.scan(which === "wifi");
            if (adapter && adapter.enabled)
                adapter.discovering = which === "bluetooth";
        }

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
                                reveal: window.reveal
                                icon: Net.wired ? "lan" : Net.wifiEnabled ? "wifi" : "wifi_off"
                                label: "Wi-Fi"
                                detail: Net.wired ? "Ethernet" : !Net.wifiEnabled ? "Off" : (Net.name || "Not Connected")
                                checked: Net.wifiEnabled
                                expandable: true
                                onToggled: Net.setWifi(!Net.wifiEnabled)
                                onDetailsRequested: window.expand(window.expanded === "wifi" ? "" : "wifi")
                            }

                            CcPill {
                                reveal: window.reveal
                                icon: window.btConnected.length > 0 ? "bluetooth_connected"
                                    : window.btEnabled ? "bluetooth" : "bluetooth_disabled"
                                label: "Bluetooth"
                                detail: !window.adapter ? "Unavailable" : !window.btEnabled ? "Off"
                                    : window.btConnected.length > 0 ? window.btConnected.map((d) => d.name).join(", ") : "On"
                                checked: window.btEnabled
                                expandable: !!window.adapter
                                onToggled: if (window.adapter) window.adapter.enabled = !window.adapter.enabled
                                onDetailsRequested: window.expand(window.expanded === "bluetooth" ? "" : "bluetooth")
                            }
                        }

                        NowPlaying { reveal: window.reveal }
                    }

                    // ----- Focus, Appearance, Energy, battery --------------------
                    Row {
                        spacing: Theme.ccGap

                        CcCircle {
                            reveal: window.reveal
                            icon: "dark_mode"
                            checked: Notifs.doNotDisturb
                            onClicked: Notifs.doNotDisturb = !Notifs.doNotDisturb
                        }

                        CcCircle {
                            reveal: window.reveal
                            icon: "contrast"
                            checked: Theme.dark
                            onClicked: ThemeState.toggle()
                        }

                        CcCircle {
                            reveal: window.reveal
                            icon: window.profiles[window.profileIndex].icon
                            checked: PowerProfiles.profile !== PowerProfile.Balanced
                            onClicked: window.nextProfile()
                        }

                        CcCircle {
                            reveal: window.reveal
                            interactive: false
                            icon: !window.hasBattery ? "power"
                                : window.battery.state === UPowerDeviceState.Charging ? "battery_charging_full" : "battery_full"
                            label: window.hasBattery ? Math.round(window.battery.percentage * 100) + "%" : "AC"
                        }
                    }

                    // ----- Wi-Fi networks ----------------------------------------
                    GlassPanel {
                        reveal: window.reveal
                        width: parent.width
                        height: networks.implicitHeight + 16
                        radius: 30
                        visible: window.expanded === "wifi" && Net.wifiEnabled

                        Column {
                            id: networks
                            x: 8
                            y: 8
                            width: parent.width - 16
                            spacing: 2

                            CcText {
                                x: 8
                                height: 26
                                verticalAlignment: Text.AlignVCenter
                                text: "Wi-Fi"
                                color: Theme.cc.text
                                font.family: Theme.font
                                font.styleName: "Semibold"
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
                                        color: netMouse.pressed ? Theme.cc.pressed : netMouse.containsMouse ? Theme.cc.hover : Theme.clear
                                        Behavior on color { ColorAnimation { duration: Theme.fast } }
                                    }

                                    Rectangle {
                                        id: netIcon
                                        x: 6
                                        y: 5
                                        width: 24
                                        height: 24
                                        radius: 12
                                        color: netRow.modelData.connected ? "#ffffff" : Theme.cc.buttonOff

                                        Icon {
                                            anchors.centerIn: parent
                                            name: netRow.modelData.signalStrength > 0.66 ? "wifi"
                                                : netRow.modelData.signalStrength > 0.33 ? "wifi_2_bar" : "wifi_1_bar"
                                            size: 14
                                            filled: true
                                            color: netRow.modelData.connected ? Theme.cc.accent : Theme.cc.text
                                        }
                                    }

                                    CcText {
                                        anchors.left: netIcon.right
                                        anchors.leftMargin: 10
                                        anchors.right: lock.left
                                        anchors.rightMargin: 6
                                        y: 9
                                        text: netRow.modelData.name
                                            + (netRow.modelData.stateChanging ? "  ·  Connecting…" : "")
                                        elide: Text.ElideRight
                                        color: Theme.cc.text
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
                                        color: Theme.cc.textDim
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
                                        color: Theme.cc.sliderTrack

                                        TextInput {
                                            id: psk
                                            anchors.fill: parent
                                            anchors.leftMargin: 12
                                            anchors.rightMargin: 12
                                            verticalAlignment: TextInput.AlignVCenter
                                            echoMode: TextInput.Password
                                            color: Theme.cc.text
                                            font.family: Theme.font
                                            font.pixelSize: Theme.textSm
                                            onVisibleChanged: if (visible) { text = ""; forceActiveFocus(); }
                                            onAccepted: {
                                                netRow.modelData.connectWithPsk(text);
                                                window.pskNetwork = null;
                                            }
                                            Keys.onEscapePressed: window.pskNetwork = null

                                            CcText {
                                                anchors.verticalCenter: parent.verticalCenter
                                                visible: psk.text.length === 0
                                                text: "Password"
                                                color: Theme.cc.textFaint
                                                font: psk.font
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ----- Bluetooth devices -------------------------------------
                    GlassPanel {
                        reveal: window.reveal
                        width: parent.width
                        height: devices.implicitHeight + 16
                        radius: 30
                        visible: window.expanded === "bluetooth" && window.btEnabled

                        Column {
                            id: devices
                            x: 8
                            y: 8
                            width: parent.width - 16
                            spacing: 2

                            Item {
                                width: parent.width
                                height: 26

                                CcText {
                                    x: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Bluetooth"
                                    color: Theme.cc.text
                                    font.family: Theme.font
                                    font.styleName: "Semibold"
                                    font.pixelSize: Theme.textMd
                                }
                                CcText {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: window.adapter ? window.adapter.discovering : false
                                    text: "Searching…"
                                    color: Theme.cc.textDim
                                    font.family: Theme.font
                                    font.pixelSize: Theme.textXs
                                }
                            }

                            CcText {
                                x: 8
                                height: 30
                                visible: window.btDevices.length === 0
                                verticalAlignment: Text.AlignVCenter
                                text: "No devices"
                                color: Theme.cc.textDim
                                font.family: Theme.font
                                font.pixelSize: Theme.textSm
                            }

                            Repeater {
                                model: window.btDevices.slice(0, 8)

                                delegate: Item {
                                    id: devRow
                                    required property var modelData
                                    readonly property bool busy: modelData.state === BluetoothDeviceState.Connecting
                                        || modelData.state === BluetoothDeviceState.Disconnecting || modelData.pairing
                                    width: parent.width
                                    height: 34

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 17
                                        color: devMouse.pressed ? Theme.cc.pressed : devMouse.containsMouse ? Theme.cc.hover : Theme.clear
                                        Behavior on color { ColorAnimation { duration: Theme.fast } }
                                    }

                                    Rectangle {
                                        id: devIcon
                                        x: 6
                                        y: 5
                                        width: 24
                                        height: 24
                                        radius: 12
                                        color: devRow.modelData.connected ? "#ffffff" : Theme.cc.buttonOff

                                        Icon {
                                            anchors.centerIn: parent
                                            name: (devRow.modelData.icon || "").indexOf("audio") >= 0 ? "headphones"
                                                : (devRow.modelData.icon || "").indexOf("input-mouse") >= 0 ? "mouse"
                                                : (devRow.modelData.icon || "").indexOf("input-keyboard") >= 0 ? "keyboard"
                                                : (devRow.modelData.icon || "").indexOf("phone") >= 0 ? "smartphone"
                                                : "bluetooth"
                                            size: 14
                                            filled: true
                                            color: devRow.modelData.connected ? Theme.cc.accent : Theme.cc.text
                                        }
                                    }

                                    CcText {
                                        anchors.left: devIcon.right
                                        anchors.leftMargin: 10
                                        anchors.right: devState.left
                                        anchors.rightMargin: 6
                                        y: 9
                                        text: devRow.modelData.name
                                        elide: Text.ElideRight
                                        color: Theme.cc.text
                                        font.family: Theme.font
                                        font.pixelSize: Theme.textSm
                                    }

                                    CcText {
                                        id: devState
                                        anchors.right: parent.right
                                        anchors.rightMargin: 10
                                        y: 10
                                        text: devRow.busy ? "…"
                                            : devRow.modelData.connected && devRow.modelData.batteryAvailable
                                                ? Math.round(devRow.modelData.battery * 100) + "%"
                                            : devRow.modelData.connected ? "Connected"
                                            : devRow.modelData.paired ? "" : "Pair"
                                        color: devRow.modelData.paired || devRow.busy ? Theme.cc.textDim : Theme.cc.accent
                                        font.family: Theme.font
                                        font.pixelSize: Theme.textXs
                                    }

                                    MouseArea {
                                        id: devMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            const device = devRow.modelData;
                                            if (devRow.busy)
                                                return;
                                            if (device.connected) {
                                                device.disconnect();
                                            } else if (device.paired) {
                                                device.connect();
                                            } else {
                                                device.trusted = true;
                                                device.pair();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ----- Display / Sound ---------------------------------------
                    CcSlider {
                        reveal: window.reveal
                        width: parent.width
                        visible: Brightness.available
                        title: "Display"
                        iconLow: "brightness_low"
                        iconHigh: "brightness_high"
                        value: Brightness.value
                        onMoved: (value) => Brightness.setValue(value)
                    }

                    CcSlider {
                        reveal: window.reveal
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

                        PowerCircle { reveal: window.reveal; icon: "lock"; confirm: false; onRun: Lock.lock() }
                        PowerCircle { reveal: window.reveal; icon: "logout"; onRun: Quickshell.execDetached(["shoji_wm", "--quit"]) }
                        PowerCircle { reveal: window.reveal; icon: "restart_alt"; onRun: Quickshell.execDetached(["systemctl", "reboot"]) }
                        PowerCircle { reveal: window.reveal; icon: "power_settings_new"; onRun: Quickshell.execDetached(["systemctl", "poweroff"]) }
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
        radius: 32

        ClippingRectangle {
            id: art
            x: 16
            y: 16
            width: 52
            height: 52
            radius: 10
            color: Theme.cc.buttonOff

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
                color: Theme.cc.textDim
            }
        }

        Column {
            x: 16
            anchors.top: art.bottom
            anchors.topMargin: 10
            width: parent.width - 32

            CcText {
                width: parent.width
                text: Media.active ? Media.title : "Not Playing"
                elide: Text.ElideRight
                color: Theme.cc.text
                font.family: Theme.font
                font.styleName: "Semibold"
                font.pixelSize: Theme.textMd
            }
            CcText {
                width: parent.width
                visible: text.length > 0
                text: Media.active ? Media.artist : ""
                elide: Text.ElideRight
                color: Theme.cc.textDim
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

            IconButton { icon: "fast_rewind"; iconSize: 24; active: true; colors: Theme.cc; color: Theme.cc.text; onClicked: Media.previous() }
            IconButton {
                icon: Media.playing ? "pause" : "play_arrow"
                iconSize: 28
                active: true
                colors: Theme.cc
                color: Theme.cc.text
                onClicked: Media.toggle()
            }
            IconButton { icon: "fast_forward"; iconSize: 24; active: true; colors: Theme.cc; color: Theme.cc.text; onClicked: Media.next() }
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
