import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs

// A box that drops down under the bar. The window is fullscreen and
// transparent while open, so a click anywhere outside the box (the bar
// button that opened it included) or Esc asks to close it.
PanelWindow {
    id: root

    // owned by the caller; set it back to false on closeRequested
    property bool open: false
    // screen x of the box's left edge, or of its right edge with alignRight
    property real anchorX: 0
    property bool alignRight: false
    property int boxWidth: 220
    property int padding: Theme.menuPadding
    default property alias content: column.data
    property alias spacing: column.spacing

    signal closeRequested()

    screen: Quickshell.screens.find(s => Hyprland.monitorFor(s) === Hyprland.focusedMonitor)
            ?? Quickshell.screens[0]
    // Hyprland fades the whole layer in and out (layers animation), blur
    // included; fading the box ourselves first left the blur to vanish in a
    // jump at the end
    visible: open

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onPressed: root.closeRequested()
    }

    Rectangle {
        id: box
        width: root.boxWidth
        height: column.implicitHeight + 2 * root.padding
        // stay on screen, lined up with the bar's edges
        x: Math.max(Theme.gapSide, Math.min(root.alignRight ? root.anchorX - width : root.anchorX,
                                            root.width - width - Theme.gapSide))
        color: Theme.glass

        // just under the bar
        y: Theme.gapTop + Theme.barHeight + Theme.menuGap

        focus: true
        Keys.onEscapePressed: root.closeRequested()

        // clicks on the box's own padding must not reach the closer below
        MouseArea { anchors.fill: parent }

        Column {
            id: column
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: root.padding }
            spacing: 2
        }
    }
}
