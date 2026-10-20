import QtQuick
import Quickshell.Bluetooth
import qs.common

// The Bluetooth menu, as on macOS: the switch, the paired devices, then the
// devices nearby under a chevron, looked for while the menu is open.
CcMenu {
    id: root

    property bool showNearby: true

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool powered: adapter ? adapter.enabled : false
    readonly property var devices: Bluetooth.devices ? Bluetooth.devices.values : []
    readonly property var paired: devices.filter((d) => d.paired)
        .sort((a, b) => (b.connected - a.connected) || a.name.localeCompare(b.name))
    readonly property var nearby: devices.filter((d) => !d.paired && d.name.length > 0)
        .sort((a, b) => a.name.localeCompare(b.name))

    title: "Bluetooth"
    checked: powered
    onToggled: if (adapter) adapter.enabled = !adapter.enabled

    readonly property bool discover: scanning && powered
    onDiscoverChanged: if (adapter) adapter.discovering = discover
    Component.onDestruction: if (adapter && powered) adapter.discovering = false

    MenuSection {
        visible: root.powered
        text: "Devices"
    }

    CcText {
        x: 16
        height: 32
        visible: root.powered && root.paired.length === 0
        verticalAlignment: Text.AlignVCenter
        text: "No Devices"
        color: Theme.dark ? Theme.cc.textDim : Theme.cc.textSoft
        font.pixelSize: Theme.textMd
    }

    Repeater {
        model: root.powered ? root.paired : []
        delegate: DeviceRow {}
    }

    MenuSection {
        visible: root.powered
        text: "Nearby Devices"
        expandable: true
        expanded: root.showNearby
        onClicked: root.showNearby = !root.showNearby
    }

    Repeater {
        model: root.powered && root.showNearby ? root.nearby.slice(0, 12) : []
        delegate: DeviceRow {}
    }

    component DeviceRow: MenuRow {
        id: row

        required property var modelData
        readonly property bool busy: modelData.state === BluetoothDeviceState.Connecting
            || modelData.state === BluetoothDeviceState.Disconnecting || modelData.pairing
        readonly property string kind: modelData.icon || ""

        icon: kind.indexOf("audio") >= 0 ? "headphones"
            : kind.indexOf("input-mouse") >= 0 ? "mouse"
            : kind.indexOf("input-keyboard") >= 0 ? "keyboard"
            : kind.indexOf("input-gaming") >= 0 ? "sports_esports"
            : kind.indexOf("phone") >= 0 ? "smartphone"
            : kind.indexOf("computer") >= 0 ? "computer"
            : "bluetooth"
        label: modelData.name
        active: modelData.connected
        detail: modelData.pairing ? "Pairing…"
            : modelData.state === BluetoothDeviceState.Connecting ? "Connecting…"
            : modelData.state === BluetoothDeviceState.Disconnecting ? "Disconnecting…"
            : modelData.connected && modelData.batteryAvailable ? Math.round(modelData.battery * 100) + "%"
            : ""
        onClicked: {
            const device = row.modelData;
            if (row.busy)
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
