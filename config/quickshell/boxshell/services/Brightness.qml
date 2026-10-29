pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Screen backlight, i.e. laptops; `available` is false on a desktop and the
// bar and OSD leave it out. The brightness keys run brightnessctl directly;
// sysfs has no change events, so the level is polled to catch that.
Singleton {
    id: root

    property string device: ""
    readonly property bool available: device !== ""
    property real max: 1
    readonly property real value: available ? (parseInt(current.text()) || 0) / max : 0

    function set(v: real) {
        if (!available) return
        // never all the way to black
        const percent = Math.round(Math.max(0.01, Math.min(1, v)) * 100)
        Quickshell.execDetached(["brightnessctl", "-q", "-d", device, "set", `${percent}%`])
    }

    // "intel_backlight,backlight,512,50%,1024"; fails without a backlight
    Process {
        running: true
        command: ["brightnessctl", "-m", "-c", "backlight", "info"]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split(",")
                if (fields.length < 5) return
                root.max = parseInt(fields[4]) || 1
                root.device = fields[0]
            }
        }
    }

    FileView {
        id: current
        path: root.available ? `/sys/class/backlight/${root.device}/brightness` : ""
    }

    Timer {
        interval: 250
        running: root.available
        repeat: true
        onTriggered: current.reload()
    }
}
