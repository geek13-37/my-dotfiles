import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs
import qs.services
import qs.widgets

PanelWindow {
    id: bar
    required property ShellScreen modelData
    screen: modelData

    anchors { top: true; left: true; right: true }
    margins { top: Theme.gapTop; left: Theme.gapSide; right: Theme.gapSide }
    implicitHeight: Theme.barHeight
    color: "transparent"
    WlrLayershell.namespace: "boxshell-bar"

    Item {
        anchors.fill: parent

        // blurred by Hyprland behind, see Theme.glass
        Rectangle {
            anchors.fill: parent
            color: Theme.glass
            Behavior on color { ColorAnimation { duration: 400 } }
        }

        Item {
            id: content
            anchors.fill: parent

            // One hover square for the whole bar (see widgets/HoverBox.qml):
            // items say when they're active, the square sits on the latest.
            readonly property bool isHoverHost: true
            property var hoverStack: []
            readonly property Item hoverTarget: hoverStack.length ? hoverStack[hoverStack.length - 1] : null
            function hoverOn(item) {
                hoverStack = hoverStack.filter(i => i !== item).concat([item])
            }
            function hoverOff(item) {
                hoverStack = hoverStack.filter(i => i !== item)
            }

            // no glide or fade: it just sits on whatever is hovered
            Rectangle {
                id: hoverSquare
                readonly property Item target: content.hoverTarget

                color: Theme.hover
                visible: target !== null

                function follow() {
                    if (!target) return
                    const p = target.mapToItem(content, 0, 0)
                    x = p.x
                    y = p.y
                    width = target.width
                    height = target.height
                }

                onTargetChanged: follow()

                // items change size as their numbers update and the bar lays
                // itself out after startup: keep matching the target
                Connections {
                    target: hoverSquare.target
                    function onWidthChanged() { hoverSquare.follow() }
                    function onHeightChanged() { hoverSquare.follow() }
                }
                Timer {
                    interval: 250
                    running: hoverSquare.target !== null
                    repeat: true
                    onTriggered: hoverSquare.follow()
                }
            }

            RowLayout {
                anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: Theme.itemInset }
                spacing: Theme.spacing
                Workspaces { screen: bar.modelData }
                Tray { bar: bar }
                Stats { bar: bar }
            }

            Clock { anchors.centerIn: parent }

            RowLayout {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: Theme.itemInset }
                spacing: Theme.spacing
                PrivacyIndicator { bar: bar }
                DockerButton { bar: bar }
                Network {}
                LayoutButton {}
                // laptop only, hidden on a desktop
                Backlight {}
                Volume {}
                BatteryButton { bar: bar }
                ControlButton { bar: bar }
                PowerButton {}
            }
        }
    }
}
