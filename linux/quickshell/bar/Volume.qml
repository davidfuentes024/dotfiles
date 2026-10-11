import QtQuick
import Quickshell.Services.Pipewire
import ".."

// Output volume. Scroll changes it, click toggles mute.
MouseArea {
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight
    visible: sink !== null
    cursorShape: Qt.PointingHandCursor

    onClicked: if (sink?.audio) sink.audio.muted = !sink.audio.muted
    onWheel: wheel => {
        if (!sink?.audio) return;
        const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
        sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + step));
    }

    // Volume and mute are only live for tracked nodes
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    BarText {
        id: label
        readonly property string icon: muted ? Icons.volumeMute
            : volume > 0.6 ? Icons.volumeHigh
            : volume > 0.25 ? Icons.volumeMedium
            : Icons.volumeLow
        text: `${icon} ${Math.round(volume * 100)}%`
        color: muted ? Theme.fgDim : Theme.fg
    }
}
