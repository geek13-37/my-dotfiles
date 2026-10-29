import QtQuick
import qs

// Square highlight behind a clickable bar item while it's hovered or its
// menu is open. Put it first so it sits under the item's content.
Rectangle {
    property bool active: false
    anchors.fill: parent
    color: Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, active ? 0.14 : 0)
    Behavior on color { ColorAnimation { duration: 120 } }
}
