import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

// Panel that drops down from a bar item (network, Bluetooth and audio menus).
// Put rows inside it; clicking outside closes it.
PopupWindow {
    id: dropdown

    required property Item anchorItem
    property bool open: false
    property int panelWidth: 320
    default property alias content: column.data

    visible: open
    grabFocus: true
    onVisibleChanged: if (!visible) open = false

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: 10
    implicitWidth: panelWidth
    implicitHeight: panel.implicitHeight
    color: "transparent"

    Rectangle {
        id: panel
        width: parent.width
        implicitHeight: column.implicitHeight + 16
        color: Theme.bgAlt
        border.width: 1
        border.color: Theme.overlay

        ColumnLayout {
            id: column
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 8
            }
            spacing: 2
        }
    }
}
