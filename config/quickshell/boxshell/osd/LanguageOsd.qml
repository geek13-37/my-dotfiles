import QtQuick
import qs
import qs.services
import qs.widgets

// Keyboard layout popup: icon and the layout's name, nothing moving inside.
OsdFrame {
    id: root
    boxWidth: row.implicitWidth + 2 * 14

    Connections {
        target: Keyboard
        function onSwitched() { root.show() }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 10
        Icon { text: "keyboard"; font.pixelSize: 20; anchors.verticalCenter: parent.verticalCenter }
        Label { text: Keyboard.activeName; anchors.verticalCenter: parent.verticalCenter }
    }
}
