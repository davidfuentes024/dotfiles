import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import ".."

// Synced lyrics floating over the desktop (Cmd+Shift+L). The layer covers the
// whole screen but only the box takes input, and only in edit mode
// (Cmd+Shift+K): drag the box to move it, drag its corner to resize it.
// Position and size are saved.
//
// Lines glide slowly upward; every line keeps the same size and color and only
// fades in or out with its distance from the current one. Long lines wrap. The
// box is translucent and Hyprland blurs what is behind it (layer rule in
// hyprland.lua).
//
// Only the box moves inside this fixed window: moving the window itself on
// every mouse event made the compositor and the drag fight each other.
PanelWindow {
    id: overlay

    readonly property int lineHeight: Theme.fontSize + 16

    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    visible: Media.lyricsVisible && (Media.title !== "" || Media.editing)

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusiveZone: 0
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "lyrics"

    // Input only on the box while editing; elsewhere clicks reach the windows below
    mask: Region { item: Media.editing ? box : null }

    Rectangle {
        id: box

        // Clamped so a saved position from another monitor never ends up off-screen
        width: Math.min(Media.overlayGeometry.width, overlay.width)
        height: Math.min(Media.overlayGeometry.height, overlay.height)
        x: Math.max(0, Math.min(Media.overlayGeometry.x, overlay.width - width))
        y: Math.max(0, Math.min(Media.overlayGeometry.y, overlay.height - height))

        color: Qt.rgba(Theme.bgAlt.r, Theme.bgAlt.g, Theme.bgAlt.b, 0.55)
        border.width: 1
        border.color: Media.editing ? Theme.accent : Qt.rgba(Theme.overlay.r, Theme.overlay.g, Theme.overlay.b, 0.6)
        clip: true

        function save() {
            Media.overlayGeometry = Qt.rect(Math.round(x), Math.round(y), Math.round(width), Math.round(height));
            Media.saveSettings();
        }

        // Status message when there is nothing to scroll
        Text {
            anchors.centerIn: parent
            visible: Media.lyricsStatus !== "ready"
            text: ({ loading: "Loading lyrics...", missing: "No synced lyrics for this song", idle: "Lyrics" })[Media.lyricsStatus] ?? ""
            color: Theme.fgDim
            font.family: Theme.font
            font.pixelSize: Theme.fontSize + 1
        }

        ListView {
            id: lines
            anchors.fill: parent
            anchors.margins: 8
            visible: Media.lyricsStatus === "ready"
            interactive: false
            model: Media.lyrics
            currentIndex: Math.max(0, Media.currentLine)

            // Keeps the current line in the middle and glides between lines
            highlightRangeMode: ListView.StrictlyEnforceRange
            preferredHighlightBegin: (height - (currentItem?.height ?? overlay.lineHeight)) / 2
            preferredHighlightEnd: (height + (currentItem?.height ?? overlay.lineHeight)) / 2
            highlightMoveDuration: 1100
            highlightMoveVelocity: -1

            delegate: Item {
                id: line
                required property var modelData
                required property int index
                readonly property bool isCurrent: index === Media.currentLine

                width: lines.width
                height: Math.max(overlay.lineHeight, text.implicitHeight + 8)

                Text {
                    id: text
                    // 0 for the current line, 1 for its neighbours, and so on
                    readonly property int distance: Math.abs(line.index - Media.currentLine)

                    anchors.centerIn: parent
                    width: parent.width - 16
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: line.modelData.text || "..."
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize + 3
                    color: Theme.fg
                    opacity: distance === 0 ? 1 : Math.max(0.15, 0.55 - (distance - 1) * 0.2)

                    Behavior on opacity {
                        NumberAnimation { duration: 900; easing.type: Easing.InOutQuad }
                    }
                }
            }
        }

        // Drag the box to move it
        MouseArea {
            anchors.fill: parent
            enabled: Media.editing
            cursorShape: Qt.SizeAllCursor
            drag.target: box
            drag.minimumX: 0
            drag.minimumY: 0
            drag.maximumX: overlay.width - box.width
            drag.maximumY: overlay.height - box.height
            onReleased: box.save()
        }

        // Drag the bottom-right corner to resize it
        MouseArea {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            width: 18
            height: 18
            visible: Media.editing
            cursorShape: Qt.SizeFDiagCursor

            property point start
            property size startSize

            // Window coordinates stay stable while the corner moves with the box
            onPressed: mouse => {
                start = mapToItem(null, mouse.x, mouse.y);
                startSize = Qt.size(box.width, box.height);
            }
            onPositionChanged: mouse => {
                const now = mapToItem(null, mouse.x, mouse.y);
                box.width = Math.max(220, Math.min(overlay.width - box.x, startSize.width + now.x - start.x));
                box.height = Math.max(overlay.lineHeight + 16, Math.min(overlay.height - box.y, startSize.height + now.y - start.y));
            }
            onReleased: box.save()

            Rectangle {
                anchors.fill: parent
                color: Theme.accent
            }
        }
    }
}
