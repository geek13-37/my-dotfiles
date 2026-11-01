import QtQuick
import qs

// Segments you can drag, click or scroll. Emits moved(value) with the new
// 0..1 value; the owner applies it and feeds `value` back.
Item {
    id: root

    property real value: 0
    property bool dimmed: false
    readonly property bool pressed: drag.pressed

    signal moved(real value)

    function request(v: real) {
        moved(Math.max(0, Math.min(1, v)))
    }

    height: 8

    Segments {
        anchors.fill: parent
        value: root.value
        onColor: root.dimmed ? Theme.dim : Theme.accent
    }

    MouseArea {
        id: drag
        // bigger hit area than the thin row
        anchors { fill: parent; topMargin: -10; bottomMargin: -10 }
        cursorShape: Qt.PointingHandCursor
        onPressed: mouse => root.request(mouse.x / root.width)
        onPositionChanged: mouse => { if (pressed) root.request(mouse.x / root.width) }
        onWheel: wheel => root.request(root.value + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))
    }
}
