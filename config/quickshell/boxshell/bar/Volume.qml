import QtQuick
import Quickshell.Services.Pipewire
import qs
import qs.widgets

// Volume as a bare percentage (grey when muted). Scroll to change it,
// click to mute.
MouseArea {
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink?.audio?.muted ?? true
    readonly property int percent: Math.round((sink?.audio?.volume ?? 0) * 100)

    implicitWidth: row.implicitWidth + Theme.itemPadding * 2
    implicitHeight: Theme.itemHeight
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    PwObjectTracker { objects: [sink] }

    HoverBox { active: containsMouse }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 4
        TickingLabel {
            height: Theme.itemHeight
            value: sink?.audio?.volume ?? 0
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
