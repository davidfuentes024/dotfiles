import QtQuick
import Quickshell
import Quickshell.Io

// Notes app, opened from the launcher ("Notes", see linux/applications). Every
// launch opens another window; the first one shows the most recent note, the
// others start blank. Every note is a plain .md file in ~/Notes, saved while
// typing, that starts with its title as a "# " heading like Apple Notes: type
// a title, or leave it empty and the first line of the text becomes the title.
Scope {
    id: root

    readonly property string notesDir: Quickshell.env("HOME") + "/Notes"
    // One entry per open window
    property var windows: []
    property int nextId: 0

    function openWindow() {
        windows = [...windows, nextId++];
    }

    function closeWindow(id) {
        windows = windows.filter(w => w !== id);
    }

    // `qs ipc call notes open` (the launcher entry)
    IpcHandler {
        target: "notes"
        function open(): void { root.openWindow(); }
    }

    Process {
        running: true
        command: ["mkdir", "-p", root.notesDir]
    }

    Instantiator {
        model: root.windows

        delegate: NotesWindow {
            required property int modelData
            required property int index
            notesDir: root.notesDir
            startBlank: index > 0
            onDismissed: root.closeWindow(modelData)
        }
    }
}
