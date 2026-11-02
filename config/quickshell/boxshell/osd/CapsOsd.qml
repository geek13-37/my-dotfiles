import QtQuick
import qs
import qs.services
import qs.widgets

// Caps Lock popup: lit icon and "Caps Lock" when on, grey when off.
OsdFrame {
    id: root
    boxWidth: row.implicitWidth + 2 * 14

    Connections {
        target: Keyboard
        function onCapsToggled() { root.show() }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 10
        Icon {
            text: "keyboard_capslock"
            font.pixelSize: 20
            color: Keyboard.capsLock ? Theme.accent : Theme.dim
            anchors.verticalCenter: parent.verticalCenter
        }
        Label {
            text: Keyboard.capsLock ? "Caps Lock on" : "Caps Lock off"
            color: Keyboard.capsLock ? Theme.fg : Theme.dim
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
