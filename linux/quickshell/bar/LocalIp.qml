import QtQuick
import Quickshell
import Quickshell.Io
import ".."

// Local IPv4 address. Click copies it to the clipboard.
MouseArea {
    id: root
    property string address: ""
    property bool copied: false

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight
    visible: address !== ""
    cursorShape: Qt.PointingHandCursor

    onClicked: {
        Quickshell.clipboardText = address;
        copied = true;
        copiedTimer.restart();
    }

    BarText {
        id: label
        text: `${Icons.ip} ${root.copied ? "copied" : root.address}`
        color: root.copied ? Theme.accent : Theme.fg
    }

    Process {
        id: lookup
        command: ["sh", "-c", "ip -4 -o addr show scope global | awk '{print $4}' | cut -d/ -f1 | head -n 1"]
        stdout: StdioCollector {
            onStreamFinished: root.address = text.trim()
        }
    }

    Timer {
        interval: 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: lookup.running = true
    }

    Timer {
        id: copiedTimer
        interval: 1200
        onTriggered: root.copied = false
    }
}
