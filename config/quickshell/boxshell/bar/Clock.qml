import QtQuick
import Quickshell
import qs
import qs.widgets

Label {
    color: Theme.fg
    SystemClock { id: clock; precision: SystemClock.Minutes }
    text: Qt.formatDateTime(clock.date, "ddd dd MMM  HH:mm")
}
