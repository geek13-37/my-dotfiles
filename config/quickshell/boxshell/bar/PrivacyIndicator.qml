import QtQuick
import QtQuick.Layouts
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

    // 0 hidden .. 1 shown: it opens up its room in the bar (spacing included)
    // and fades in, so the neighbours slide instead of jumping
    property real shown: Privacy.active ? 1 : 0
    Behavior on shown { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    visible: shown > 0
    Layout.leftMargin: (shown - 1) * Theme.spacing
    clip: true
    readonly property int kindsActive: kinds.filter(k => Privacy.users[k.key].length > 0).length
    // a square for a single icon
    implicitWidth: shown * (kindsActive > 1 ? row.implicitWidth + Theme.itemPadding * 2 : Theme.itemHeight)
    implicitHeight: Theme.itemHeight
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    opacity: shown

    onClicked: {
        drawer.anchorX = Theme.gapSide + mapToItem(null, width, 0).x
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
                height: Theme.itemHeight
                visible: Privacy.users[modelData.key].length > 0
                text: modelData.icon
                color: Theme.error
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
                leftPadding: Theme.menuInset
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
