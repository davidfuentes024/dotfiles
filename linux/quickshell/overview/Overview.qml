import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import ".."
import "../bar"

// Mission Control style overview (Ctrl+Up or a 3-finger swipe up): every
// desktop as a card with its windows at their real place and size, showing
// their live content. Click a window to go to it, a card to go to that
// desktop, "+" for a new one. Ctrl+Down, a 3-finger swipe down, Esc or a
// click outside close it; 1-9 jump to that desktop.
Scope {
    id: root

    property bool open: false

    readonly property var desktops: Hyprland.workspaces.values
        .filter(ws => ws.id > 0)
        .sort((a, b) => a.id - b.id)

    function show() {
        // Window positions are only as fresh as the last refresh
        Hyprland.refreshToplevels();
        Hyprland.refreshWorkspaces();
        open = true;
    }

    function desktopsCall(lua) {
        Quickshell.execDetached(["hyprctl", "eval", lua]);
        open = false;
    }

    function focusWindow(toplevel) {
        const address = toplevel.address.startsWith("0x") ? toplevel.address : "0x" + toplevel.address;
        Quickshell.execDetached(["hyprctl", "dispatch", `hl.dsp.focus({ window = "address:${address}" })`]);
        open = false;
    }

    // `qs ipc call overview open | close | toggle`
    IpcHandler {
        target: "overview"
        function open(): void { if (!root.open) root.show(); }
        function close(): void { root.open = false; }
        function toggle(): void { if (root.open) root.open = false; else root.show(); }
    }

    PanelWindow {
        id: window

        screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
        visible: root.open

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        exclusionMode: ExclusionMode.Ignore
        // Blurred by the "overview" layer rule in hyprland.lua
        color: Qt.rgba(Theme.bg.r, Theme.bg.g, Theme.bg.b, 0.7)

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "overview"

        // Monitor size in layout units: the reference for every card
        readonly property var monitor: Hyprland.focusedMonitor?.lastIpcObject ?? null
        readonly property real monitorWidth: monitor ? monitor.width / monitor.scale : 1920
        readonly property real monitorHeight: monitor ? monitor.height / monitor.scale : 1080

        readonly property int cardCount: root.desktops.length + 1
        readonly property int columns: Math.min(4, cardCount)
        readonly property real cardWidth: Math.min(480, (width - 120 - (columns - 1) * 28) / columns)
        readonly property real cardHeight: cardWidth * monitorHeight / monitorWidth

        // Click outside the cards closes it
        MouseArea {
            anchors.fill: parent
            onClicked: root.open = false
        }

        Item {
            anchors.fill: parent
            focus: root.open
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    root.open = false;
                } else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
                    root.desktopsCall(`Desktops.goTo(${event.key - Qt.Key_0})`);
                } else {
                    return;
                }
                event.accepted = true;
            }
        }

        GridLayout {
            anchors.centerIn: parent
            columns: window.columns
            columnSpacing: 28
            rowSpacing: 36

            Repeater {
                model: root.desktops

                delegate: ColumnLayout {
                    id: desktop
                    required property var modelData
                    readonly property bool isActive: Hyprland.focusedWorkspace?.id === modelData.id
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: window.cardWidth
                        Layout.preferredHeight: window.cardHeight
                        color: Theme.bgAlt
                        border.width: desktop.isActive ? 2 : 1
                        border.color: desktop.isActive ? Theme.accent : Theme.overlay
                        clip: true

                        // Empty space of the card: go to that desktop
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.desktopsCall(`Desktops.goTo(${desktop.modelData.id})`)
                        }

                        Repeater {
                            model: Hyprland.toplevels.values.filter(t => t.workspace?.id === desktop.modelData.id)

                            delegate: MouseArea {
                                id: thumb
                                required property var modelData
                                readonly property var ipc: modelData.lastIpcObject
                                readonly property real scaleFactor: window.cardWidth / window.monitorWidth
                                readonly property real monitorX: window.monitor ? window.monitor.x : 0
                                readonly property real monitorY: window.monitor ? window.monitor.y : 0

                                x: ((ipc?.at?.[0] ?? 0) - monitorX) * scaleFactor
                                y: ((ipc?.at?.[1] ?? 0) - monitorY) * scaleFactor
                                width: Math.max(24, (ipc?.size?.[0] ?? 200) * scaleFactor)
                                height: Math.max(18, (ipc?.size?.[1] ?? 120) * scaleFactor)
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.focusWindow(modelData)

                                Rectangle {
                                    anchors.fill: parent
                                    color: Theme.surface
                                }

                                // Live content of the window
                                ScreencopyView {
                                    id: preview
                                    anchors.fill: parent
                                    captureSource: root.open ? thumb.modelData.wayland : null
                                    live: true
                                }

                                // App name when there is no picture yet
                                BarText {
                                    anchors.centerIn: parent
                                    visible: !preview.hasContent
                                    text: thumb.ipc?.class ?? ""
                                    color: Theme.fgDim
                                    font.pixelSize: Theme.fontSize - 2
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    color: "transparent"
                                    border.width: thumb.containsMouse ? 2 : 0
                                    border.color: Theme.accent
                                }
                            }
                        }
                    }

                    BarText {
                        Layout.alignment: Qt.AlignHCenter
                        text: desktop.modelData.id
                        color: desktop.isActive ? Theme.accent : Theme.fg
                        font.bold: desktop.isActive
                    }
                }
            }

            // New desktop
            ColumnLayout {
                spacing: 8

                MouseArea {
                    Layout.preferredWidth: window.cardWidth
                    Layout.preferredHeight: window.cardHeight
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.desktopsCall("Desktops.new()")

                    Rectangle {
                        anchors.fill: parent
                        color: parent.containsMouse ? Theme.bgAlt : "transparent"
                        border.width: 1
                        border.color: Theme.overlay
                    }
                    BarText {
                        anchors.centerIn: parent
                        text: Icons.plus
                        color: Theme.fgDim
                        font.pixelSize: Theme.fontSize + 16
                    }
                }

                BarText {
                    Layout.alignment: Qt.AlignHCenter
                    text: "New"
                    color: Theme.fgDim
                }
            }
        }
    }
}
