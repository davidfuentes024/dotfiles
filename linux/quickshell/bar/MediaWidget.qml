import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

// Music icon next to the clock. Click opens a panel below the bar with the
// song, artist, progress and controls, so the bar itself never shifts.
MouseArea {
    id: root
    readonly property var player: Media.player

    visible: player !== null && Media.title !== ""
    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight
    cursorShape: Qt.PointingHandCursor
    onClicked: Media.panelOpen = !Media.panelOpen

    BarText {
        id: icon
        text: Icons.music
        color: root.player?.isPlaying ? Theme.accent : Theme.fgDim
    }

    function formatTime(seconds) {
        const total = Math.max(0, Math.floor(seconds));
        return `${Math.floor(total / 60)}:${String(total % 60).padStart(2, "0")}`;
    }

    PopupWindow {
        visible: Media.panelOpen && root.visible
        // Clicking outside closes it
        grabFocus: true
        onVisibleChanged: if (!visible) Media.panelOpen = false

        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.margins.top: 10
        implicitWidth: 340
        implicitHeight: panel.implicitHeight
        color: "transparent"

        Rectangle {
            id: panel
            width: parent.width
            implicitHeight: content.implicitHeight + 28
            color: Theme.bgAlt
            border.width: 1
            border.color: Theme.overlay

            ColumnLayout {
                id: content
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 14
                }
                spacing: 6

                BarText {
                    Layout.fillWidth: true
                    text: Media.title
                    font.bold: true
                    elide: Text.ElideRight
                }
                BarText {
                    Layout.fillWidth: true
                    text: Media.artist
                    color: Theme.fgDim
                    elide: Text.ElideRight
                    visible: text !== ""
                }

                // Progress
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 6
                    spacing: 4
                    visible: root.player?.lengthSupported && root.player.length > 0

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 3
                        color: Theme.surface

                        Rectangle {
                            width: parent.width * Math.min(1, Media.position / Math.max(1, root.player?.length ?? 1))
                            height: parent.height
                            color: Theme.accent
                        }

                        // Click to seek
                        MouseArea {
                            anchors.fill: parent
                            anchors.topMargin: -6
                            anchors.bottomMargin: -6
                            enabled: root.player?.canSeek ?? false
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mouse => root.player.position = root.player.length * mouse.x / width
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        BarText {
                            text: root.formatTime(Media.position)
                            color: Theme.fgDim
                            font.pixelSize: Theme.fontSize - 2
                        }
                        Item { Layout.fillWidth: true }
                        BarText {
                            text: root.formatTime(root.player?.length ?? 0)
                            color: Theme.fgDim
                            font.pixelSize: Theme.fontSize - 2
                        }
                    }
                }

                // Controls
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 28

                    Repeater {
                        model: [
                            { glyph: Icons.previous, action: () => root.player.previous(), enabled: root.player?.canGoPrevious },
                            { glyph: root.player?.isPlaying ? Icons.pause : Icons.play, action: () => root.player.togglePlaying(), enabled: root.player?.canTogglePlaying },
                            { glyph: Icons.next, action: () => root.player.next(), enabled: root.player?.canGoNext }
                        ]

                        delegate: MouseArea {
                            required property var modelData
                            implicitWidth: control.implicitWidth
                            implicitHeight: control.implicitHeight
                            enabled: modelData.enabled ?? false
                            cursorShape: Qt.PointingHandCursor
                            onClicked: modelData.action()

                            BarText {
                                id: control
                                text: modelData.glyph
                                color: parent.enabled ? Theme.fg : Theme.fgDim
                                font.pixelSize: Theme.fontSize + 8
                            }
                        }
                    }
                }

                BarText {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.player?.identity ?? ""
                    color: Theme.fgDim
                    font.pixelSize: Theme.fontSize - 2
                }
            }
        }
    }
}
