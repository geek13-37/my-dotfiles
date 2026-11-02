import QtQuick
import qs

// One OSD's contents, drawn in the shared OSD window (OsdState). Call show()
// to put it up; it hides 1.5s later.
Item {
    id: root

    // values get reported once on startup; don't pop up for that
    property bool armed: false
    // keep it open, e.g. while a slider is dragged
    property bool held: false
    // the slider ones are wide; text ones size the box to their content
    property int boxWidth: 360

    function show() {
        if (armed) OsdState.show(root)
    }

    parent: OsdState.box
    anchors.fill: parent
    visible: OsdState.current === root

    Timer { interval: 1000; running: true; onTriggered: root.armed = true }
}
