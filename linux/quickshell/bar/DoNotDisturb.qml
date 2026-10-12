import QtQuick
import ".."

// Do Not Disturb switch: click to silence notification popups
MouseArea {
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight
    cursorShape: Qt.PointingHandCursor
    onClicked: NotificationCenter.doNotDisturb = !NotificationCenter.doNotDisturb

    BarText {
        id: label
        text: NotificationCenter.doNotDisturb ? Icons.bellOff : Icons.bell
        color: NotificationCenter.doNotDisturb ? Theme.accentAlt : Theme.fg
    }
}
