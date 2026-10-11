import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import ".."

// Apps running in the background (system tray). Click opens the app, right
// click shows its menu, middle click its secondary action. Icons are drawn in
// grayscale to match the bar.
RowLayout {
    spacing: 10

    Repeater {
        model: SystemTray.items.values

        delegate: MouseArea {
            id: item
            required property var modelData

            implicitWidth: 16
            implicitHeight: 16
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            cursorShape: Qt.PointingHandCursor

            function showMenu() {
                const point = item.mapToItem(null, 0, item.height + 6);
                modelData.display(QsWindow.window, point.x, point.y);
            }

            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    if (modelData.hasMenu) showMenu();
                } else if (mouse.button === Qt.MiddleButton) {
                    modelData.secondaryActivate();
                } else if (modelData.onlyMenu && modelData.hasMenu) {
                    showMenu();
                } else {
                    modelData.activate();
                }
            }
            onWheel: wheel => modelData.scroll(wheel.angleDelta.y, false)

            IconImage {
                id: icon
                anchors.fill: parent
                source: item.modelData.icon
                visible: false
            }

            MultiEffect {
                anchors.fill: icon
                source: icon
                saturation: -1.0
                brightness: 0.1
            }
        }
    }
}
