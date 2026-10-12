import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import ".."
import "../bar"

// One notification: app name, title, body and its action buttons. Click to
// dismiss. Closes itself after a few seconds unless critical or hovered.
Rectangle {
    id: popup
    required property var notification
    readonly property bool critical: notification.urgency === NotificationUrgency.Critical

    implicitWidth: 360
    implicitHeight: content.implicitHeight + 20
    color: Theme.bgAlt
    border.width: 1
    border.color: critical ? Theme.red : Theme.overlay

    Timer {
        // Apps may ask for their own timeout; 5 s otherwise
        interval: popup.notification.expireTimeout > 0 ? popup.notification.expireTimeout : 5000
        running: !popup.critical && !hover.containsMouse
        onTriggered: NotificationCenter.removePopup(popup.notification)
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        onClicked: popup.notification.dismiss()
    }

    ColumnLayout {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 10
        }
        spacing: 4

        BarText {
            Layout.fillWidth: true
            text: popup.notification.appName
            color: Theme.fgDim
            font.pixelSize: Theme.fontSize - 2
            elide: Text.ElideRight
            visible: text !== ""
        }

        BarText {
            Layout.fillWidth: true
            text: popup.notification.summary
            color: popup.critical ? Theme.red : Theme.fg
            font.bold: true
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }

        BarText {
            Layout.fillWidth: true
            text: popup.notification.body
            textFormat: Text.PlainText
            wrapMode: Text.Wrap
            maximumLineCount: 4
            elide: Text.ElideRight
            visible: text !== ""
        }

        RowLayout {
            Layout.topMargin: 4
            spacing: 6
            visible: popup.notification.actions.length > 0

            Repeater {
                model: popup.notification.actions

                delegate: MouseArea {
                    required property var modelData
                    implicitWidth: actionLabel.implicitWidth + 16
                    implicitHeight: actionLabel.implicitHeight + 8
                    cursorShape: Qt.PointingHandCursor
                    onClicked: modelData.invoke()

                    Rectangle {
                        anchors.fill: parent
                        color: parent.containsMouse ? Theme.overlay : Theme.surface
                    }
                    BarText {
                        id: actionLabel
                        anchors.centerIn: parent
                        text: modelData.text
                        color: Theme.accent
                    }
                }
            }
        }
    }
}
