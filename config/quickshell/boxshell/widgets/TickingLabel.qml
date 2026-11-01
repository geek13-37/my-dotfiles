import QtQuick

// A percentage that ticks through the numbers in between when it changes,
// slowing down as it arrives (same as the OSD's).
Label {
    // 0..1
    property real value: 0
    property real shown: value * 100
    Behavior on shown { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }

    text: `${Math.round(shown)}%`
}
