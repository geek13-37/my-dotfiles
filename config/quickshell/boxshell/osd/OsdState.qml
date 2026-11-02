pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs

// The one OSD window at the bottom of the focused monitor. Every OSD
// (volume, brightness, layout, Caps Lock) is an OsdFrame drawn inside it;
// show() puts that one up and hides the rest.
//
// No QML fade: the window just appears and Hyprland's layer fade does it
// together with the blur. A QML fade on top of that and a window per OSD
// that resized and overlapped the others is what flashed black.
Singleton {
    id: root

    property Item current: null
    property bool open: false
    readonly property Item box: content

    function show(frame: Item) {
        current = frame
        open = true
        hideTimer.restart()
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.current?.held ? restart() : root.open = false
    }

    PanelWindow {
        screen: Quickshell.screens.find(s => Hyprland.monitorFor(s) === Hyprland.focusedMonitor)
                ?? Quickshell.screens[0]
        visible: root.open

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "boxshell-osd"
        exclusionMode: ExclusionMode.Ignore
        anchors.bottom: true
        margins.bottom: 80
        // fixed size so switching between OSDs never resizes the surface;
        // the transparent sides aren't blurred (ignore_alpha in rules.lua)
        implicitWidth: 360
        implicitHeight: 44
        color: "transparent"

        Rectangle {
            id: content
            anchors.centerIn: parent
            width: root.current?.boxWidth ?? 360
            height: parent.height
            color: Theme.glass
        }
    }
}
