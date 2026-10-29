import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
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
            anchors.fill: parent

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "black"
                shadowBlur: 0.35
                shadowVerticalOffset: 1
                shadowHorizontalOffset: 0
                shadowOpacity: 0.5
            }

            RowLayout {
                anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 6 }
                spacing: Theme.spacing
                Workspaces { screen: bar.modelData }
                Tray { bar: bar }
            }

            Clock { anchors.centerIn: parent }

            RowLayout {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 10 }
                spacing: Theme.spacing
                PrivacyIndicator { bar: bar }
                DockerButton { bar: bar }
                Network {}
                // laptop only, hidden on a desktop
                Backlight {}
                Volume {}
                BatteryButton { bar: bar }
                PowerButton {}
            }
        }
    }
}
