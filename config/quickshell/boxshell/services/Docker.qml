pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Docker containers for the bar's docker menu. Refreshes on Docker's own
// container events instead of polling; retries while the daemon is down.
Singleton {
    id: root

    property bool available: false
    // [{ id, name, project, image, state, status, health }], running first
    property var containers: []
    readonly property int running: containers.filter(c => c.state === "running").length
    // container ids with a start/stop/restart in flight
    property var busy: ({})

    function refresh() {
        if (!list.running) list.running = true
    }

    function act(action: string, id: string) {
        const b = Object.assign({}, busy)
        b[id] = true
        busy = b
        actProc.createObject(root, { command: ["docker", action, id], containerId: id })
    }

    Component.onCompleted: refresh()

    Process {
        id: list
        command: ["docker", "ps", "-a", "--format", "{{json .}}"]
        stdout: StdioCollector {
            onStreamFinished: {
                const rows = text.trim().split("\n").filter(l => l !== "").map(l => {
                    const c = JSON.parse(l)
                    const labels = c.Labels ?? ""
                    const project = (labels.match(/com\.docker\.compose\.project=([^,]+)/) ?? [])[1] ?? ""
                    return { id: c.ID, name: c.Names, project: project, image: c.Image,
                             state: c.State, status: c.Status, health: c.HealthStatus ?? "" }
                })
                rows.sort((a, b) => (b.state === "running") - (a.state === "running")
                                    || a.name.localeCompare(b.name))
                root.containers = rows
            }
        }
        onExited: code => {
            root.available = code === 0
            // daemon down or starting: try again later
            if (code !== 0) retry.restart()
            else if (!events.running) events.running = true
        }
    }

    Timer {
        id: retry
        interval: 30000
        onTriggered: root.refresh()
    }

    // one line per container event (start, die, create, destroy, health...)
    Process {
        id: events
        command: ["docker", "events", "--filter", "type=container", "--format", "{{.Action}}"]
        stdout: SplitParser {
            onRead: debounce.restart()
        }
        // the daemon went away; the next refresh restarts this
        onExited: retry.restart()
    }

    // a restart fires several events in a row; list once
    Timer {
        id: debounce
        interval: 300
        onTriggered: root.refresh()
    }

    Component {
        id: actProc
        Process {
            property string containerId
            running: true
            onExited: {
                const b = Object.assign({}, root.busy)
                delete b[containerId]
                root.busy = b
                root.refresh()
                destroy()
            }
        }
    }
}
