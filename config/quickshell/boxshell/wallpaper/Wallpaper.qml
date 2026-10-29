import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

// Draws the wallpaper on the background layer of one monitor.
PanelWindow {
    required property ShellScreen modelData
    screen: modelData

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "boxshell-wallpaper"
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    color: "black"

    // the picture on screen now
    Image {
        id: current
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(width, height)
        // already decoded by `next`, so this is a cache hit and doesn't flicker
        asynchronous: false
    }

    // the new picture loads here and fades in over the old one
    Image {
        id: next
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(width, height)
        asynchronous: true
        opacity: 0
        source: Scheme.wallpaper
        onStatusChanged: if (status === Image.Ready) fade.restart()
    }

    SequentialAnimation {
        id: fade
        NumberAnimation { target: next; property: "opacity"; from: 0; to: 1; duration: 600; easing.type: Easing.InOutQuad }
        ScriptAction {
            script: {
                current.source = next.source
                next.opacity = 0
            }
        }
    }
}
