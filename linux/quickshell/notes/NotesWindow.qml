import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import ".."
import "../bar"
import "note.js" as Note

// One Notes window: the notes on the left, most recently edited first, and the
// editor on the right. Several windows can be open; they stay in sync through
// the files: lists follow ~/Notes and an open note reloads when another
// window saves it (unless it is being edited here).
// Cmd+N new note, Cmd+F search, Esc close.
FloatingWindow {
    id: win

    required property string notesDir
    // Start with the most recent note (first window) or a blank one
    property bool startBlank: false
    signal dismissed()

    property string currentPath: ""
    property string query: ""
    // Delete asks for a second click
    property bool confirmDelete: false

    title: "Notes"
    visible: true
    implicitWidth: 920
    implicitHeight: 600
    color: Theme.bg

    onVisibleChanged: if (!visible) {
        dropIfEmpty();
        dismissed();
    }

    function select(path) {
        flushSave();
        dropIfEmpty();
        confirmDelete = false;
        currentPath = path;
    }

    function newNote() {
        flushSave();
        dropIfEmpty();
        const name = Qt.formatDateTime(new Date(), "yyyy-MM-dd_HHmmsszzz") + ".md";
        currentPath = win.notesDir + "/" + name;
        titleField.text = "";
        editor.text = "";
        // No file until something is typed, so empty notes never hit the disk
        titleFocus.restart();
    }

    // Save now instead of waiting for the typing pause (switching notes)
    function flushSave() {
        if (saveTimer.running) {
            saveTimer.stop();
            save();
        }
    }

    function save() {
        if (currentPath === "") return;
        const content = Note.compose(titleField.text, editor.text);
        // Everything erased: remove the note instead of keeping a blank file
        if (content === "") Quickshell.execDetached(["rm", "-f", currentPath]);
        else currentFile.setText(content);
        refreshList();
    }

    // Notes left empty are not worth keeping
    function dropIfEmpty() {
        if (currentPath !== "" && editor.text.trim() === "" && titleField.text.trim() === "")
            Quickshell.execDetached(["rm", "-f", currentPath]);
    }

    function deleteCurrent() {
        if (!confirmDelete) {
            confirmDelete = true;
            return;
        }
        saveTimer.stop();
        Quickshell.execDetached(["rm", "-f", currentPath]);
        confirmDelete = false;
        currentPath = "";
        titleField.text = "";
        editor.text = "";
    }

    // FolderListModel only notices added and removed files, not edits, so
    // the order (most recently edited first) and dates are refreshed by hand
    // whenever a note changes, from this window or another one
    function refreshList() {
        listRefresh.restart();
    }

    Timer {
        id: listRefresh
        interval: 300
        onTriggered: {
            notesModel.folder = "";
            notesModel.folder = "file://" + win.notesDir;
        }
    }

    FolderListModel {
        id: notesModel
        folder: "file://" + win.notesDir
        nameFilters: ["*.md"]
        showDirs: false
        sortField: FolderListModel.Time
        // Pick the first note once the folder is read
        onStatusChanged: {
            if (status !== FolderListModel.Ready || win.currentPath !== "") return;
            if (!win.startBlank && count > 0) win.select(get(0, "filePath"));
            else win.newNote();
        }
    }

    // The note being edited; reloads when another window saves it
    FileView {
        id: currentFile
        path: win.currentPath
        atomicWrites: true
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            // Never overwrite what is being typed here
            if (titleField.activeFocus || editor.activeFocus) return;
            const note = Note.parse(text());
            if (titleField.text !== note.title) titleField.text = note.title;
            if (editor.text !== note.body) editor.text = note.body;
        }
    }

    Timer {
        id: saveTimer
        interval: 400
        onTriggered: win.save()
    }

    Timer {
        id: titleFocus
        interval: 50
        onTriggered: titleField.forceActiveFocus()
    }

    Shortcut { sequence: "Ctrl+N"; onActivated: win.newNote() }
    Shortcut { sequence: "Ctrl+F"; onActivated: search.forceActiveFocus() }
    Shortcut { sequence: "Escape"; onActivated: win.visible = false }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ---- Sidebar --------------------------------------------------------
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 260
            color: Theme.bgAlt

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 30
                        color: Theme.surface

                        TextInput {
                            id: search
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            verticalAlignment: TextInput.AlignVCenter
                            color: Theme.fg
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize
                            onTextChanged: win.query = text.toLowerCase()
                            Keys.onEscapePressed: { text = ""; editor.forceActiveFocus(); }

                            BarText {
                                visible: search.text === ""
                                text: `${Icons.search} Search`
                                color: Theme.fgDim
                            }
                        }
                    }

                    MouseArea {
                        implicitWidth: 30
                        implicitHeight: 30
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: win.newNote()

                        Rectangle {
                            anchors.fill: parent
                            color: parent.containsMouse ? Theme.overlay : Theme.surface
                        }
                        BarText {
                            anchors.centerIn: parent
                            text: Icons.plus
                            color: Theme.accent
                        }
                    }
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 2
                    model: notesModel

                    delegate: MouseArea {
                        id: entry
                        required property string filePath
                        required property date fileModified

                        readonly property string content: entryFile.text()
                        readonly property bool matches: win.query === "" || content.toLowerCase().includes(win.query)
                        readonly property bool selected: filePath === win.currentPath

                        width: ListView.view.width
                        height: matches ? 46 : 0
                        visible: matches
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: win.select(filePath)

                        FileView {
                            id: entryFile
                            path: entry.filePath
                            watchChanges: true
                            onFileChanged: {
                                reload();
                                win.refreshList();
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: entry.selected ? Theme.surface : entry.containsMouse ? Theme.bg : "transparent"
                        }
                        Rectangle {
                            visible: entry.selected
                            width: 2
                            height: parent.height
                            color: Theme.accent
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 8
                            spacing: 0

                            BarText {
                                Layout.fillWidth: true
                                text: Note.listTitle(entry.content)
                                elide: Text.ElideRight
                                font.bold: entry.selected
                            }
                            BarText {
                                text: Qt.formatDateTime(entry.fileModified, "dd MMM  HH:mm")
                                color: Theme.fgDim
                                font.pixelSize: Theme.fontSize - 2
                            }
                        }
                    }
                }
            }
        }

        // ---- Editor ---------------------------------------------------------
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 10
                spacing: 8

                Item { Layout.fillWidth: true }

                MouseArea {
                    implicitWidth: deleteLabel.implicitWidth + 16
                    implicitHeight: 26
                    visible: win.currentPath !== ""
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: win.deleteCurrent()
                    onExited: win.confirmDelete = false

                    Rectangle {
                        anchors.fill: parent
                        color: win.confirmDelete ? Theme.red : parent.containsMouse ? Theme.surface : "transparent"
                    }
                    BarText {
                        id: deleteLabel
                        anchors.centerIn: parent
                        text: win.confirmDelete ? `${Icons.trash} Delete?` : Icons.trash
                        color: win.confirmDelete ? Theme.bg : Theme.fgDim
                    }
                }
            }

            // Title, shown as an H1
            TextInput {
                id: titleField
                Layout.fillWidth: true
                Layout.leftMargin: 22
                Layout.rightMargin: 22
                Layout.topMargin: 4
                Layout.bottomMargin: 6
                color: Theme.fg
                selectionColor: Theme.overlay
                font.family: Theme.font
                font.pixelSize: Theme.fontSize + 12
                font.bold: true
                enabled: win.currentPath !== ""
                clip: true
                onTextEdited: saveTimer.restart()
                // Enter goes on to the text
                Keys.onReturnPressed: editor.forceActiveFocus()
                Keys.onTabPressed: editor.forceActiveFocus()

                Text {
                    visible: titleField.text === ""
                    text: "Title"
                    color: Theme.fgDim
                    font: titleField.font
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.bottomMargin: 12

                TextArea {
                    id: editor
                    wrapMode: TextArea.Wrap
                    color: Theme.fg
                    selectionColor: Theme.overlay
                    selectedTextColor: Theme.fg
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize + 2
                    placeholderText: "Write..."
                    placeholderTextColor: Theme.fgDim
                    background: null
                    enabled: win.currentPath !== ""
                    onTextChanged: if (activeFocus) saveTimer.restart()
                }
            }
        }
    }
}
