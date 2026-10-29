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
        drawer.anchorX = Theme.gapSide + mapToItem(null, width, 0).x + drawer.padding
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
            anchors.verticalCenter: parent.verticalCenter
            text: Battery.icon
            color: root.tint
        }
        Label {
            anchors.verticalCenter: parent.verticalCenter
            text: `${Math.round(Battery.level * 100)}%`
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

        Label {
            leftPadding: 6
            topPadding: 4
            font.bold: true
            text: `${Math.round(Battery.level * 100)}%  ·  ${Battery.full ? "full" : Battery.charging ? "charging" : "on battery"}`
        }
        Label {
            leftPadding: 6
            visible: text !== ""
            color: Theme.dim
            text: Battery.timeText
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
                        color: profileButton.active ? Theme.accent : profileButton.containsMouse ? Theme.surface : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        Icon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: profileButton.modelData.icon
                            color: profileButton.active ? Theme.accentText : Theme.fg
                        }
                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: profileButton.modelData.label
                            font.pixelSize: Theme.fontSize - 2
                            color: profileButton.active ? Theme.accentText : Theme.fg
                        }
                    }
                }
            }
        }
    }
}
