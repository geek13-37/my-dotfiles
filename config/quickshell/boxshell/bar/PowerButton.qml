import QtQuick
import qs
import qs.widgets
import qs.session

// Opens the session menu (sleep, log out, reboot, power off).
MouseArea {
    implicitWidth: icon.implicitWidth + Theme.itemPadding * 2
    implicitHeight: Theme.itemHeight
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: SessionMenu.toggle()

    HoverBox { active: parent.containsMouse || SessionMenu.open }

    Icon {
        id: icon
        anchors.centerIn: parent
        text: "power_settings_new"
        color: parent.containsMouse || SessionMenu.open ? Theme.accent : Theme.fg
        Behavior on color { ColorAnimation { duration: 120 } }
    }
}
