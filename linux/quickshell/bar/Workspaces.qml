import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import ".."

// Desktops 1..N. Click: go to it. Right click: delete it. "+": new desktop.
// Actions go through the Desktops Lua API in hyprland.lua so the bar follows
// the same rules as the keyboard shortcuts.
RowLayout {
    id: root
    spacing: 0

    readonly property var desktops: Hyprland.workspaces.values
        .filter(ws => ws.id > 0)
        .sort((a, b) => a.id - b.id)

    function desktopsCall(lua) {
        Quickshell.execDetached(["hyprctl", "eval", lua]);
        refreshTimer.restart();
    }

    // Renumbering (change_id) emits no IPC event, so refresh after actions
    Timer {
        id: refreshTimer
        interval: 400
        onTriggered: Hyprland.refreshWorkspaces()
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "configreloaded" || event.name.startsWith("workspace")
                    || event.name.startsWith("renameworkspace"))
                refreshTimer.restart();
        }
    }

    Repeater {
        model: root.desktops

        delegate: MouseArea {
            required property var modelData
            readonly property bool isActive: Hyprland.focusedWorkspace?.id === modelData.id
            readonly property bool isEmpty: (modelData.toplevels?.values?.length ?? 0) === 0

            Layout.fillHeight: true
            implicitWidth: label.implicitWidth + 16
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor

            onClicked: mouse => {
                if (mouse.button === Qt.RightButton)
                    root.desktopsCall(`Desktops.goTo(${modelData.id}); Desktops.delete()`);
                else
                    root.desktopsCall(`Desktops.goTo(${modelData.id})`);
            }

            BarText {
                id: label
                anchors.centerIn: parent
                text: modelData.id
                color: isActive ? Theme.accent : (isEmpty ? Theme.fgDim : Theme.fg)
                font.bold: isActive
            }
        }
    }

    MouseArea {
        Layout.fillHeight: true
        implicitWidth: plusLabel.implicitWidth + 16
        cursorShape: Qt.PointingHandCursor
        onClicked: root.desktopsCall("Desktops.new()")

        BarText {
            id: plusLabel
            anchors.centerIn: parent
            text: Icons.plus
            color: Theme.fgDim
        }
    }
}
