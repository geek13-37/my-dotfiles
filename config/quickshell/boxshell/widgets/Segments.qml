import QtQuick
import qs

// A level as a row of square segments (20 by default, 5% each). When it
// changes they light up or go out in a wave from the edge, and a segment that
// just lit up flashes a little bigger. Used by the OSD slider and the battery.
Row {
    id: root

    // 0..1
    property real value: 0
    property int count: 20
    property color onColor: Theme.accent
    property color offColor: Theme.surface
    readonly property int lit: Math.round(Math.max(0, Math.min(1, value)) * count)

    spacing: 3

    Repeater {
        model: root.count

        Rectangle {
            id: segment
            required property int index
            readonly property bool on: index < root.lit

            width: (root.width - root.spacing * (root.count - 1)) / root.count
            height: root.height
            color: on ? root.onColor : root.offColor

            // a wave: segments further from the edge change a bit later
            Behavior on color {
                SequentialAnimation {
                    PauseAnimation { duration: Math.min(180, Math.abs(segment.index - root.lit) * 15) }
                    ColorAnimation { duration: 120 }
                }
            }

            onOnChanged: if (on) flash.restart()
            SequentialAnimation {
                id: flash
                NumberAnimation { target: segment; property: "scale"; to: 1.35; duration: 70; easing.type: Easing.OutQuad }
                NumberAnimation { target: segment; property: "scale"; to: 1; duration: 200; easing.type: Easing.OutCubic }
            }
        }
    }
}
