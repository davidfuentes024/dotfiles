import QtQuick
import QtQuick.Layouts
import ".."

// Title of a Dropdown with an on/off switch on the right
RowLayout {
    id: header

    property string title: ""
    property bool checked: false
    property bool showSwitch: true
    signal toggled()

    Layout.fillWidth: true
    Layout.leftMargin: 10
    Layout.rightMargin: 10
    Layout.bottomMargin: 4
    implicitHeight: 32

    BarText {
        Layout.fillWidth: true
        text: header.title
        font.bold: true
    }

    // Small flat switch
    MouseArea {
        visible: header.showSwitch
        implicitWidth: 34
        implicitHeight: 18
        cursorShape: Qt.PointingHandCursor
        onClicked: header.toggled()

        Rectangle {
            anchors.fill: parent
            color: header.checked ? Theme.accent : Theme.surface
        }
        Rectangle {
            width: 14
            height: 14
            y: 2
            x: header.checked ? parent.width - width - 2 : 2
            color: header.checked ? Theme.bg : Theme.fgDim
            Behavior on x { NumberAnimation { duration: 120 } }
        }
    }
}
