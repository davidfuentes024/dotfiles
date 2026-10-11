import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import ".."
import "../bar"
import "fuzzy.js" as Fuzzy

// Launcher (Cmd+Space). Apps by default; a prefix switches the mode:
//   =  calculator (qalc)        /  files in home (fd)
//   :  theme, font and black    >  power: lock, suspend, reboot, power off, log out
//   ;  clipboard history (Cmd+Shift+V opens it directly)
Scope {
    id: root

    property bool open: false
    property string query: ""
    property int selected: 0
    // Power actions that need a second Enter
    property string pendingConfirm: ""

    property var asyncResults: []

    readonly property string home: Quickshell.env("HOME")
    // ~/.config/themes links to shared/themes; its parent holds shared/bin
    readonly property string themeCommand: home + "/.config/themes/../bin/theme"

    readonly property string mode: {
        const first = query.charAt(0);
        return ({ "=": "calc", "/": "files", ":": "commands", ">": "power", ";": "clipboard" })[first] ?? "apps";
    }
    readonly property string term: mode === "apps" ? query.trim() : query.slice(1).trim()

    readonly property var results: {
        if (mode === "apps") return appResults(term);
        if (mode === "power") return powerResults(term);
        if (mode === "commands" || mode === "clipboard") return filterResults(asyncResults, term);
        return asyncResults;
    }

    function show(prefix) {
        query = prefix;
        selected = 0;
        pendingConfirm = "";
        asyncResults = [];
        open = true;
        refreshAsync();
    }

    function close() {
        open = false;
        query = "";
    }

    function run(item) {
        if (!item) return;
        if (item.confirm && pendingConfirm !== item.title) {
            pendingConfirm = item.title;
            return;
        }
        close();
        item.run();
    }

    // ---- Apps -------------------------------------------------------------

    function launchApp(entry) {
        if (entry.runInTerminal)
            Quickshell.execDetached(["wezterm", "start", "--", ...entry.command]);
        else
            entry.execute();
    }

    function appResults(text) {
        const apps = DesktopEntries.applications.values.filter(entry => !entry.noDisplay);
        const scored = apps.map(entry => ({
            entry: entry,
            score: text === "" ? 0 : Fuzzy.best(text, [entry.name, entry.genericName, (entry.keywords || []).join(" "), entry.comment])
        })).filter(item => item.score >= 0);
        scored.sort((a, b) => b.score - a.score || a.entry.name.localeCompare(b.entry.name));
        return scored.slice(0, 50).map(item => ({
            title: item.entry.name,
            subtitle: item.entry.genericName || item.entry.comment || "",
            iconPath: Quickshell.iconPath(item.entry.icon, true),
            glyph: Icons.application,
            run: () => launchApp(item.entry)
        }));
    }

    // ---- Power ------------------------------------------------------------

    function powerResults(text) {
        const items = [
            { title: "Lock", glyph: Icons.lock, command: ["sh", "-c", "pidof hyprlock || hyprlock"] },
            { title: "Suspend", glyph: Icons.sleep, command: ["systemctl", "suspend"] },
            { title: "Reboot", glyph: Icons.restart, command: ["systemctl", "reboot"], confirm: true },
            { title: "Power off", glyph: Icons.power, command: ["systemctl", "poweroff"], confirm: true },
            { title: "Log out", glyph: Icons.logout, command: ["hyprctl", "dispatch", "hl.dsp.exit()"], confirm: true },
        ];
        return filterResults(items.map(item => Object.assign(item, {
            subtitle: item.confirm ? (pendingConfirm === item.title ? "Press Enter again to confirm" : "Asks for confirmation") : "",
            run: () => Quickshell.execDetached(item.command)
        })), text);
    }

    function filterResults(items, text) {
        if (text === "") return items;
        return items
            .map(item => ({ item: item, score: Fuzzy.best(text, [item.title, item.subtitle]) }))
            .filter(entry => entry.score >= 0)
            .sort((a, b) => b.score - a.score)
            .map(entry => entry.item);
    }

    // ---- Async modes: calculator, files, commands, clipboard ---------------

    function refreshAsync() {
        if (mode === "calc") {
            asyncResults = [];
            if (term !== "") { calcProcess.running = false; calcProcess.running = true; }
        } else if (mode === "files") {
            asyncResults = [];
            if (term.length >= 2) { filesProcess.running = false; filesProcess.running = true; }
        } else if (mode === "commands") {
            commandsProcess.running = true;
        } else if (mode === "clipboard") {
            clipboardProcess.running = true;
        }
    }

    onModeChanged: refreshAsync()
    onTermChanged: {
        selected = 0;
        pendingConfirm = "";
        if (mode === "calc" || mode === "files") debounce.restart();
    }

    Timer {
        id: debounce
        interval: 150
        onTriggered: root.refreshAsync()
    }

    Process {
        id: calcProcess
        command: ["qalc", "-t", root.term]
        stdout: StdioCollector {
            onStreamFinished: {
                const answer = text.trim();
                root.asyncResults = answer === "" ? [] : [{
                    title: answer,
                    subtitle: "Enter copies the result",
                    glyph: Icons.calculator,
                    run: () => { Quickshell.clipboardText = answer; }
                }];
            }
        }
    }

    Process {
        id: filesProcess
        command: ["fd", "--ignore-case", "--type", "f", "--hidden", "--exclude", ".git",
                  "--max-results", "60", "--", root.term, root.home]
        stdout: StdioCollector {
            onStreamFinished: {
                root.asyncResults = text.split("\n").filter(line => line !== "").map(path => ({
                    title: path.split("/").pop(),
                    subtitle: path.replace(root.home, "~"),
                    glyph: Icons.file,
                    run: () => Quickshell.execDetached(["xdg-open", path])
                }));
            }
        }
    }

    Process {
        id: commandsProcess
        command: ["sh", "-c",
            "for f in \"$HOME\"/.config/themes/palettes/*.toml; do echo \"theme $(basename \"$f\" .toml)\"; done;"
            + "for f in \"$HOME\"/.config/themes/fonts/*.toml; do echo \"font $(basename \"$f\" .toml)\"; done;"
            + "for f in \"$HOME\"/.config/themes/blacks/*.toml; do echo \"black $(basename \"$f\" .toml)\"; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                const glyphs = { theme: Icons.palette, font: Icons.fontIcon, black: Icons.contrast };
                root.asyncResults = text.split("\n").filter(line => line !== "").map(line => {
                    const args = line.split(" ");
                    return {
                        title: line,
                        subtitle: "",
                        glyph: glyphs[args[0]],
                        run: () => Quickshell.execDetached([root.themeCommand, ...args])
                    };
                });
            }
        }
    }

    Process {
        id: clipboardProcess
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.asyncResults = text.split("\n").filter(line => line !== "").slice(0, 200).map(line => ({
                    title: line.split("\t").slice(1).join(" ").replace(/\s+/g, " ").trim(),
                    subtitle: "",
                    glyph: Icons.clipboard,
                    // cliphist decodes by its own line format (id<TAB>preview)
                    run: () => Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | cliphist decode | wl-copy", "_", line])
                }));
            }
        }
    }

    // `qs ipc call launcher toggle` (Cmd+Space), `open clipboard` (Cmd+Shift+V)
    IpcHandler {
        target: "launcher"
        function toggle(): void { if (root.open) root.close(); else root.show(""); }
        function open(mode: string): void {
            root.show(({ clipboard: ";", calc: "=", files: "/", commands: ":", power: ">" })[mode] ?? "");
        }
    }

    // ---- Window -----------------------------------------------------------

    PanelWindow {
        id: window
        screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
        visible: root.open

        anchors.top: true
        margins.top: Math.round((screen?.height ?? 1080) * 0.2)
        exclusiveZone: 0
        implicitWidth: 640
        implicitHeight: panel.implicitHeight
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "launcher"

        // Clicking anywhere else closes it
        HyprlandFocusGrab {
            windows: [window]
            active: window.visible
            onCleared: root.close()
        }

        Rectangle {
            id: panel
            width: parent.width
            implicitHeight: column.implicitHeight
            color: Theme.bgAlt
            border.width: 1
            border.color: Theme.overlay

            ColumnLayout {
                id: column
                width: parent.width
                spacing: 0

                RowLayout {
                    Layout.fillWidth: true
                    Layout.margins: 14
                    spacing: 12

                    BarText {
                        text: Icons.search
                        color: Theme.accent
                        font.pixelSize: Theme.fontSize + 4
                    }

                    TextInput {
                        id: input
                        Layout.fillWidth: true
                        text: root.query
                        onTextEdited: root.query = text
                        color: Theme.fg
                        selectionColor: Theme.overlay
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize + 3
                        focus: true

                        // Prefixes can also be set from outside (IPC), not only typed
                        Connections {
                            target: root
                            function onQueryChanged() {
                                if (input.text !== root.query) {
                                    input.text = root.query;
                                    input.cursorPosition = input.text.length;
                                }
                            }
                            function onOpenChanged() {
                                if (root.open) {
                                    input.text = root.query;
                                    input.cursorPosition = input.text.length;
                                    input.forceActiveFocus();
                                }
                            }
                        }

                        Keys.onPressed: event => {
                            const count = root.results.length;
                            const down = event.key === Qt.Key_Down || event.key === Qt.Key_Tab
                                || ((event.modifiers & Qt.ControlModifier) && (event.key === Qt.Key_J || event.key === Qt.Key_N));
                            const up = event.key === Qt.Key_Up || event.key === Qt.Key_Backtab
                                || ((event.modifiers & Qt.ControlModifier) && (event.key === Qt.Key_K || event.key === Qt.Key_P));
                            if (event.key === Qt.Key_Escape) {
                                root.close();
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                root.run(root.results[root.selected]);
                            } else if (down && count > 0) {
                                root.selected = (root.selected + 1) % count;
                            } else if (up && count > 0) {
                                root.selected = (root.selected - 1 + count) % count;
                            } else {
                                return;
                            }
                            event.accepted = true;
                        }

                        BarText {
                            visible: root.term === ""
                            x: input.contentWidth + (input.text === "" ? 0 : 8)
                            text: ({
                                apps: "Search apps",
                                calc: "Expression, e.g. 2^10 or 5 km to mi",
                                files: "File name (2+ letters)",
                                commands: "theme, font or black",
                                power: "Lock, suspend, reboot...",
                                clipboard: "Search the clipboard history"
                            })[root.mode]
                            color: Theme.fgDim
                            font.pixelSize: input.font.pixelSize
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: Theme.overlay
                    visible: list.count > 0
                }

                ListView {
                    id: list
                    Layout.fillWidth: true
                    implicitHeight: Math.min(count, 8) * 44
                    clip: true
                    model: root.results
                    currentIndex: root.selected
                    highlightMoveDuration: 0
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: MouseArea {
                        id: row
                        required property var modelData
                        required property int index
                        readonly property bool isSelected: index === root.selected

                        width: list.width
                        height: 44
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.selected = index
                        onClicked: root.run(modelData)

                        Rectangle {
                            anchors.fill: parent
                            color: row.isSelected ? Theme.surface : "transparent"
                        }

                        Rectangle {
                            visible: row.isSelected
                            width: 2
                            height: parent.height
                            color: Theme.accent
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 12

                            Item {
                                implicitWidth: 24
                                implicitHeight: 24

                                IconImage {
                                    id: appIcon
                                    anchors.fill: parent
                                    source: row.modelData.iconPath ?? ""
                                    visible: source !== "" && status === Image.Ready
                                }
                                BarText {
                                    anchors.centerIn: parent
                                    visible: !appIcon.visible
                                    text: row.modelData.glyph ?? ""
                                    color: row.isSelected ? Theme.accent : Theme.fgDim
                                    font.pixelSize: Theme.fontSize + 4
                                }
                            }

                            BarText {
                                text: row.modelData.title
                                color: Theme.fg
                                elide: Text.ElideRight
                                Layout.maximumWidth: list.width * 0.55
                            }

                            BarText {
                                Layout.fillWidth: true
                                text: row.modelData.subtitle ?? ""
                                color: row.modelData.title === root.pendingConfirm ? Theme.accentAlt : Theme.fgDim
                                font.pixelSize: Theme.fontSize - 1
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                // Prefix cheat sheet while nothing is typed
                BarText {
                    Layout.fillWidth: true
                    Layout.margins: 10
                    visible: root.query === ""
                    horizontalAlignment: Text.AlignHCenter
                    text: "=  calc     /  files     :  theme     >  power     ;  clipboard"
                    color: Theme.fgDim
                    font.pixelSize: Theme.fontSize - 1
                }
            }
        }
    }
}
