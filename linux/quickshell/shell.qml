//@ pragma UseQApplication
// QApplication mode is needed for tray menus (platform menus)
import QtQuick
import Quickshell
import Quickshell.Io
import "bar"
import "notifications"
import "osd"
import "launcher"
import "lyrics"

// Entry point: one bar per monitor
ShellRoot {
    id: shell

    property bool barVisible: true

    // `qs ipc call bar toggle` (bound to Cmd+. in Hyprland)
    IpcHandler {
        target: "bar"
        function toggle(): void { shell.barVisible = !shell.barVisible; }
    }

    NotificationPopups {}
    Osd {}
    Launcher {}
    LyricsOverlay {}

    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
            visible: shell.barVisible
        }
    }
}
