import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Volume popup: opens on any volume change (media keys, bar, pavucontrol...).
Scope {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink

    PwObjectTracker { objects: [root.sink] }

    Osd {
        id: osd
        label: dimmed ? "muted" : "volume"
        value: root.sink?.audio?.volume ?? 0
        dimmed: root.sink?.audio?.muted ?? false
        onRequested: v => { if (root.sink?.audio) root.sink.audio.volume = v }
    }

    Connections {
        target: root.sink?.audio ?? null
        ignoreUnknownSignals: true
        function onVolumeChanged() { osd.show() }
        function onMutedChanged() { osd.show() }
    }
}
