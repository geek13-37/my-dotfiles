import QtQuick
import qs
import qs.services
import qs.widgets

// Keyboard layout code ("RU"); Caps Lock on adds its icon in the accent
// colour. Click to switch to the next layout.
MouseArea {
    implicitWidth: row.implicitWidth + Theme.itemPadding * 2
    implicitHeight: Theme.itemHeight
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    visible: Keyboard.layouts.length > 1 || Keyboard.capsLock

    HoverBox { active: parent.containsMouse }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 2
        Icon {
            visible: Keyboard.capsLock
            height: Theme.itemHeight
            text: "keyboard_capslock"
            color: Theme.accent
        }
        Label {
            height: Theme.itemHeight
            text: Keyboard.layouts[Keyboard.activeIndex] ?? ""
        }
    }

    onClicked: Keyboard.next()
}
