import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs
import qs.widgets

Row {
    id: root
    required property ShellScreen screen
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
    spacing: 3

    Repeater {
        // workspaces of this monitor only, hide special ones (scratchpad)
        model: Hyprland.workspaces.values.filter(ws => ws.id > 0 && ws.monitor === root.monitor)

        Rectangle {
            required property HyprlandWorkspace modelData
            readonly property bool active: root.monitor?.activeWorkspace === modelData

            width: 22
            height: 20
            color: active ? Theme.accent : (hover.hovered ? Theme.surface : "transparent")

            Label {
                anchors.centerIn: parent
                text: modelData.id
                color: active ? Theme.accentText : Theme.fg
            }

            HoverHandler { id: hover }
            TapHandler {
                // Hyprland 0.56 config is Lua, so dispatch takes Lua too
                onTapped: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${modelData.id} })`)
            }
        }
    }
}
