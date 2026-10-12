import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import ".."

// Connected network in the bar. Click opens a menu: Wi-Fi switch, nearby
// networks by signal (click to connect, password prompt for new secured
// ones) and disconnect for the current one.
MouseArea {
    id: root

    readonly property var connectedDevice: Networking.devices.values.find(device => device.connected) ?? null
    readonly property var wifiDevice: Networking.devices.values.find(device => device.type === DeviceType.Wifi) ?? null
    readonly property bool isWifi: connectedDevice?.type === DeviceType.Wifi
    readonly property var activeNetwork: isWifi
        ? connectedDevice.networks.values.find(network => network.connected) ?? null
        : null

    // Network waiting for a password, if any
    property var passwordFor: null

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight
    cursorShape: Qt.PointingHandCursor
    onClicked: menu.open = !menu.open

    function strengthIcon(strength) {
        return Icons.wifiStrength[Math.min(3, Math.floor((strength ?? 0) * 4))];
    }

    BarText {
        id: label
        text: !root.connectedDevice ? `${Icons.wifiOff} offline`
            : root.isWifi ? `${Icons.wifi} ${root.activeNetwork?.name ?? ""}`
            : `${Icons.ethernet} eth`
        color: root.connectedDevice ? Theme.fg : Theme.fgDim
    }

    Dropdown {
        id: menu
        anchorItem: root
        // Scan only while the menu is open
        onOpenChanged: {
            if (root.wifiDevice) root.wifiDevice.scannerEnabled = open;
            if (!open) root.passwordFor = null;
        }

        MenuHeader {
            title: "Wi-Fi"
            checked: Networking.wifiEnabled
            onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
        }

        Repeater {
            model: Networking.wifiEnabled && root.wifiDevice
                ? root.wifiDevice.networks.values
                    .filter(network => network.name !== "")
                    .sort((a, b) => (b.connected - a.connected) || (b.signalStrength - a.signalStrength))
                    .slice(0, 12)
                : []

            delegate: MenuRow {
                required property var modelData
                icon: root.strengthIcon(modelData.signalStrength)
                label: modelData.name
                active: modelData.connected
                detail: modelData.connected ? "disconnect"
                    : modelData.stateChanging ? "..."
                    : modelData.security !== 0 && !modelData.known ? Icons.lock : ""
                onClicked: {
                    if (modelData.connected) {
                        modelData.disconnect();
                    } else if (modelData.known || modelData.security === 0) {
                        modelData.connect();
                    } else {
                        root.passwordFor = modelData;
                        passwordInput.text = "";
                        passwordInput.forceActiveFocus();
                    }
                }
            }
        }

        // Password for a new secured network
        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 6
            implicitHeight: 34
            visible: root.passwordFor !== null
            color: Theme.surface
            border.width: 1
            border.color: Theme.accent

            TextInput {
                id: passwordInput
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                verticalAlignment: TextInput.AlignVCenter
                echoMode: TextInput.Password
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
                Keys.onReturnPressed: {
                    root.passwordFor.connectWithPsk(text);
                    root.passwordFor = null;
                }
                Keys.onEscapePressed: root.passwordFor = null

                BarText {
                    visible: passwordInput.text === ""
                    text: `Password for ${root.passwordFor?.name ?? ""} (Enter)`
                    color: Theme.fgDim
                }
            }
        }

        BarText {
            Layout.margins: 10
            visible: Networking.wifiEnabled && (root.wifiDevice?.networks.values.length ?? 0) === 0
            text: "Searching..."
            color: Theme.fgDim
        }
    }
}
