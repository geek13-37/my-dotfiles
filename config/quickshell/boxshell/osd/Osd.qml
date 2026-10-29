import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.widgets

// Popup with a label, a percentage and a slider at the bottom of the focused
// monitor (volume, brightness). Call show() when the value changes; dragging
// or scrolling the slider emits requested(value) for the owner to apply.
Scope {
    id: root

    property string label
    property real value: 0
    // greyed out, e.g. muted
    property bool dimmed: false
    property bool open: false
    // values get reported once on startup; don't pop up for that
    property bool armed: false

    signal requested(real value)

    function show() {
        if (!armed) return
        open = true
        hideTimer.restart()
    }

    function request(v: real) {
        requested(Math.max(0, Math.min(1, v)))
    }

    Timer { interval: 1000; running: true; onTriggered: root.armed = true }

    Timer {
        id: hideTimer
        interval: 1500
        // stay open while the slider is being dragged; scrolling changes
        // the value, which restarts the timer anyway
        onTriggered: drag.pressed ? restart() : root.open = false
    }

    PanelWindow {
        screen: Quickshell.screens.find(s => Hyprland.monitorFor(s) === Hyprland.focusedMonitor)
                ?? Quickshell.screens[0]
        // keep the window until the hide animation has finished
        visible: root.open || box.opacity > 0

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "boxshell-osd"
        exclusionMode: ExclusionMode.Ignore
        anchors.bottom: true
        margins.bottom: 80
        implicitWidth: 360
        implicitHeight: 80
        color: "transparent"

        Rectangle {
            id: box
            width: parent.width
            height: 64
            color: Theme.glass
            border.color: Theme.surface
            border.width: Theme.border

            // slide up with a small overshoot, fade and grow a little
            y: root.open ? 0 : 16
            opacity: root.open ? 1 : 0
            scale: root.open ? 1 : 0.94
            Behavior on y { NumberAnimation { duration: 280; easing.type: Easing.OutBack } }
            Behavior on opacity { NumberAnimation { duration: 180 } }
            Behavior on scale { NumberAnimation { duration: 280; easing.type: Easing.OutBack } }

            Label {
                anchors { left: parent.left; top: parent.top; leftMargin: 14; topMargin: 12 }
                text: root.label
                color: root.dimmed ? Theme.dim : Theme.fg
            }

            Label {
                id: percent
                anchors { right: parent.right; top: parent.top; rightMargin: 14; topMargin: 12 }
                text: `${Math.round(root.value * 100)}%`
                color: root.dimmed ? Theme.dim : Theme.accent
                font.bold: true
                transformOrigin: Item.Right

                // little jump on every change
                onTextChanged: bump.restart()
                SequentialAnimation {
                    id: bump
                    NumberAnimation { target: percent; property: "scale"; to: 1.25; duration: 70; easing.type: Easing.OutQuad }
                    NumberAnimation { target: percent; property: "scale"; to: 1; duration: 220; easing.type: Easing.OutBack }
                }
            }

            Rectangle {
                id: track
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom
                          leftMargin: 14; rightMargin: 14; bottomMargin: 14 }
                height: 6
                color: Theme.surface

                Rectangle {
                    id: fill
                    width: track.width * Math.max(0, Math.min(root.value, 1))
                    height: parent.height
                    color: root.dimmed ? Theme.dim : Theme.accent
                    Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                // square knob at the end of the fill
                Rectangle {
                    x: fill.width - width / 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: 12
                    height: 12
                    color: fill.color
                    border.color: Theme.bg
                    border.width: 2
                    scale: drag.pressed ? 1.3 : 1
                    Behavior on scale { NumberAnimation { duration: 120 } }
                }

                MouseArea {
                    id: drag
                    // bigger hit area than the thin track
                    anchors { fill: parent; topMargin: -10; bottomMargin: -10 }
                    cursorShape: Qt.PointingHandCursor
                    onPressed: mouse => root.request(mouse.x / track.width)
                    onPositionChanged: mouse => { if (pressed) root.request(mouse.x / track.width) }
                    onWheel: wheel => root.request(root.value + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))
                }
            }
        }
    }
}
