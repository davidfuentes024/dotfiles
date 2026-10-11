import QtQuick
import Quickshell.Io
import Quickshell.Services.UPower
import ".."

// Power profile (needs power-profiles-daemon). Click cycles
// saver -> balanced -> performance.
MouseArea {
    id: root
    readonly property int profile: PowerProfiles.profile
    // PowerProfiles reports a default value even without the daemon
    property bool daemonRunning: false

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight
    visible: daemonRunning && label.text !== ""
    cursorShape: Qt.PointingHandCursor

    onClicked: {
        const order = [PowerProfile.PowerSaver, PowerProfile.Balanced];
        if (PowerProfiles.hasPerformanceProfile) order.push(PowerProfile.Performance);
        PowerProfiles.profile = order[(order.indexOf(profile) + 1) % order.length];
    }

    Process {
        id: daemonCheck
        command: ["systemctl", "is-active", "--quiet", "power-profiles-daemon"]
        onExited: exitCode => root.daemonRunning = exitCode === 0
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: daemonCheck.running = true
    }

    BarText {
        id: label
        text: profile === PowerProfile.PowerSaver ? Icons.powerSaver
            : profile === PowerProfile.Performance ? Icons.powerPerformance
            : profile === PowerProfile.Balanced ? Icons.powerBalanced
            : ""
        color: profile === PowerProfile.Performance ? Theme.accentAlt : Theme.fg
    }
}
