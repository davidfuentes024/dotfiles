import QtQuick
import Quickshell.Networking
import ".."

// Connected network: Wi-Fi name, ethernet or offline
BarText {
    readonly property var connectedDevice: Networking.devices.values.find(device => device.connected) ?? null
    readonly property bool isWifi: connectedDevice?.type === DeviceType.Wifi
    readonly property var activeNetwork: isWifi
        ? connectedDevice.networks.values.find(network => network.connected) ?? null
        : null

    text: !connectedDevice ? `${Icons.wifiOff} offline`
        : isWifi ? `${Icons.wifi} ${activeNetwork?.name ?? ""}`
        : `${Icons.ethernet} eth`
    color: connectedDevice ? Theme.fg : Theme.fgDim
}
