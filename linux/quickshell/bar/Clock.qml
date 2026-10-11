import QtQuick
import Quickshell
import ".."

BarText {
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    text: Qt.formatDateTime(clock.date, "ddd dd MMM   HH:mm")
}
