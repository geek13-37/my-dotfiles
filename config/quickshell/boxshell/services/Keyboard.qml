pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// Keyboard layouts of the main keyboard and Caps Lock.
//
// Hyprland sends `activelayout>>keyboard,name` on every switch (Alt+Shift);
// the name is taken from it right away, the layout list and index are read
// from `hyprctl devices` after. Caps Lock has no Hyprland event, so the
// keyboards' capslock LEDs in sysfs are polled.
Singleton {
    id: root

    // short codes, e.g. ["US", "RU"]
    property list<string> layouts: []
    property int activeIndex: -1
    // e.g. "English (US)"
    property string activeName: ""
    property bool capsLock: false

    // sent on changes after startup, not for the first read
    signal switched()
    signal capsToggled()

    // a switch that came in while hyprctl was still running
    property bool pending: false

    function refresh() {
        if (devices.running) pending = true
        else devices.running = true
    }

    Process {
        id: devices
        running: true
        command: ["hyprctl", "devices", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                let keyboards = []
                try { keyboards = JSON.parse(text).keyboards ?? [] } catch (e) { return }
                const kb = keyboards.find(k => k.main) ?? keyboards[0]
                if (!kb) return
                root.layouts = kb.layout.split(",").map(l => l.trim().toUpperCase())
                root.activeName = kb.active_keymap
                root.activeIndex = kb.active_layout_index
            }
        }
        // starting it again from inside its own exit handler does nothing
        onExited: if (root.pending) {
            root.pending = false
            Qt.callLater(() => devices.running = true)
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name !== "activelayout") return
            const name = event.data.slice(event.data.indexOf(",") + 1)
            if (name === root.activeName) return
            root.activeName = name
            root.switched()
            root.refresh()
        }
    }

    // input7::capslock, input13::capslock... one per keyboard
    property list<string> capsLeds: []

    Process {
        running: true
        command: ["sh", "-c", "ls -d /sys/class/leds/*::capslock"]
        stdout: StdioCollector {
            onStreamFinished: root.capsLeds = text.trim().split("\n").filter(l => l !== "")
        }
    }

    Variants {
        id: leds
        model: root.capsLeds
        FileView {
            required property string modelData
            path: `${modelData}/brightness`
            // reload() then text() in one go: wait for the read
            blockAllReads: true
        }
    }

    // the first read only sets capsLock, without popping up the OSD.
    // Reading two sysfs files this often costs next to nothing and keeps
    // the popup in step with the key.
    property bool capsKnown: false

    Timer {
        interval: 30
        running: root.capsLeds.length > 0
        repeat: true
        onTriggered: {
            let on = false
            for (const led of leds.instances) {
                led.reload()
                if (parseInt(led.text()) > 0) on = true
            }
            if (!root.capsKnown) {
                root.capsLock = on
                root.capsKnown = true
                return
            }
            if (on === root.capsLock) return
            root.capsLock = on
            root.capsToggled()
        }
    }

    // switch to the next layout (bar click)
    function next() {
        Quickshell.execDetached(["hyprctl", "switchxkblayout", "current", "next"])
    }
}
