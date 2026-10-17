pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking

// The wifi device and its connected network, picked out of Networking.
Singleton {
    id: root

    readonly property var wifiDevice: {
        const devices = Networking.devices ? Networking.devices.values : [];
        for (let i = 0; i < devices.length; i++) {
            if (devices[i].type === DeviceType.Wifi)
                return devices[i];
        }
        return null;
    }

    readonly property var wiredDevice: {
        const devices = Networking.devices ? Networking.devices.values : [];
        for (let i = 0; i < devices.length; i++) {
            if (devices[i].type === DeviceType.Wired && devices[i].connected)
                return devices[i];
        }
        return null;
    }

    readonly property var networks: wifiDevice && wifiDevice.networks
        ? wifiDevice.networks.values.slice().sort((a, b) => b.signalStrength - a.signalStrength)
        : []

    readonly property var current: {
        for (let i = 0; i < networks.length; i++) {
            if (networks[i].connected)
                return networks[i];
        }
        return null;
    }

    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wired: wiredDevice !== null
    readonly property real strength: current ? current.signalStrength : 0
    readonly property string name: wired ? "Ethernet" : current ? current.name : ""

    readonly property string icon: wired ? "lan"
        : !wifiEnabled ? "wifi_off"
        : !current ? "wifi_find"
        : strength > 0.66 ? "wifi"
        : strength > 0.33 ? "wifi_2_bar" : "wifi_1_bar"

    function setWifi(enabled: bool): void {
        Networking.wifiEnabled = enabled;
    }

    function scan(enabled: bool): void {
        if (wifiDevice)
            wifiDevice.scannerEnabled = enabled;
    }
}
