import QtQuick

// Marks a clickable bar item. While `active` (hovered, or its menu is open)
// the bar's one hover square jumps to this item, like the macOS menu
// bar; Bar.qml draws it. Put it inside the item, it fills it.
Item {
    id: root
    property bool active: false
    anchors.fill: parent

    // the bar item that draws the square, found by walking up
    property Item host: null

    Component.onCompleted: {
        let p = parent
        while (p && p.isHoverHost !== true) p = p.parent
        host = p
        if (active) host?.hoverOn(root)
    }
    onActiveChanged: active ? host?.hoverOn(root) : host?.hoverOff(root)
    Component.onDestruction: host?.hoverOff(root)
}
