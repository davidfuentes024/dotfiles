import QtQuick
import Quickshell.Hyprland
import ".."

// Title of the focused window
BarText {
    readonly property var window: Hyprland.activeToplevel
    readonly property bool onFocusedDesktop: window?.workspace?.id === Hyprland.focusedWorkspace?.id

    text: window && onFocusedDesktop ? window.title : ""
    color: Theme.fgDim
    elide: Text.ElideRight
}
