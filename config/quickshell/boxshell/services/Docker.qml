pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Docker containers for the bar's docker menu. Refreshes on Docker's own
// container events instead of polling; retries while the daemon is down.
// CPU and memory of running containers are read only while the menu wants
// them (`statsWanted`).
Singleton {
    id: root

    property bool available: false
    // [{ id, name, project, image, state, status, health, port }]
    property var containers: []
    readonly property int running: containers.filter(c => c.state === "running").length

    // [{ name, compose, running, containers }]: compose projects by name,
    // then the rest as "other"; running containers first in each
    readonly property var groups: {
        const byName = {}
        for (const c of containers) {
            const key = c.project || ""
            byName[key] = byName[key] ?? []
            byName[key].push(c)
        }
        const keys = Object.keys(byName).filter(k => k !== "").sort()
        if (byName[""]) keys.push("")
        return keys.map(k => ({
            name: k || "other",
            compose: k !== "",
            project: k,
            running: byName[k].filter(c => c.state === "running").length,
            containers: byName[k],
        }))
    }

    // container id -> "starting" / "stopping" / "restarting" / "removing"
    property var busy: ({})
    // container name -> { cpu, mem } while statsWanted
    property var stats: ({})
    property bool statsWanted: false

    // group name -> true/false once the user has opened or closed it;
    // otherwise a group is open when something in it runs
    property var expanded: ({})
    function isExpanded(group): bool {
        return expanded[group.name] ?? group.running > 0
    }
    function toggle(group) {
        const e = Object.assign({}, expanded)
        e[group.name] = !isExpanded(group)
        expanded = e
    }

    function refresh() {
        if (!list.running) list.running = true
    }

    readonly property var verbs: ({ start: "starting", stop: "stopping", restart: "restarting", rm: "removing" })

    function act(action: string, c) {
        setBusy([c.id], verbs[action])
        run(["docker", action, c.id], [c.id])
    }

    // start / stop a whole compose project
    function actProject(action: string, group) {
        const ids = group.containers.map(c => c.id)
        setBusy(ids, verbs[action])
        run(["docker", "compose", "-p", group.project, action], ids)
    }

    // remove every stopped container of a group
    function removeStopped(group) {
        const ids = group.containers.filter(c => c.state !== "running").map(c => c.id)
        if (ids.length === 0) return
        setBusy(ids, "removing")
        run(["docker", "rm"].concat(ids), ids)
    }

    function logs(c) {
        Quickshell.execDetached(["alacritty", "--title", `${c.name} logs`, "-e",
                                 "docker", "logs", "-f", "--tail", "300", c.id])
    }

    function shell(c) {
        Quickshell.execDetached(["alacritty", "--title", c.name, "-e", "docker", "exec", "-it", c.id,
                                 "sh", "-c", "command -v bash >/dev/null && exec bash || exec sh"])
    }

    function openPort(c) {
        Quickshell.execDetached(["xdg-open", `http://localhost:${c.port}`])
    }

    // "Up 3 hours (healthy)" -> "up 3h", "Exited (137) 5 minutes ago" -> "exited 137 · 5m"
    function shortStatus(c): string {
        const s = c.status
        const units = [["second", "s"], ["minute", "m"], ["hour", "h"], ["day", "d"], ["week", "w"], ["month", "mo"], ["year", "y"]]
        let age = ""
        const m = s.match(/(\d+|an?|About an?) (second|minute|hour|day|week|month|year)/i)
        if (m) {
            const n = /^\d+$/.test(m[1]) ? m[1] : "1"
            age = n + units.find(u => u[0] === m[2].toLowerCase())[1]
        } else if (/less than a second/i.test(s)) {
            age = "0s"
        }
        if (c.state === "running") return age ? `up ${age}` : "up"
        const code = (s.match(/Exited \((\d+)\)/) ?? [])[1]
        if (code !== undefined) {
            const head = code === "0" ? "exited" : `exited ${code}`
            return age ? `${head} · ${age}` : head
        }
        return c.state
    }

    // a set of ids that are now `verb`ing (or done with "")
    function setBusy(ids, verb: string) {
        const b = Object.assign({}, busy)
        for (const id of ids) {
            if (verb) b[id] = verb
            else delete b[id]
        }
        busy = b
    }

    function run(command, ids) {
        actProc.createObject(root, { command: command, ids: ids })
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
                    // "0.0.0.0:8080->80/tcp, :::8080->80/tcp": the first host port
                    const port = ((c.Ports ?? "").match(/:(\d+)->/) ?? [])[1] ?? ""
                    return { id: c.ID, name: c.Names, project: project, image: c.Image,
                             state: c.State, status: c.Status, health: c.HealthStatus ?? "",
                             port: port }
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

    // `docker stats --no-stream` takes about two seconds itself
    Process {
        id: statsProc
        command: ["docker", "stats", "--no-stream", "--format", "{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"]
        stdout: StdioCollector {
            onStreamFinished: {
                const s = {}
                for (const line of text.trim().split("\n")) {
                    const f = line.split("\t")
                    if (f.length < 3) continue
                    // "12.5MiB / 31.2GiB" -> "12M"
                    const mem = f[2].split("/")[0].trim()
                        .replace(/^([\d.]+)\s*([KMGT])i?B$/, (_, n, u) => Math.round(parseFloat(n)) + u)
                    s[f[0]] = { cpu: Math.round(parseFloat(f[1])) + "%", mem: mem }
                }
                root.stats = s
            }
        }
    }

    Timer {
        interval: 3000
        running: root.statsWanted && root.running > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!statsProc.running) statsProc.running = true
    }

    Component {
        id: actProc
        Process {
            property var ids: []
            running: true
            onExited: {
                root.setBusy(ids, "")
                root.refresh()
                destroy()
            }
        }
    }
}
