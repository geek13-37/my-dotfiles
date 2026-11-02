import QtQuick
import qs
import qs.widgets

// Popup with an icon, a slider and a percentage in one row at the bottom of the focused
// monitor (volume, brightness). Call show() when the value changes; dragging
// or scrolling the slider emits requested(value) for the owner to apply.
//
// It just fades in and out quickly. The slider is a row of square segments
// that light up in a wave, the percentage ticks up or down to the new value.
OsdFrame {
    id: root

    // Material Symbols name
    property string icon
    property real value: 0
    // greyed out, e.g. muted
    property bool dimmed: false

    signal requested(real value)

    function request(v: real) {
        requested(Math.max(0, Math.min(1, v)))
    }

    // stay open while the slider is being dragged; scrolling changes the
    // value, which restarts the timer anyway
    held: slider.pressed

    Item {
        anchors.fill: parent

        Icon {
            id: icon
            anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
            text: root.icon
            font.pixelSize: 20
            color: root.dimmed ? Theme.dim : Theme.fg
            Behavior on color { ColorAnimation { duration: 200 } }
        }

        TickingLabel {
            id: percent
            value: root.value

            anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
            // as wide as "100%", so the slider doesn't shift as it ticks
            width: sizer.implicitWidth
            horizontalAlignment: Text.AlignRight
            color: root.dimmed ? Theme.dim : Theme.accent
            font.bold: true
            Label { id: sizer; visible: false; text: "100%"; font: percent.font }
        }

        // 20 square segments, 5% each
        SegmentSlider {
            id: slider
            anchors { left: icon.right; right: percent.left; leftMargin: 12; rightMargin: 12
                      verticalCenter: parent.verticalCenter }
            value: root.value
            dimmed: root.dimmed
            onMoved: v => root.request(v)
        }
    }
}
