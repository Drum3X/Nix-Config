import QtQuick
import Quickshell
import Quickshell.Bluetooth
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
// actions. The Wi-Fi and Bluetooth capsules grow into their menus. Notifications
// are in the Notification Center.
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
        // As tall as the controls, or an open menu (until it has shrunk back).
        implicitHeight: Math.min(screen.height - Theme.barExclusive - Theme.dockHeight - Theme.edge * 3,
                                 Math.max(content.implicitHeight, menuLoader.implicitHeight, menuHeight))
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

        // ----- Wi-Fi and Bluetooth menus --------------------------------
        // A capsule's glass grows into its menu, across the top of the panel,
        // while the other controls shrink away under it; it shrinks back the
        // same way.

        // The menu on the glass ("wifi", "bluetooth"); kept while it shrinks back.
        property string menu: ""
        property bool menuOpen: false
        // The capsule it grows out of, in panel coordinates.
        property rect menuFrom: Qt.rect(0, 0, 0, 0)
        // 0: the capsule, 1: the menu.
        property real morph: 0
        readonly property real shrink: 1 - morph
        readonly property real controlsReveal: reveal * Math.max(0, 1 - morph * 2)
        // Eased when a section opens or closes in the open menu.
        property real menuHeight: menuLoader.implicitHeight
        Behavior on menuHeight {
            enabled: window.morph === 1
            NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
        }

        // `capsule` is the control it grows out of; "" closes it.
        function openMenu(which: string, capsule: Item): void {
            if (which) {
                const p = capsule.mapToItem(panel, 0, 0);
                menuFrom = Qt.rect(p.x, p.y, capsule.width, capsule.height);
                menu = which;
            }
            menuOpen = which !== "";
            morphAnim.stop();
            morphAnim.to = menuOpen ? 1 : 0;
            morphAnim.duration = menuOpen ? Theme.slideIn : 320;
            morphAnim.start();
        }

        // Opened on a menu from the bar: closing the menu closes the panel, as
        // there were no controls before it.
        property bool menuDirect: false

        // The capsule of a menu.
        function capsuleOf(which: string): Item {
            return which === "bluetooth" ? btPill : wifiPill;
        }

        // Escape: back to the controls, or closed if it was opened on the menu.
        function closeMenu(): void {
            if (menuDirect)
                Ui.controlScreen = "";
            else
                openMenu("", null);
        }

        Connections {
            target: root
            function onOpenChanged(): void {
                if (!root.open)
                    return;
                morphAnim.stop();
                window.morph = 0;
                window.menu = "";
                window.menuOpen = false;
                window.menuDirect = Ui.controlMenu !== "";
                // On a menu from the bar: already open, fading in with the panel.
                if (window.menuDirect) {
                    window.openMenu(Ui.controlMenu, window.capsuleOf(Ui.controlMenu));
                    morphAnim.complete();
                }
            }
        }

        // The bar's Wi-Fi item while the panel is already open.
        Connections {
            target: Ui
            function onControlMenuChanged(): void {
                if (!root.open || Ui.controlMenu === "")
                    return;
                window.menuDirect = true;
                window.openMenu(Ui.controlMenu, window.capsuleOf(Ui.controlMenu));
            }
        }

        readonly property var battery: UPower.displayDevice
        readonly property bool hasBattery: !!(battery && battery.isPresent && battery.isLaptopBattery)
        readonly property var adapter: Bluetooth.defaultAdapter
        readonly property bool btEnabled: adapter ? adapter.enabled : false
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

            Keys.onEscapePressed: {
                if (window.menuOpen)
                    window.closeMenu();
                else
                    Ui.controlScreen = "";
            }

            // A click beside an open menu closes the panel, as one outside it does.
            MouseArea {
                anchors.fill: parent
                enabled: window.menuOpen
                onClicked: Ui.controlScreen = ""
            }

            Flickable {
                anchors.fill: parent
                visible: window.morph < 1
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
                                id: wifiPill
                                reveal: window.controlsReveal
                                scale: window.shrink
                                icon: Net.wired ? "lan" : Net.wifiEnabled ? "wifi" : "wifi_off"
                                label: "Wi-Fi"
                                detail: Net.wired ? "Ethernet" : !Net.wifiEnabled ? "Off" : (Net.name || "Not Connected")
                                checked: Net.wifiEnabled
                                expandable: true
                                onToggled: Net.setWifi(!Net.wifiEnabled)
                                onDetailsRequested: window.openMenu("wifi", wifiPill)
                            }

                            CcPill {
                                id: btPill
                                reveal: window.controlsReveal
                                scale: window.shrink
                                icon: window.btConnected.length > 0 ? "bluetooth_connected"
                                    : window.btEnabled ? "bluetooth" : "bluetooth_disabled"
                                label: "Bluetooth"
                                detail: !window.adapter ? "Unavailable" : !window.btEnabled ? "Off"
                                    : window.btConnected.length > 0 ? window.btConnected.map((d) => d.name).join(", ") : "On"
                                checked: window.btEnabled
                                expandable: !!window.adapter
                                onToggled: if (window.adapter) window.adapter.enabled = !window.adapter.enabled
                                onDetailsRequested: window.openMenu("bluetooth", btPill)
                            }
                        }

                        NowPlaying { reveal: window.controlsReveal; scale: window.shrink }
                    }

                    // ----- Focus, Appearance, Energy, battery --------------------
                    Row {
                        spacing: Theme.ccGap

                        CcCircle {
                            reveal: window.controlsReveal
                            scale: window.shrink
                            icon: "dark_mode"
                            checked: Notifs.doNotDisturb
                            onClicked: Notifs.doNotDisturb = !Notifs.doNotDisturb
                        }

                        CcCircle {
                            reveal: window.controlsReveal
                            scale: window.shrink
                            icon: "contrast"
                            checked: Theme.dark
                            onClicked: ThemeState.toggle()
                        }

                        CcCircle {
                            reveal: window.controlsReveal
                            scale: window.shrink
                            icon: window.profiles[window.profileIndex].icon
                            checked: PowerProfiles.profile !== PowerProfile.Balanced
                            onClicked: window.nextProfile()
                        }

                        CcCircle {
                            reveal: window.controlsReveal
                            scale: window.shrink
                            interactive: false
                            icon: !window.hasBattery ? "power"
                                : window.battery.state === UPowerDeviceState.Charging ? "battery_charging_full" : "battery_full"
                            label: window.hasBattery ? Math.round(window.battery.percentage * 100) + "%" : "AC"
                        }
                    }

                    // ----- Display / Sound ---------------------------------------
                    CcSlider {
                        reveal: window.controlsReveal
                        scale: window.shrink
                        width: parent.width
                        visible: Brightness.available
                        title: "Display"
                        iconLow: "brightness_low"
                        iconHigh: "brightness_high"
                        value: Brightness.value
                        onMoved: (value) => Brightness.setValue(value)
                    }

                    CcSlider {
                        reveal: window.controlsReveal
                        scale: window.shrink
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

                        PowerCircle { reveal: window.controlsReveal; scale: window.shrink; icon: "lock"; confirm: false; onRun: Lock.lock() }
                        PowerCircle { reveal: window.controlsReveal; scale: window.shrink; icon: "logout"; onRun: Quickshell.execDetached(["shoji_wm", "--quit"]) }
                        PowerCircle { reveal: window.controlsReveal; scale: window.shrink; icon: "restart_alt"; onRun: Quickshell.execDetached(["systemctl", "reboot"]) }
                        PowerCircle { reveal: window.controlsReveal; scale: window.shrink; icon: "power_settings_new"; onRun: Quickshell.execDetached(["systemctl", "poweroff"]) }
                    }
                }
            }

            // The open menu, on the glass the capsule grows into.
            GlassPanel {
                id: menuGlass
                readonly property real m: window.morph
                readonly property rect from: window.menuFrom

                visible: window.menu !== ""
                x: from.x * (1 - m)
                y: from.y * (1 - m)
                width: from.width + (panel.width - from.width) * m
                height: from.height + (Math.min(panel.height, window.menuHeight) - from.height) * m
                radius: from.height / 2 + (26 - from.height / 2) * m
                reveal: window.reveal
                clip: true

                // Clicks on the menu stay in it.
                MouseArea { anchors.fill: parent }

                Flickable {
                    width: panel.width
                    height: menuGlass.height
                    contentHeight: menuLoader.implicitHeight
                    interactive: contentHeight > height
                    boundsBehavior: Flickable.StopAtBounds
                    opacity: Math.max(0, (menuGlass.m - 0.3) / 0.7)

                    Loader {
                        id: menuLoader
                        width: panel.width
                        sourceComponent: window.menu === "wifi" ? wifiMenu
                            : window.menu === "bluetooth" ? bluetoothMenu : null
                    }
                }

                Component {
                    id: wifiMenu
                    WifiMenu { scanning: window.menuOpen && root.open }
                }
                Component {
                    id: bluetoothMenu
                    BluetoothMenu { scanning: window.menuOpen && root.open }
                }
            }

            NumberAnimation {
                id: morphAnim
                target: window
                property: "morph"
                easing.type: Easing.OutCubic
                onFinished: if (!window.menuOpen) window.menu = ""
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
