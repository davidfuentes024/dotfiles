import QtQuick
import Quickshell
import Quickshell.Bluetooth
import ".."

// Bluetooth state and connected device. Click opens bluetui until the
// Quickshell menus exist.
MouseArea {
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var connectedDevice: Bluetooth.devices.values.find(device => device.connected) ?? null

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight
    visible: adapter !== null
    cursorShape: Qt.PointingHandCursor
    onClicked: Quickshell.execDetached(["wezterm", "start", "--class", "bluetui", "--", "bluetui"])

    BarText {
        id: label
        text: !adapter?.enabled ? Icons.bluetoothOff
            : connectedDevice ? `${Icons.bluetoothConnected} ${connectedDevice.name}`
            : Icons.bluetooth
        color: adapter?.enabled ? Theme.fg : Theme.fgDim
    }
}
