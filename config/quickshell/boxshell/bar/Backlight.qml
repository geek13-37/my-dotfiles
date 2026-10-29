import QtQuick
import qs
import qs.services
import qs.widgets

// Screen brightness, laptops only; scroll to change it.
MouseArea {
    visible: Brightness.available
    implicitWidth: row.implicitWidth + Theme.itemPadding * 2
    implicitHeight: Theme.itemHeight

    Row {
        id: row
        anchors.centerIn: parent
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
