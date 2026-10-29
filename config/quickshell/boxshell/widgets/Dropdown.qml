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
    property int padding: 6
    default property alias content: column.data
    property alias spacing: column.spacing

    signal closeRequested()

    screen: Quickshell.screens.find(s => Hyprland.monitorFor(s) === Hyprland.focusedMonitor)
            ?? Quickshell.screens[0]
    // keep the window until the closing animation has finished
    visible: open || box.opacity > 0

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
        border.color: Theme.surface
        border.width: Theme.border

        // drop down from the bar
        readonly property int openY: Theme.gapTop + Theme.barHeight + 4
        y: root.open ? openY : openY - 8
        opacity: root.open ? 1 : 0
        Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 160 } }

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
