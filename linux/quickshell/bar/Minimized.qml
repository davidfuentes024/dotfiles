import QtQuick
import Quickshell
import Quickshell.Hyprland
import ".."

// Windows minimized with Cmd+M (Hyprland's "minimized" special workspace).
// Shows a count only when there are some; click lists them, click one to
// bring it back to the current desktop.
MouseArea {
    id: root

    readonly property var windows: Hyprland.toplevels.values
        .filter(w => w.workspace?.name === "special:minimized")

    visible: windows.length > 0
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight
    cursorShape: Qt.PointingHandCursor
    onClicked: menu.open = !menu.open

    function restore(window) {
        // Hyprland addresses are hex, sometimes without the 0x prefix here
        const address = window.address.startsWith("0x") ? window.address : "0x" + window.address;
        Quickshell.execDetached(["hyprctl", "eval", `Windows.restore("${address}")`]);
        menu.open = false;
    }

    // Moving a window between workspaces does not update the toplevels'
    // workspace on its own; refresh when Hyprland reports a move
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name.startsWith("movewindow") || event.name.startsWith("closewindow")) refresh.restart();
        }
    }
    Timer {
        id: refresh
        interval: 150
        onTriggered: Hyprland.refreshToplevels()
    }

    BarText {
        id: label
        text: `${Icons.minimized} ${root.windows.length}`
    }

    Dropdown {
        id: menu
        anchorItem: root

        MenuHeader {
            title: "Minimized"
            showSwitch: false
        }

        Repeater {
            model: root.windows
            delegate: MenuRow {
                required property var modelData
                icon: Icons.minimized
                label: modelData.title
                detail: modelData.lastIpcObject?.class ?? ""
                onClicked: root.restore(modelData)
            }
        }
    }
}
