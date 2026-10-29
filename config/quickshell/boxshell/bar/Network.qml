import QtQuick
import Quickshell.Io
import qs
import qs.widgets

// Polls nmcli: lan icon for ethernet, wifi icon + network name, or offline.
Row {
    id: root
    property string type: ""      // "wifi", "ethernet" or "" when offline
    property string connection: ""
    spacing: 4
    leftPadding: Theme.itemPadding
    rightPadding: Theme.itemPadding

    Icon {

        anchors.verticalCenter: parent.verticalCenter
        text: root.type === "wifi" ? "wifi" : root.type === "ethernet" ? "lan" : "wifi_off"
        color: root.type === "" ? Theme.dim : Theme.fg
    }
    Label {
        color: Theme.fg
        anchors.verticalCenter: parent.verticalCenter
        visible: root.type === "wifi"
        text: root.connection
    }

    Process {
        id: nmcli
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device"]
        stdout: StdioCollector {
            onStreamFinished: {
                const up = text.split("\n")
                    .map(l => l.split(":"))
                    .find(f => f[1] === "connected" && (f[0] === "wifi" || f[0] === "ethernet"))
                root.type = up ? up[0] : ""
                root.connection = up ? up[2] : ""
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: nmcli.running = true
    }
}
