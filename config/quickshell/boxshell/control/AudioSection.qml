import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs
import qs.widgets

// One half of the sound settings: the default output (or input), its volume
// as a segment slider (click the icon to mute) and the devices to switch to.
Column {
    id: root

    property bool output: true

    readonly property PwNode current: output ? Pipewire.defaultAudioSink : Pipewire.defaultAudioSource
    readonly property var devices: Pipewire.nodes.values.filter(n => n.audio && !n.isStream && n.isSink === root.output)
    readonly property real volume: current?.audio?.volume ?? 0
    readonly property bool muted: current?.audio?.muted ?? false

    PwObjectTracker { objects: root.devices }

    spacing: 4

    function deviceIcon(node): string {
        const name = `${node?.name ?? ""} ${node?.description ?? ""}`.toLowerCase()
        if (!root.output) return /headset|bluez/.test(name) ? "headset_mic" : "mic"
        if (/headphone|headset|bluez/.test(name)) return "headphones"
        if (/hdmi|displayport/.test(name)) return "tv"
        return "speaker"
    }

    MenuHeader {
        icon: root.output ? "speaker" : "mic"
        title: root.output ? "Output" : "Input"
    }

    Item {
        width: parent.width
        height: Theme.itemHeight

        MouseArea {
            id: mute
            // its icon lines up with the device icons below
            x: Theme.menuInset - (Theme.itemHeight - Theme.iconSize) / 2
            width: Theme.itemHeight
            height: Theme.itemHeight
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: if (root.current?.audio) root.current.audio.muted = !root.muted

            Rectangle {
                anchors.fill: parent
                color: mute.containsMouse ? Theme.accent : Theme.clear(Theme.accent)
                Behavior on color { ColorAnimation { duration: 120 } }
            }
            Icon {
                anchors.centerIn: parent
                text: root.output
                      ? (root.muted || root.volume === 0 ? "volume_off" : root.volume < 0.5 ? "volume_down" : "volume_up")
                      : (root.muted ? "mic_off" : "mic")
                color: mute.containsMouse ? Theme.accentText : root.muted ? Theme.dim : Theme.fg
            }
        }

        SegmentSlider {
            anchors { left: mute.right; right: percent.left; leftMargin: 10; rightMargin: 10
                      verticalCenter: parent.verticalCenter }
            value: root.volume
            dimmed: root.muted
            onMoved: v => { if (root.current?.audio) root.current.audio.volume = v }
        }

        TickingLabel {
            id: percent
            anchors { right: parent.right; rightMargin: Theme.menuInset; verticalCenter: parent.verticalCenter }
            width: sizer.implicitWidth
            horizontalAlignment: Text.AlignRight
            value: root.volume
            color: root.muted ? Theme.dim : Theme.accent
            font.bold: true
            Label { id: sizer; visible: false; text: "100%"; font: percent.font }
        }
    }

    Repeater {
        model: root.devices

        MouseArea {
            id: device
            required property PwNode modelData
            readonly property bool selected: modelData === root.current

            width: root.width
            height: 30
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.output) Pipewire.preferredDefaultAudioSink = modelData
                else Pipewire.preferredDefaultAudioSource = modelData
            }

            readonly property color ink: containsMouse ? Theme.accentText : Theme.fg

            Rectangle {
                anchors.fill: parent
                color: device.containsMouse ? Theme.accent : Theme.clear(Theme.accent)
                Behavior on color { ColorAnimation { duration: 120 } }
            }

            Icon {
                id: deviceIcon
                anchors { left: parent.left; leftMargin: Theme.menuInset; verticalCenter: parent.verticalCenter }
                text: root.deviceIcon(device.modelData)
                color: device.ink
            }
            Label {
                anchors { left: deviceIcon.right; leftMargin: 10; right: check.left; rightMargin: 8
                          verticalCenter: parent.verticalCenter }
                elide: Text.ElideRight
                text: device.modelData.description || device.modelData.nickname || device.modelData.name
                color: device.ink
                font.bold: device.selected
            }
            Icon {
                id: check
                anchors { right: parent.right; rightMargin: Theme.menuInset; verticalCenter: parent.verticalCenter }
                visible: device.selected
                text: "check"
                color: device.containsMouse ? Theme.accentText : Theme.accent
            }
        }
    }
}
