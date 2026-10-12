//@ pragma UseQApplication
// QApplication mode is needed for tray menus (platform menus)
import QtQuick
import Quickshell
import Quickshell.Io
import "bar"
import "notifications"
import "osd"
import "launcher"
import "qs-music"
import "notes"
import "overview"

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
    Notes {}
    Overview {}
    // qs-music (synced lyrics); its colors and font follow the active theme
    LyricsOverlay {}
    Binding { target: MusicStyle; property: "bg"; value: Theme.bg }
    Binding { target: MusicStyle; property: "bgAlt"; value: Theme.bgAlt }
    Binding { target: MusicStyle; property: "surface"; value: Theme.surface }
    Binding { target: MusicStyle; property: "overlay"; value: Theme.overlay }
    Binding { target: MusicStyle; property: "fg"; value: Theme.fg }
    Binding { target: MusicStyle; property: "fgDim"; value: Theme.fgDim }
    Binding { target: MusicStyle; property: "accent"; value: Theme.accent }
    Binding { target: MusicStyle; property: "red"; value: Theme.red }
    Binding { target: MusicStyle; property: "font"; value: Theme.font }
    Binding { target: MusicStyle; property: "fontSize"; value: Theme.fontSize }

    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
            visible: shell.barVisible
        }
    }
}
