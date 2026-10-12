import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import ".."

// Stack of notification popups in the top-right corner of the focused monitor
PanelWindow {
    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    visible: NotificationCenter.popups.length > 0

    anchors {
        top: true
        right: true
    }
    margins {
        top: 8
        right: 8
    }
    exclusiveZone: 0
    implicitWidth: 360
    implicitHeight: stack.implicitHeight
    color: "transparent"

    ColumnLayout {
        id: stack
        width: parent.width
        spacing: 8

        Repeater {
            model: NotificationCenter.popups

            delegate: NotificationPopup {
                required property var modelData
                notification: modelData
                Layout.fillWidth: true
            }
        }
    }
}
