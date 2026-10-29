import QtQuick
import qs
import qs.services
import qs.widgets

// Screen brightness, laptops only; scroll to change it.
MouseArea {
    visible: Brightness.available
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row
        spacing: 4
        Icon {
            anchors.verticalCenter: parent.verticalCenter
            text: "brightness_6"
        }
        Label {
            anchors.verticalCenter: parent.verticalCenter
            text: `${Math.round(Brightness.value * 100)}%`
        }
    }

    onWheel: wheel => Brightness.set(Brightness.value + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))
}
