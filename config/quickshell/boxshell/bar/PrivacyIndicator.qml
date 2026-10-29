import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services
import qs.widgets

// Red icons while the mic, camera or screen is in use; click for which apps.
// Hidden the rest of the time.
MouseArea {
    id: root
    required property var bar
    property bool open: false

    visible: Privacy.active || scale > 0
    implicitWidth: row.implicitWidth + Theme.itemPadding * 2
    implicitHeight: Theme.itemHeight
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    // pop in and out
    scale: Privacy.active ? 1 : 0
    Behavior on scale { NumberAnimation { duration: 260; easing.type: Easing.OutBack } }

    onClicked: {
        drawer.anchorX = Theme.gapSide + mapToItem(null, width, 0).x + drawer.padding
        open = !open
    }

    readonly property var kinds: [
        { key: "mic",    icon: "mic",          label: "microphone" },
        { key: "camera", icon: "videocam",     label: "camera" },
        { key: "screen", icon: "screen_share", label: "screen" },
    ]

    HoverBox { active: root.containsMouse || root.open }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 2

        Repeater {
            model: root.kinds
            Icon {
                required property var modelData
                anchors.verticalCenter: parent.verticalCenter
                visible: Privacy.users[modelData.key].length > 0
                text: modelData.icon
                color: Theme.error

                // slow breathing so it catches the eye
                SequentialAnimation on opacity {
                    running: Privacy.active
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.45; duration: 900; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1; duration: 900; easing.type: Easing.InOutSine }
                }
            }
        }
    }

    Dropdown {
        id: drawer
        screen: root.bar.screen
        WlrLayershell.namespace: "boxshell-tray"
        open: root.open && Privacy.active
        onCloseRequested: root.open = false
        alignRight: true
        boxWidth: 260
        spacing: 4

        Repeater {
            model: root.kinds.filter(k => Privacy.users[k.key].length > 0)

            Row {
                required property var modelData
                leftPadding: 6
                spacing: 8
                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.icon
                    color: Theme.error
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: `${modelData.label}: ${Privacy.users[modelData.key].join(", ")}`
                    width: 210
                    elide: Text.ElideRight
                }
            }
        }
    }
}
