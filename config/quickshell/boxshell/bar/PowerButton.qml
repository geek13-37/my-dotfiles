import QtQuick
import qs
import qs.widgets
import qs.session

// Opens the session menu (sleep, log out, reboot, power off).
MouseArea {
    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: SessionMenu.toggle()

    Icon {
        id: icon
        text: "power_settings_new"
        color: parent.containsMouse || SessionMenu.open ? Theme.accent : Theme.fg
        Behavior on color { ColorAnimation { duration: 120 } }
    }
}
