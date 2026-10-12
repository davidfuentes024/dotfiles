import QtQuick
import QtQuick.Layouts
import ".."

// One row of a Dropdown: icon, label, optional detail on the right
MouseArea {
    id: row

    property string icon: ""
    property string label: ""
    property string detail: ""
    property bool active: false
    property bool dim: false

    Layout.fillWidth: true
    implicitHeight: 34
    hoverEnabled: true
    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

    Rectangle {
        anchors.fill: parent
        color: row.containsMouse && row.enabled ? Theme.surface : "transparent"
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10

        BarText {
            text: row.icon
            color: row.active ? Theme.accent : Theme.fgDim
            Layout.preferredWidth: 18
        }
        BarText {
            Layout.fillWidth: true
            text: row.label
            color: row.active ? Theme.accent : row.dim ? Theme.fgDim : Theme.fg
            elide: Text.ElideRight
        }
        BarText {
            text: row.detail
            color: Theme.fgDim
            font.pixelSize: Theme.fontSize - 2
        }
    }
}
