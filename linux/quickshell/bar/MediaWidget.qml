import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import ".."

// Music icon next to the clock. Click opens a panel below the bar with the
// song, artist, progress and controls, so the bar itself never shifts. The
// panel is the mouse-friendly way to drive the player: shuffle, repeat and
// volume work there for any MPRIS player that supports them.
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
                    visible: !!root.player?.lengthSupported && root.player.length > 0

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

                // Shuffle, repeat, like and volume (see Media.qml for how each player is driven)
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    spacing: 14

                    MouseArea {
                        implicitWidth: shuffleIcon.implicitWidth
                        implicitHeight: shuffleIcon.implicitHeight
                        visible: Media.shuffleAvailable
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Media.toggleShuffle()

                        BarText {
                            id: shuffleIcon
                            text: Media.shuffleOn ? Icons.shuffle : Icons.shuffleOff
                            color: Media.shuffleOn ? Theme.accent : Theme.fgDim
                            font.pixelSize: Theme.fontSize + 3
                        }
                    }

                    MouseArea {
                        implicitWidth: repeatIcon.implicitWidth
                        implicitHeight: repeatIcon.implicitHeight
                        visible: Media.repeatAvailable
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Media.cycleRepeat()

                        BarText {
                            id: repeatIcon
                            text: Media.repeatMode === "one" ? Icons.repeatOne
                                : Media.repeatMode === "all" ? Icons.repeatAll : Icons.repeatOff
                            color: Media.repeatMode === "off" ? Theme.fgDim : Theme.accent
                            font.pixelSize: Theme.fontSize + 3
                        }
                    }

                    // Click: like the song. Right click: unlike it.
                    MouseArea {
                        id: likeButton
                        property bool flash: false
                        implicitWidth: likeIcon.implicitWidth
                        implicitHeight: likeIcon.implicitHeight
                        visible: Media.isSpotifyPlayer
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            Media.like(mouse.button === Qt.RightButton);
                            flash = mouse.button === Qt.LeftButton;
                            flashTimer.restart();
                        }

                        Timer {
                            id: flashTimer
                            interval: 900
                            onTriggered: likeButton.flash = false
                        }

                        BarText {
                            id: likeIcon
                            text: likeButton.flash ? Icons.heart : Icons.heartOutline
                            color: likeButton.flash ? Theme.red : Theme.fgDim
                            font.pixelSize: Theme.fontSize + 3
                        }
                    }

                    Item { Layout.fillWidth: true }

                    BarText {
                        visible: volumeBar.visible
                        text: Icons.volumeMedium
                        color: Theme.fgDim
                    }

                    // Click or drag to set it, scroll to nudge it
                    Rectangle {
                        id: volumeBar
                        // Follows the finger while dragging, then the player's value
                        property real dragValue: -1

                        Layout.preferredWidth: 110
                        implicitHeight: 3
                        visible: Media.volumeAvailable
                        color: Theme.surface

                        Rectangle {
                            width: parent.width * Math.max(0, Math.min(1, volumeBar.dragValue >= 0 ? volumeBar.dragValue : Media.volume))
                            height: parent.height
                            color: Theme.accent
                        }

                        MouseArea {
                            anchors.fill: parent
                            anchors.topMargin: -8
                            anchors.bottomMargin: -8
                            cursorShape: Qt.PointingHandCursor
                            onPressed: mouse => volumeBar.dragValue = mouse.x / width
                            onPositionChanged: mouse => { if (pressed) volumeBar.dragValue = Math.max(0, Math.min(1, mouse.x / width)); }
                            // Applied on release: one command per gesture, not per pixel
                            onReleased: {
                                Media.setVolume(volumeBar.dragValue);
                                volumeBar.dragValue = -1;
                            }
                            onWheel: wheel => Media.setVolume(Media.volume + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))
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
