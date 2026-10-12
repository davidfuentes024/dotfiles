import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Pipewire
import ".."
import "../bar"

// On-screen display for volume, microphone mute and brightness, bottom center
// of the focused monitor. Volume reacts to any change in PipeWire (keys, bar,
// apps); brightness is announced by the Hyprland key binds through IPC.
Scope {
    id: root

    property string icon: ""
    property real value: 0
    property bool muted: false
    property bool showing: false

    // PipeWire reports the initial state on startup; don't flash the OSD then
    property bool armed: false

    function show(icon, value, muted) {
        root.icon = icon;
        root.value = value;
        root.muted = muted;
        root.showing = true;
        hideTimer.restart();
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    function showVolume() {
        if (!root.armed || !sink?.audio) return;
        const volume = sink.audio.volume;
        const icon = sink.audio.muted ? Icons.volumeMute
            : volume > 0.6 ? Icons.volumeHigh
            : volume > 0.25 ? Icons.volumeMedium
            : Icons.volumeLow;
        show(icon, volume, sink.audio.muted);
    }

    Connections {
        target: root.sink?.audio ?? null
        function onVolumeChanged() { root.showVolume(); }
        function onMutedChanged() { root.showVolume(); }
    }

    Connections {
        target: root.source?.audio ?? null
        function onMutedChanged() {
            if (!root.armed) return;
            const muted = root.source.audio.muted;
            root.show(muted ? Icons.microphoneOff : Icons.microphone, muted ? 0 : 1, muted);
        }
    }

    Timer {
        interval: 2000
        running: true
        onTriggered: root.armed = true
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.showing = false
    }

    // Same exponential scale (-e4) as the brightness key binds
    Process {
        id: brightnessQuery
        command: ["brightnessctl", "-e4", "-m", "info"]
        stdout: StdioCollector {
            onStreamFinished: {
                const percent = Number((text.split(",")[3] || "0").replace("%", ""));
                root.show(Icons.brightness, percent / 100, false);
            }
        }
    }

    // `qs ipc call osd brightness` after changing it
    IpcHandler {
        target: "osd"
        function brightness(): void { brightnessQuery.running = true; }
    }

    PanelWindow {
        screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
        visible: root.showing

        anchors.bottom: true
        margins.bottom: 80
        exclusiveZone: 0
        implicitWidth: 280
        implicitHeight: 44
        color: "transparent"
        // Never take keyboard or mouse input from the window below
        mask: Region {}

        Rectangle {
            anchors.fill: parent
            color: Theme.bgAlt
            border.width: 1
            border.color: Theme.overlay

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 12

                BarText {
                    text: root.icon
                    color: root.muted ? Theme.fgDim : Theme.fg
                    font.pixelSize: Theme.fontSize + 4
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 4
                    color: Theme.surface

                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(1, root.value))
                        height: parent.height
                        color: root.muted ? Theme.fgDim : Theme.accent
                    }
                }

                BarText {
                    Layout.preferredWidth: 38
                    horizontalAlignment: Text.AlignRight
                    text: root.muted ? "off" : `${Math.round(root.value * 100)}%`
                    color: root.muted ? Theme.fgDim : Theme.fg
                }
            }
        }
    }
}
