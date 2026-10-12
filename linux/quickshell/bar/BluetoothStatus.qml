import QtQuick
import Quickshell
import Quickshell.Bluetooth
import ".."

// Bluetooth state and connected device. Click opens bluetui (until the
// Quickshell menus exist), right click turns Bluetooth on or off.
MouseArea {
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
            Quickshell.execDetached(["wezterm", "start", "--class", "bluetui", "--", "bluetui"]);
        }
    }

    BarText {
        id: label
        text: !adapter?.enabled ? Icons.bluetoothOff
            : connectedDevice ? `${Icons.bluetoothConnected} ${connectedDevice.name}`
            : Icons.bluetooth
        color: adapter?.enabled ? Theme.fg : Theme.fgDim
    }
}
