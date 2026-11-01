import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.control
import qs.widgets

// Opens the control center: sound output and input, their volume and
// devices. Super+S too.
MouseArea {
    id: root
    required property var bar
    // the keybind opens it on the focused monitor only
    readonly property bool open: ControlCenter.open && Hyprland.monitorFor(bar.screen) === Hyprland.focusedMonitor

    implicitWidth: Theme.itemHeight
    implicitHeight: Theme.itemHeight
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: ControlCenter.toggle()
    onOpenChanged: if (open) drawer.anchorX = Theme.gapSide + mapToItem(null, width, 0).x

    HoverBox { active: root.containsMouse || root.open }

    Icon {
        anchors.centerIn: parent
        text: "tune"
        color: root.containsMouse || root.open ? Theme.accent : Theme.fg
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    Dropdown {
        id: drawer
        screen: root.bar.screen
        WlrLayershell.namespace: "boxshell-tray"
        open: root.open
        onCloseRequested: ControlCenter.open = false
        alignRight: true
        boxWidth: 340
        spacing: 14

        AudioSection { width: parent.width; output: true }
        AudioSection { width: parent.width; output: false }
    }
}
