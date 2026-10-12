pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Colors and font of the active theme (shared/themes), switched with the
// `theme` command. Files are watched, so the shell restyles itself live.
Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || home + "/.local/state") + "/theme"
    readonly property string themesDir: home + "/.config/themes"

    readonly property string themeName: firstLine(nameFile.text(), "neon")
    readonly property string blackName: firstLine(blackFile.text(), "soft")
    readonly property string fontName: firstLine(fontFile.text(), "jetbrains")

    readonly property var palette: parse(paletteFile.text())
    readonly property var black: parse(blackFile2.text())
    readonly property var fontSpec: parse(fontSpecFile.text())

    readonly property color bg: black.bg || "#1c1c1e"
    readonly property color bgAlt: black.bg_alt || "#232325"
    readonly property color surface: black.surface || "#2c2c2f"
    readonly property color overlay: black.overlay || "#3a3a3e"
    readonly property color fg: palette.fg || "#dcdfe4"
    readonly property color fgDim: palette.fg_dim || "#7f848e"
    readonly property color accent: palette.accent || "#61afef"
    readonly property color accentAlt: palette.accent_alt || "#e5c07b"
    readonly property color red: palette.red || "#e05561"
    readonly property color green: palette.green || "#8cc265"

    readonly property string font: fontSpec.family || "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13

    function firstLine(text, fallback) {
        const line = (text || "").split("\n")[0].trim();
        return line.length > 0 ? line : fallback;
    }

    // Parses `key = "value"` lines of a theme file
    function parse(text) {
        const values = {};
        for (const line of (text || "").split("\n")) {
            const match = line.match(/^(\w+)\s*=\s*"(.*)"/);
            if (match) values[match[1]] = match[2];
        }
        return values;
    }

    // A file can vanish for a moment (e.g. git switching branches); retry so
    // the shell does not stay on the fallback colors
    Timer {
        id: retry
        interval: 1000
        onTriggered: {
            for (const file of [nameFile, blackFile, fontFile, paletteFile, blackFile2, fontSpecFile]) file.reload();
        }
    }

    FileView { id: nameFile; path: root.stateDir + "/name"; watchChanges: true; onFileChanged: reload(); onLoadFailed: retry.restart() }
    FileView { id: blackFile; path: root.stateDir + "/black"; watchChanges: true; onFileChanged: reload(); onLoadFailed: retry.restart() }
    FileView { id: fontFile; path: root.stateDir + "/font"; watchChanges: true; onFileChanged: reload(); onLoadFailed: retry.restart() }
    FileView { id: paletteFile; path: root.themesDir + "/palettes/" + root.themeName + ".toml"; watchChanges: true; onFileChanged: reload(); onLoadFailed: retry.restart() }
    FileView { id: blackFile2; path: root.themesDir + "/blacks/" + root.blackName + ".toml"; watchChanges: true; onFileChanged: reload(); onLoadFailed: retry.restart() }
    FileView { id: fontSpecFile; path: root.themesDir + "/fonts/" + root.fontName + ".toml"; watchChanges: true; onFileChanged: reload(); onLoadFailed: retry.restart() }
}
