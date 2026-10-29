import QtQuick
import Quickshell.Services.Pipewire
import qs
import qs.widgets

// Scroll to change volume, click to mute.
MouseArea {
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink?.audio?.muted ?? true
    readonly property int percent: Math.round((sink?.audio?.volume ?? 0) * 100)

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    PwObjectTracker { objects: [sink] }

    Row {
        id: row
        spacing: 4
        Icon {
            anchors.verticalCenter: parent.verticalCenter
            text: muted || percent === 0 ? "volume_off" : percent < 50 ? "volume_down" : "volume_up"
            color: muted ? Theme.dim : Theme.fg
        }
        Label {
            anchors.verticalCenter: parent.verticalCenter
            text: `${percent}%`
            color: muted ? Theme.dim : Theme.fg
        }
    }

    onClicked: if (sink?.audio) sink.audio.muted = !sink.audio.muted
    onWheel: wheel => {
        if (!sink?.audio) return
        const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05
        sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + step))
    }
}
