pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Who's using the microphone, camera or screen right now, read from PipeWire
// links: a mic/camera node, or Hyprland's screencast node (xdph), feeding an
// app. Visualisers like cava read the speakers' monitor, not the mic, so
// they don't count.
Singleton {
    id: root

    // tracked so their `properties` get filled in
    PwObjectTracker { objects: Pipewire.nodes.values }

    // level meters that read the mic without recording anything
    readonly property var ignored: ["pavucontrol", "quickshell", "easyeffects"]

    function appName(node): string {
        const p = node?.properties ?? {}
        return p["application.name"] || p["application.process.binary"] || node?.description || node?.name || "unknown"
    }

    // { mic: [app names], camera: [...], screen: [...] }
    readonly property var users: {
        const mic = new Set(), camera = new Set(), screen = new Set()
        for (const group of Pipewire.linkGroups.values) {
            const source = group.source
            const target = group.target
            if (!source || !target) continue
            const app = appName(target)
            if (ignored.includes(app.toLowerCase())) continue
            const kind = source.properties?.["media.class"] ?? ""
            if (kind.startsWith("Audio/Source")) mic.add(app)
            else if (kind.startsWith("Video/Source")) {
                if ((source.name ?? "").startsWith("xdph")) screen.add(app)
                else camera.add(app)
            }
        }
        return { mic: [...mic], camera: [...camera], screen: [...screen] }
    }

    readonly property bool active: users.mic.length + users.camera.length + users.screen.length > 0
}
