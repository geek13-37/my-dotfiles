import QtQuick
import qs

// A section title in a dropdown: accent icon and bold title, lined up with
// the rest of the menu content (Theme.menuInset). Children go over the right
// side, e.g. a value anchored to parent.right.
Item {
    property string icon
    property string title
    default property alias extra: right.data

    x: Theme.menuInset
    width: (parent?.width ?? 0) - 2 * Theme.menuInset
    height: 24

    Icon {
        id: glyph
        anchors.verticalCenter: parent.verticalCenter
        text: parent.icon
        color: Theme.accent
    }
    Label {
        anchors { left: glyph.right; leftMargin: 8; verticalCenter: parent.verticalCenter }
        text: parent.title
        font.bold: true
    }
    Item {
        id: right
        anchors.fill: parent
    }
}
