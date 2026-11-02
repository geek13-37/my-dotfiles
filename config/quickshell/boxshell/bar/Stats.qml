import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs
import qs.services
import qs.widgets

// Used RAM and CPU load. Click: an Activity Monitor style menu with the last
// minute of both as segment graphs, the details and the busiest processes.
MouseArea {
    id: root
    required property var bar
    property bool open: false

    implicitWidth: row.implicitWidth + Theme.itemPadding * 2
    implicitHeight: Theme.itemHeight
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: {
        drawer.anchorX = Theme.gapSide + mapToItem(null, 0, 0).x
        open = !open
    }

    // processes are only listed while the menu is open
    Binding { target: SysStats; property: "watchProcesses"; value: root.open }

    HoverBox { active: root.containsMouse || root.open }

    readonly property color ramColor: Theme.level(SysStats.ramTotal > 0 ? SysStats.ramUsed / SysStats.ramTotal : 0)
    readonly property color cpuColor: Theme.level(SysStats.cpu)

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 4

        Icon { height: Theme.itemHeight; text: "memory"; color: root.ramColor }
        Label {
            height: Theme.itemHeight
            text: `${SysStats.ramUsed.toFixed(1)} GiB`
            color: root.ramColor
        }

        Item { width: 8; height: 1 }

        Icon { height: Theme.itemHeight; text: "speed"; color: root.cpuColor }
        // no reserved width: the padding stays even on both sides (the hover
        // square follows the width when the digits change)
        TickingLabel {
            height: Theme.itemHeight
            value: SysStats.cpu
            color: root.cpuColor
        }
    }

    function gib(v: real): string {
        return `${v.toFixed(1)} GiB`
    }

    function duration(seconds: real): string {
        const d = Math.floor(seconds / 86400)
        const h = Math.floor(seconds % 86400 / 3600)
        const m = Math.floor(seconds % 3600 / 60)
        return d > 0 ? `${d}d ${h}h` : h > 0 ? `${h}h ${m}m` : `${m}m`
    }

    Dropdown {
        id: drawer
        screen: root.bar.screen
        WlrLayershell.namespace: "boxshell-tray"
        open: root.open
        onCloseRequested: root.open = false
        boxWidth: 400
        spacing: 6

        // ─── CPU ───
        MenuHeader {
            icon: "speed"
            title: "CPU"
            TickingLabel {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                value: SysStats.cpu
                color: SysStats.cpu > 0.85 ? Theme.error : Theme.accent
                font.bold: true
            }
        }
        SegmentGraph {
            x: Theme.menuInset
            width: parent.width - 2 * Theme.menuInset
            height: 48
            values: SysStats.cpuHistory
        }
        Note {
            text: `load ${SysStats.load.map(v => v.toFixed(2)).join("  ")}  ·  ${SysStats.cores} threads  ·  up ${root.duration(SysStats.uptime)}`
        }

        Item { width: 1; height: 6 }

        // ─── Memory ───
        MenuHeader {
            icon: "memory"
            title: "Memory"
            Label {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                text: `${root.gib(SysStats.ramUsed)} / ${root.gib(SysStats.ramTotal)}`
                color: Theme.accent
                font.bold: true
            }
        }
        SegmentGraph {
            x: Theme.menuInset
            width: parent.width - 2 * Theme.menuInset
            height: 48
            values: SysStats.ramHistory
        }
        Note {
            text: `cached ${root.gib(SysStats.ramCached)}`
                  + (SysStats.swapTotal > 0 ? `  ·  swap ${root.gib(SysStats.swapUsed)} / ${root.gib(SysStats.swapTotal)}` : "")
        }

        Item { width: 1; height: 6 }

        // ─── Processes ───
        MenuHeader {
            icon: "apps"
            title: "Processes"
            // column titles over the numbers below
            Label {
                anchors { right: parent.right; rightMargin: root.memWidth + root.columnGap; verticalCenter: parent.verticalCenter }
                width: root.cpuWidth
                horizontalAlignment: Text.AlignRight
                text: "cpu"
                color: Theme.dim
                font.pixelSize: Theme.fontSize - 1
            }
            Label {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                width: root.memWidth
                horizontalAlignment: Text.AlignRight
                text: "memory"
                color: Theme.dim
                font.pixelSize: Theme.fontSize - 1
            }
        }

        Repeater {
            model: SysStats.processes

            Item {
                required property var modelData
                x: Theme.menuInset
                width: parent.width - 2 * Theme.menuInset
                height: 22

                // the app's own icon when there's a desktop entry for it
                readonly property string appIcon: {
                    const entry = DesktopEntries.heuristicLookup(modelData.name)
                    return entry?.icon ? Quickshell.iconPath(entry.icon, true) : Quickshell.iconPath(modelData.name.toLowerCase(), true)
                }

                Item {
                    id: appIcon
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.iconSize
                    height: Theme.iconSize

                    IconImage {
                        anchors.fill: parent
                        visible: parent.parent.appIcon !== ""
                        source: parent.parent.appIcon
                    }
                    Icon {
                        anchors.centerIn: parent
                        visible: parent.parent.appIcon === ""
                        text: "terminal"
                        color: Theme.dim
                    }
                }
                Label {
                    anchors { left: appIcon.right; leftMargin: 8; right: cpu.left; rightMargin: root.columnGap
                              verticalCenter: parent.verticalCenter }
                    elide: Text.ElideRight
                    text: modelData.name
                }
                Label {
                    id: cpu
                    anchors { right: mem.left; rightMargin: root.columnGap; verticalCenter: parent.verticalCenter }
                    width: root.cpuWidth
                    horizontalAlignment: Text.AlignRight
                    text: `${modelData.cpu.toFixed(1)}%`
                    color: modelData.cpu > 50 ? Theme.error : Theme.fg
                }
                Label {
                    id: mem
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    width: root.memWidth
                    horizontalAlignment: Text.AlignRight
                    text: root.gib(modelData.mem)
                    color: Theme.dim
                }
            }
        }
    }

    // process table columns
    readonly property int cpuWidth: 56
    readonly property int memWidth: 72
    readonly property int columnGap: 12

    // small dim line under a graph
    component Note: Label {
        leftPadding: Theme.menuInset
        color: Theme.dim
        font.pixelSize: Theme.fontSize - 1
    }
}
