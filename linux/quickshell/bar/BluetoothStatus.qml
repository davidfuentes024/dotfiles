import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import ".."

// Bluetooth state and connected device. Click opens a menu: on/off switch,
// paired devices (click to connect or disconnect) and a scan for new ones
// (click to pair and connect). Right click turns Bluetooth on or off.
MouseArea {
    id: root
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var connectedDevice: Bluetooth.devices.values.find(device => device.connected) ?? null

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight
    visible: adapter !== null
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor
    onClicked: mouse => {
        if (mouse.button === Qt.RightButton) {
            if (adapter) adapter.enabled = !adapter.enabled;
        } else {
            menu.open = !menu.open;
        }
    }

    function deviceIcon(device) {
        const icon = device?.icon ?? "";
        if (icon.includes("headset") || icon.includes("headphone") || icon.includes("audio-card")) return Icons.headphones;
        if (icon.includes("speaker")) return Icons.speaker;
        if (icon.includes("keyboard")) return Icons.keyboard;
        if (icon.includes("mouse")) return Icons.mouse;
        if (icon.includes("phone")) return Icons.phone;
        return Icons.bluetooth;
    }

    BarText {
        id: label
        text: !root.adapter?.enabled ? Icons.bluetoothOff
            : root.connectedDevice ? `${Icons.bluetoothConnected} ${root.connectedDevice.name}`
            : Icons.bluetooth
        color: root.adapter?.enabled ? Theme.fg : Theme.fgDim
    }

    Dropdown {
        id: menu
        anchorItem: root
        // Stop scanning when the menu closes
        onOpenChanged: if (!open && root.adapter?.discovering) root.adapter.discovering = false

        MenuHeader {
            title: "Bluetooth"
            checked: root.adapter?.enabled ?? false
            onToggled: root.adapter.enabled = !root.adapter.enabled
        }

        // Paired devices
        Repeater {
            model: root.adapter?.enabled
                ? Bluetooth.devices.values.filter(device => device.paired)
                    .sort((a, b) => (b.connected - a.connected) || a.name.localeCompare(b.name))
                : []

            delegate: MenuRow {
                required property var modelData
                icon: root.deviceIcon(modelData)
                label: modelData.name
                active: modelData.connected
                detail: modelData.state === BluetoothDeviceState.Connecting ? "..."
                    : modelData.batteryAvailable ? `${Math.round(modelData.battery * 100)}%`
                    : modelData.connected ? "disconnect" : ""
                onClicked: modelData.connected = !modelData.connected
            }
        }

        // New devices, while scanning
        MenuRow {
            visible: root.adapter?.enabled ?? false
            icon: Icons.refresh
            label: root.adapter?.discovering ? "Searching for devices..." : "Search for devices"
            dim: true
            onClicked: root.adapter.discovering = !root.adapter.discovering
        }

        Repeater {
            model: root.adapter?.discovering
                ? Bluetooth.devices.values.filter(device => !device.paired && device.deviceName !== "")
                : []

            delegate: MenuRow {
                required property var modelData
                icon: root.deviceIcon(modelData)
                label: modelData.name
                detail: modelData.pairing ? "pairing..." : "pair"
                onClicked: {
                    // Trusted so it reconnects on its own later
                    modelData.trusted = true;
                    modelData.pair();
                }

                // Connect as soon as pairing succeeds
                Connections {
                    target: modelData
                    function onPairedChanged() { if (modelData.paired) modelData.connect(); }
                }
            }
        }
    }
}
