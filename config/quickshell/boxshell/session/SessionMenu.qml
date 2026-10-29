pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.widgets

// Power menu that drops down under the bar's power button.
// Also: qs -c boxshell ipc call session toggle
// Destructive actions need a second click within 3 seconds.
Singleton {
    id: root

    property bool open: false

    readonly property var actions: [
        { icon: "bedtime",            label: "Sleep",     confirm: false, command: ["systemctl", "suspend"] },
        { icon: "logout",             label: "Log out",   confirm: true,  command: ["hyprctl", "dispatch", "hl.dsp.exit()"] },
        { icon: "restart_alt",        label: "Reboot",    confirm: true,  command: ["systemctl", "reboot"] },
        { icon: "power_settings_new", label: "Power off", confirm: true,  command: ["systemctl", "poweroff"] },
    ]

    function toggle() {
        open = !open
    }

    IpcHandler {
        target: "session"
        function toggle(): void { root.toggle() }
    }

    // Fullscreen and transparent while open: a click anywhere outside the
    // menu (the bar's power button included) closes it.
    PanelWindow {
        id: panel
        screen: Quickshell.screens.find(s => Hyprland.monitorFor(s) === Hyprland.focusedMonitor)
                ?? Quickshell.screens[0]
        // keep the window until the closing animation has finished
        visible: root.open || box.opacity > 0

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "boxshell-session"
        WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onPressed: root.open = false
        }

        Rectangle {
            id: box
            // under the bar's power button
            x: parent.width - width - Theme.gapSide
            width: 220
            height: column.implicitHeight + 12
            color: Theme.glass
            border.color: Theme.surface
            border.width: Theme.border

            // drop down from the bar
            readonly property int openY: Theme.gapTop + Theme.barHeight + 4
            y: root.open ? openY : openY - 8
            opacity: root.open ? 1 : 0
            Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 160 } }

            focus: true
            Keys.onEscapePressed: root.open = false

            // clicks on the menu's own padding must not reach the closer below
            MouseArea { anchors.fill: parent }

            Column {
                id: column
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 6 }
                spacing: 2

                Repeater {
                    model: root.actions

                    MouseArea {
                        id: button
                        required property var modelData
                        required property int index
                        property bool armed: false

                        width: column.width
                        height: 36
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (modelData.confirm && !armed) {
                                armed = true
                                disarm.restart()
                                return
                            }
                            root.open = false
                            Quickshell.execDetached(modelData.command)
                        }

                        Timer { id: disarm; interval: 3000; onTriggered: button.armed = false }

                        Connections {
                            target: root
                            function onOpenChanged() {
                                if (root.open) enter.restart()
                                else button.armed = false
                            }
                        }

                        // rows slide in one after another
                        SequentialAnimation {
                            id: enter
                            PropertyAction { target: button; property: "opacity"; value: 0 }
                            PropertyAction { target: button; property: "x"; value: 14 }
                            PauseAnimation { duration: button.index * 40 }
                            ParallelAnimation {
                                NumberAnimation { target: button; property: "opacity"; to: 1; duration: 180 }
                                NumberAnimation { target: button; property: "x"; to: 0; duration: 280; easing.type: Easing.OutBack }
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: button.armed ? Theme.error : button.containsMouse ? Theme.surface : "transparent"
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        Row {
                            anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                            spacing: 10
                            Icon {
                                text: button.modelData.icon
                                color: button.armed ? Theme.errorText : Theme.fg
                            }
                            Label {
                                text: button.armed ? "click again" : button.modelData.label
                                color: button.armed ? Theme.errorText : Theme.fg
                            }
                        }
                    }
                }
            }
        }
    }
}
