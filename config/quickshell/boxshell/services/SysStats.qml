pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// CPU and memory from /proc every second, with the last minute kept for the
// graphs, plus the busiest processes while someone is looking at them.
Singleton {
    id: root

    // 0..1 over the last second
    property real cpu: 0
    // GiB; used = total minus what the kernel says is available
    property real ramUsed: 0
    property real ramTotal: 0
    property real ramCached: 0
    property real swapUsed: 0
    property real swapTotal: 0
    property int cores: 0
    property var load: [0, 0, 0]
    property real uptime: 0

    // last minute, oldest first, 0..1
    readonly property int historyLength: 60
    property var cpuHistory: []
    property var ramHistory: []

    // [{ name, cpu (percent), mem (GiB) }], busiest first; only refreshed
    // while `watchProcesses` is on (the stats menu is open)
    property bool watchProcesses: false
    property var processes: []

    property var lastCpu: null

    function push(list, value) {
        return list.concat([value]).slice(-historyLength)
    }

    FileView { id: stat; path: "/proc/stat" }
    FileView { id: meminfo; path: "/proc/meminfo" }
    FileView { id: loadavg; path: "/proc/loadavg" }
    FileView { id: uptimeFile; path: "/proc/uptime" }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            stat.reload()
            meminfo.reload()
            loadavg.reload()
            uptimeFile.reload()

            // "cpu  user nice system idle iowait irq softirq steal ..."
            const lines = stat.text().split("\n")
            const f = lines[0].trim().split(/\s+/).slice(1).map(Number)
            // not read yet on the very first tick
            if (f.length < 5 || f.some(isNaN)) return
            root.cores = lines.filter(l => /^cpu\d/.test(l)).length
            const idle = f[3] + f[4]
            const total = f.reduce((a, b) => a + b, 0)
            if (root.lastCpu) {
                const dt = total - root.lastCpu.total
                if (dt > 0) root.cpu = 1 - (idle - root.lastCpu.idle) / dt
                root.cpuHistory = root.push(root.cpuHistory, root.cpu)
            }
            root.lastCpu = { idle: idle, total: total }

            const kb = key => Number((meminfo.text().match(new RegExp(`^${key}:\\s+(\\d+)`, "m")) ?? [0, 0])[1])
            const gib = 1024 * 1024
            root.ramTotal = kb("MemTotal") / gib
            root.ramUsed = (kb("MemTotal") - kb("MemAvailable")) / gib
            root.ramCached = (kb("Cached") + kb("Buffers")) / gib
            root.swapTotal = kb("SwapTotal") / gib
            root.swapUsed = (kb("SwapTotal") - kb("SwapFree")) / gib
            if (root.ramTotal > 0) root.ramHistory = root.push(root.ramHistory, root.ramUsed / root.ramTotal)

            root.load = loadavg.text().trim().split(/\s+/).slice(0, 3).map(Number)
            root.uptime = Number(uptimeFile.text().split(" ")[0]) || 0
        }
    }

    // top's second frame: CPU use right now, not averaged over the process's
    // lifetime like ps
    Process {
        id: top
        command: ["top", "-b", "-n", "2", "-d", "0.5", "-o", "%CPU", "-w", "200"]
        stdout: StdioCollector {
            onStreamFinished: {
                const frames = text.split(/\n\s*PID\s+USER/)
                const rows = (frames[frames.length - 1] ?? "").split("\n").slice(1)
                root.processes = rows.map(l => l.trim().split(/\s+/))
                    .filter(c => c.length >= 12)
                    // PID USER PR NI VIRT RES SHR S %CPU %MEM TIME+ COMMAND
                    .map(c => ({ name: c.slice(11).join(" "), cpu: Number(c[8]), mem: Number(c[9]) / 100 * root.ramTotal }))
                    // that's us asking
                    .filter(p => p.name !== "top")
                    .slice(0, 6)
            }
        }
    }

    Timer {
        interval: 2500
        running: root.watchProcesses
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!top.running) top.running = true
    }
}
