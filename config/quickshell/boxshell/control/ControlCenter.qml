pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Open state of the control center (sound output/input), shared by the bar
// button on every monitor. Also: qs -c boxshell ipc call control toggle
Singleton {
    id: root

    property bool open: false

    function toggle() {
        open = !open
    }

    IpcHandler {
        target: "control"
        function toggle(): void { root.toggle() }
    }
}
