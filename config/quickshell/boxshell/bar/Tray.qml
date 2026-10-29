import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs
import qs.widgets

// Collapsed tray: a chevron in the bar, the icons drop down under it.
// Left click activates an app, right click opens its menu.
MouseArea {
    id: root
    required property var bar
    property bool open: false

    visible: SystemTray.items.values.length > 0
    implicitWidth: chevron.implicitWidth
    implicitHeight: chevron.implicitHeight
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: {
        // the bar is laid out by now, so this lands right under the chevron
        drawer.anchorX = Theme.gapSide + mapToItem(null, 0, 0).x - drawer.padding
        open = !open
    }

    Icon {
        id: chevron
        text: "expand_more"
        color: root.containsMouse || root.open ? Theme.accent : Theme.fg
        rotation: root.open ? 180 : 0
        Behavior on rotation { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    Dropdown {
        id: drawer
        screen: root.bar.screen
        WlrLayershell.namespace: "boxshell-tray"
        open: root.open
        onCloseRequested: root.open = false
        boxWidth: grid.implicitWidth + 2 * drawer.padding

        Grid {
            id: grid
            columns: 6
            spacing: 2

            Repeater {
                model: SystemTray.items

                MouseArea {
                    id: item
                    required property SystemTrayItem modelData
                    required property int index
                    width: 30
                    height: 30
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton && !modelData.onlyMenu) {
                            modelData.activate()
                            root.open = false
                        } else if (modelData.hasMenu) {
                            // the app's own menu, opened right under the icon
                            const pos = item.mapToItem(drawer.contentItem, 0, item.height)
                            modelData.display(drawer, pos.x, pos.y)
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: item.containsMouse ? Theme.surface : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: 18
                        source: item.modelData.icon
                    }

                    // icons pop in one after another
                    Connections {
                        target: root
                        function onOpenChanged() { if (root.open) pop.restart() }
                    }
                    SequentialAnimation {
                        id: pop
                        PropertyAction { target: item; property: "scale"; value: 0.6 }
                        PropertyAction { target: item; property: "opacity"; value: 0 }
                        PauseAnimation { duration: item.index * 30 }
                        ParallelAnimation {
                            NumberAnimation { target: item; property: "scale"; to: 1; duration: 260; easing.type: Easing.OutBack }
                            NumberAnimation { target: item; property: "opacity"; to: 1; duration: 160 }
                        }
                    }
                }
            }
        }
    }
}
