pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

// Notification daemon (replaces mako). Keeps the list of popups on screen and
// the Do Not Disturb switch, shared by the popups and the bar.
Singleton {
    id: root

    property bool doNotDisturb: false
    // Notifications currently shown as popups, newest first
    property list<QtObject> popups: []

    function removePopup(notification) {
        popups = popups.filter(item => item !== notification);
    }

    NotificationServer {
        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        // Plain text bodies: no markup, links or images
        bodyMarkupSupported: false
        imageSupported: false

        onNotification: notification => {
            notification.tracked = true;
            // Critical ones (e.g. low battery) get through Do Not Disturb
            if (root.doNotDisturb && notification.urgency !== NotificationUrgency.Critical) return;
            root.popups = [notification, ...root.popups];
            notification.closed.connect(() => root.removePopup(notification));
        }
    }

    // `qs ipc call notifications toggleDnd | setDnd <bool> | dismissAll`
    // (Do Not Disturb is also used by game mode later)
    IpcHandler {
        target: "notifications"
        function toggleDnd(): void { root.doNotDisturb = !root.doNotDisturb; }
        function setDnd(enabled: bool): void { root.doNotDisturb = enabled; }
        function dismissAll(): void {
            for (const notification of root.popups) notification.dismiss();
        }
    }
}
