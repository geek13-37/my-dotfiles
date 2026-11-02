import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs
import qs.widgets

// Workspaces of this monitor as numbered squares. The active one is filled
// with the accent; on a switch the old square fades out and the new one in
// where they are, nothing slides.
Item {
    id: root
    required property ShellScreen screen
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
    // special ones (scratchpad) left out
    readonly property var workspaces: Hyprland.workspaces.values.filter(ws => ws.id > 0 && ws.monitor === root.monitor)
    readonly property int activeIndex: workspaces.indexOf(monitor?.activeWorkspace)

    // grow and shrink smoothly when workspaces come and go, so the items
    // next to it slide over instead of jumping
    implicitWidth: row.implicitWidth
    Behavior on implicitWidth { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    implicitHeight: Theme.itemHeight
    clip: true

    // a bright filled square looks bigger than the faint hover one of the
    // same size, so it's inset a pixel on each side to look the same
    readonly property int inset: 1

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

                Rectangle {
                    anchors { fill: parent; margins: root.inset }
                    color: Theme.accent
                    opacity: workspace.active ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 120 } }
                }

                Label {
                    anchors.centerIn: parent
                    text: workspace.modelData.id
                    color: workspace.active ? Theme.accentText : Theme.fg
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
                TapHandler {
                    // Hyprland 0.56 config is Lua, so dispatch takes Lua too
                    onTapped: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${workspace.modelData.id} })`)
                }
            }
        }
    }
}
