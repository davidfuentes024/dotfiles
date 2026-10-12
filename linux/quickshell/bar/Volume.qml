import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import ".."

// Output volume. Scroll changes it, right click toggles mute, click opens a
// menu: output volume and device, input device and microphone mute.
MouseArea {
    id: root
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    // Physical outputs and inputs (no per-app streams)
    readonly property var sinks: Pipewire.nodes.values.filter(node => node.isSink && !node.isStream && node.audio)
    readonly property var sources: Pipewire.nodes.values.filter(node => !node.isSink && !node.isStream && node.audio)

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight
    visible: sink !== null
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton) {
            if (sink?.audio) sink.audio.muted = !sink.audio.muted;
        } else {
            menu.open = !menu.open;
        }
    }
    onWheel: wheel => {
        if (!sink?.audio) return;
        const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
        sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + step));
    }

    function nodeName(node) {
        return node.description || node.nickname || node.name;
    }

    // Volume and mute are only live for tracked nodes
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    BarText {
        id: label
        readonly property string icon: root.muted ? Icons.volumeMute
            : root.volume > 0.6 ? Icons.volumeHigh
            : root.volume > 0.25 ? Icons.volumeMedium
            : Icons.volumeLow
        text: `${icon} ${Math.round(root.volume * 100)}%`
        color: root.muted ? Theme.fgDim : Theme.fg
    }

    Dropdown {
        id: menu
        anchorItem: root
        panelWidth: 340

        MenuHeader {
            title: "Output"
            showSwitch: false
        }

        // Volume: click or drag
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            Layout.bottomMargin: 6
            spacing: 10

            MouseArea {
                implicitWidth: muteIcon.implicitWidth
                implicitHeight: muteIcon.implicitHeight
                cursorShape: Qt.PointingHandCursor
                onClicked: if (root.sink?.audio) root.sink.audio.muted = !root.sink.audio.muted

                BarText {
                    id: muteIcon
                    text: label.icon
                    color: root.muted ? Theme.fgDim : Theme.accent
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 4
                color: Theme.surface

                Rectangle {
                    width: parent.width * Math.min(1, root.volume)
                    height: parent.height
                    color: root.muted ? Theme.fgDim : Theme.accent
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.topMargin: -8
                    anchors.bottomMargin: -8
                    cursorShape: Qt.PointingHandCursor
                    function set(x) { if (root.sink?.audio) root.sink.audio.volume = Math.max(0, Math.min(1, x / width)); }
                    onPressed: mouse => set(mouse.x)
                    onPositionChanged: mouse => { if (pressed) set(mouse.x); }
                }
            }

            BarText {
                text: `${Math.round(root.volume * 100)}%`
                color: Theme.fgDim
                Layout.preferredWidth: 38
                horizontalAlignment: Text.AlignRight
            }
        }

        Repeater {
            model: root.sinks
            delegate: MenuRow {
                required property var modelData
                icon: modelData === root.sink ? Icons.check : ""
                label: root.nodeName(modelData)
                active: modelData === root.sink
                onClicked: Pipewire.preferredDefaultAudioSink = modelData
            }
        }

        MenuHeader {
            Layout.topMargin: 8
            title: "Input"
            // Switch on = microphone live
            checked: !(root.source?.audio?.muted ?? true)
            showSwitch: root.source !== null
            onToggled: if (root.source?.audio) root.source.audio.muted = !root.source.audio.muted
        }

        Repeater {
            model: root.sources
            delegate: MenuRow {
                required property var modelData
                icon: modelData === root.source ? Icons.check : ""
                label: root.nodeName(modelData)
                active: modelData === root.source
                onClicked: Pipewire.preferredDefaultAudioSource = modelData
            }
        }
    }
}
