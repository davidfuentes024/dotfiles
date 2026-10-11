import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

// Top bar: desktops and window title | clock | system status
PanelWindow {
    id: bar

    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: 28
    color: Theme.bg

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 12
        spacing: 12

        // Left and right take equal space so the clock stays centered
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            spacing: 8

            Workspaces {
                Layout.fillHeight: true
            }
            WindowTitle {
                Layout.fillWidth: true
            }
        }

        Clock {}

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            spacing: 16

            Item { Layout.fillWidth: true }
            Tray {}
            SystemUsage {}
            LocalIp {}
            NetworkStatus {}
            BluetoothStatus {}
            Volume {}
            Battery {}
            PowerProfile {}
        }
    }
}
