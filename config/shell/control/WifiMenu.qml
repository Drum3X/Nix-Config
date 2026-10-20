import QtQuick
import Quickshell.Networking
import qs.common
import qs.services

// The Wi-Fi menu, as on macOS: the switch, the known networks in range, then
// the other networks under a chevron. A secured network not known yet asks
// for its password under its row.
CcMenu {
    id: root

    property bool showOthers: false
    property var pskNetwork: null

    readonly property var known: Net.networks.filter((n) => n.known || n.connected)
        .sort((a, b) => (b.connected - a.connected) || (b.signalStrength - a.signalStrength))
    readonly property var others: Net.networks.filter((n) => !n.known && !n.connected && n.name.length > 0)

    title: "Wi-Fi"
    checked: Net.wifiEnabled
    onToggled: Net.setWifi(!Net.wifiEnabled)

    readonly property bool scan: scanning && Net.wifiEnabled
    onScanChanged: Net.scan(scan)
    Component.onDestruction: Net.scan(false)

    MenuSection {
        visible: Net.wifiEnabled && root.known.length > 0
        text: "Known Networks"
    }

    Repeater {
        model: Net.wifiEnabled ? root.known : []
        delegate: NetworkRow {}
    }

    MenuSection {
        visible: Net.wifiEnabled
        text: "Other Networks"
        expandable: true
        expanded: root.showOthers
        onClicked: root.showOthers = !root.showOthers
    }

    Repeater {
        model: Net.wifiEnabled && root.showOthers ? root.others.slice(0, 12) : []
        delegate: NetworkRow {}
    }

    component NetworkRow: Column {
        id: row

        required property var modelData

        width: root.width

        MenuRow {
            icon: row.modelData.signalStrength > 0.66 ? "wifi"
                : row.modelData.signalStrength > 0.33 ? "wifi_2_bar" : "wifi_1_bar"
            label: row.modelData.name
            detail: row.modelData.stateChanging ? "Connecting…" : ""
            active: row.modelData.connected
            locked: row.modelData.security !== WifiSecurityType.Open
            onClicked: {
                const network = row.modelData;
                if (network.connected)
                    network.disconnect();
                else if (network.known || network.security === WifiSecurityType.Open)
                    network.connect();
                else
                    root.pskNetwork = root.pskNetwork === network ? null : network;
            }
        }

        // The password of a network not known yet.
        Item {
            width: parent.width
            height: 40
            visible: root.pskNetwork === row.modelData

            Rectangle {
                x: 52
                y: 4
                width: parent.width - x - 16
                height: 30
                radius: 15
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
                        row.modelData.connectWithPsk(text);
                        root.pskNetwork = null;
                    }
                    Keys.onEscapePressed: root.pskNetwork = null

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
