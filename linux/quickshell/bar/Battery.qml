import QtQuick
import Quickshell.Services.UPower
import ".."

BarText {
    readonly property var device: UPower.displayDevice
    // UPower reports either a 0-1 fraction or a 0-100 value depending on version
    readonly property real percent: (device?.percentage ?? 0) <= 1 ? (device?.percentage ?? 0) * 100 : device.percentage
    readonly property bool charging: device?.state === UPowerDeviceState.Charging
        || device?.state === UPowerDeviceState.FullyCharged

    visible: device?.isLaptopBattery ?? false
    text: `${charging ? Icons.batteryCharging : Icons.batteryLevels[Math.min(9, Math.floor(percent / 10))]} ${Math.round(percent)}%`
    color: !charging && percent <= 15 ? Theme.red : Theme.fg
}
