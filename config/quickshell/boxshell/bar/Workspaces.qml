import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs
import qs.widgets

// Workspaces of this monitor as numbered squares. The accent square glides to
// the active one, like Apple's tab selection: quick, soft stop, and the
// numbers turn dark exactly where the square covers them, even mid-move.
Item {
    id: root
    required property ShellScreen screen
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
    // special ones (scratchpad) left out
    readonly property var workspaces: Hyprland.workspaces.values.filter(ws => ws.id > 0 && ws.monitor === root.monitor)
    readonly property int activeIndex: workspaces.indexOf(monitor?.activeWorkspace)
    readonly property int step: Theme.itemHeight + row.spacing

    // grow and shrink smoothly when workspaces come and go, so the items
    // next to it slide over instead of jumping
    implicitWidth: row.implicitWidth
    Behavior on implicitWidth { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    implicitHeight: Theme.itemHeight
    clip: true

    // a bright filled square looks bigger than the faint hover one of the
    // same size, so it's inset a pixel on each side to look the same
    readonly property int inset: 1

    Rectangle {
        id: highlight
        visible: root.activeIndex >= 0
        x: Math.max(0, root.activeIndex) * root.step + root.inset
        y: root.inset
        width: Theme.itemHeight - 2 * root.inset
        height: Theme.itemHeight - 2 * root.inset
        color: Theme.accent
        Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    }

    Row {
        id: row
        spacing: 2

        Repeater {
            model: root.workspaces

            Item {
                id: workspace
                required property HyprlandWorkspace modelData
                required property int index
                readonly property bool active: index === root.activeIndex

                width: Theme.itemHeight
                height: Theme.itemHeight

                // a new workspace fades in while the bar makes room for it
                opacity: 0
                Component.onCompleted: opacity = 1
                Behavior on opacity { NumberAnimation { duration: 180 } }

                // the same hover square as the other bar items
                HoverBox { active: hover.hovered && !workspace.active }

                Label {
                    anchors.centerIn: parent
                    text: workspace.modelData.id
                }

                HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
                TapHandler {
                    // Hyprland 0.56 config is Lua, so dispatch takes Lua too
                    onTapped: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${workspace.modelData.id} })`)
                }
            }
        }
    }

    // the same numbers in the dark colour, showing only inside the square
    Item {
        x: highlight.x
        y: highlight.y
        width: highlight.width
        height: highlight.height
        visible: highlight.visible
        clip: true

        Repeater {
            model: root.workspaces

            Item {
                required property HyprlandWorkspace modelData
                required property int index
                x: index * root.step - highlight.x
                y: -highlight.y
                width: Theme.itemHeight
                height: Theme.itemHeight

                Label {
                    anchors.centerIn: parent
                    text: parent.modelData.id
                    color: Theme.accentText
                }
            }
        }
    }
}
