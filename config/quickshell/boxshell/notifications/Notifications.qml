import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import qs

// Notification daemon, popups stack in the top-right corner under the bar.
Scope {
    NotificationServer {
        id: server
        keepOnReload: true
        actionsSupported: true
        imageSupported: true
        bodyMarkupSupported: true
        onNotification: n => n.tracked = true
    }

    PanelWindow {
        screen: Quickshell.screens.find(s => Hyprland.monitorFor(s) === Hyprland.focusedMonitor)
                ?? Quickshell.screens[0]
        visible: server.trackedNotifications.values.length > 0

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "boxshell-notifications"
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; right: true }
        margins { top: Theme.gapTop + Theme.barHeight + 6; right: Theme.gapSide }
        implicitWidth: 360
        implicitHeight: Math.max(1, column.implicitHeight)
        color: "transparent"

        Column {
            id: column
            width: parent.width
            spacing: 6

            // cards below a closed one slide up into its place
            move: Transition {
                NumberAnimation { property: "y"; duration: 220; easing.type: Easing.OutCubic }
            }

            Repeater {
                model: server.trackedNotifications
                NotificationCard {}
            }
        }
    }
}
