import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower
import qs
import qs.services
import qs.widgets

// Battery level, laptops only. Click: charge details and the power profile
// (power saver / balanced / performance, via power-profiles-daemon).
MouseArea {
    id: root
    required property var bar
    property bool open: false

    visible: Battery.present
    implicitWidth: row.implicitWidth + Theme.itemPadding * 2
    implicitHeight: Theme.itemHeight
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: {
        drawer.anchorX = Theme.gapSide + mapToItem(null, width, 0).x
        open = !open
    }

    readonly property color tint: Battery.low ? Theme.error
                                : containsMouse || open ? Theme.accent : Theme.fg

    HoverBox { active: root.containsMouse || root.open }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 2
        Icon {
            height: Theme.itemHeight
            text: Battery.icon
            color: root.tint
        }
        TickingLabel {
            height: Theme.itemHeight
            value: Battery.level
            color: root.tint
        }
    }

    Dropdown {
        id: drawer
        screen: root.bar.screen
        WlrLayershell.namespace: "boxshell-tray"
        open: root.open
        onCloseRequested: root.open = false
        alignRight: true
        boxWidth: 240
        spacing: 6

        MenuHeader {
            icon: Battery.icon
            title: `${Math.round(Battery.level * 100)}%  ·  ${Battery.full ? "full" : Battery.charging ? "charging" : "on battery"}`
        }
        Label {
            leftPadding: Theme.menuInset
            visible: text !== ""
            color: Theme.dim
            text: Battery.timeText
        }

        Segments {
            x: Theme.menuInset
            width: parent.width - 2 * Theme.menuInset
            height: 8
            value: Battery.level
            onColor: Battery.low ? Theme.error : Theme.accent
        }

        Row {
            visible: PowerProfiles.profile !== undefined
            spacing: 2

            Repeater {
                model: [
                    { profile: PowerProfile.PowerSaver,  icon: "energy_savings_leaf", label: "saver" },
                    { profile: PowerProfile.Balanced,    icon: "balance",             label: "balanced" },
                    { profile: PowerProfile.Performance, icon: "speed",               label: "performance" },
                ].filter(p => p.profile !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile)

                MouseArea {
                    id: profileButton
                    required property var modelData
                    readonly property bool active: PowerProfiles.profile === modelData.profile
                    width: 76
                    height: 44
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: PowerProfiles.profile = modelData.profile

                    Rectangle {
                        anchors.fill: parent
                        color: profileButton.active || profileButton.containsMouse ? Theme.accent : Theme.clear(Theme.accent)
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        Icon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: profileButton.modelData.icon
                            color: profileButton.active || profileButton.containsMouse ? Theme.accentText : Theme.fg
                        }
                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: profileButton.modelData.label
                            font.pixelSize: Theme.fontSize - 2
                            color: profileButton.active || profileButton.containsMouse ? Theme.accentText : Theme.fg
                        }
                    }
                }
            }
        }
    }
}
