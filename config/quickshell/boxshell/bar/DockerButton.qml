import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services
import qs.widgets

// Docker containers: the bar shows the whale and how many run. The menu
// groups them by compose project (the rest under "other"); a group with
// nothing running starts folded. A row is one line, name and a short status;
// hovering swaps the status for its buttons.
MouseArea {
    id: root
    required property var bar
    property bool open: false

    // a square while it's just the whale
    implicitWidth: Docker.running > 0 ? row.implicitWidth + Theme.itemPadding * 2 : Theme.itemHeight
    implicitHeight: Theme.itemHeight
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: {
        drawer.anchorX = Theme.gapSide + mapToItem(null, width, 0).x
        open = !open
        if (open) Docker.refresh()
    }

    Binding { target: Docker; property: "statsWanted"; value: root.open }

    readonly property color tint: !Docker.available ? Theme.dim
                                : containsMouse || open ? Theme.accent : Theme.fg

    HoverBox { active: root.containsMouse || root.open }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 3
        // the whale; Material Symbols has none, the Nerd Font does. Its glyph
        // box doesn't match the drawing, so centre the drawing itself.
        Item {
            width: Theme.iconSize
            height: Theme.itemHeight

            TextMetrics {
                id: ink
                font: whale.font
                text: whale.text
            }

            Text {
                id: whale
                text: ""
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Theme.iconSize
                renderType: Text.NativeRendering
                color: root.tint
                // tightBoundingRect is relative to the pen position on the baseline
                x: Math.floor((parent.width - ink.tightBoundingRect.width) / 2 - ink.tightBoundingRect.x)
                y: Math.round((parent.height - ink.tightBoundingRect.height) / 2 - ink.tightBoundingRect.y - baselineOffset)
            }
        }
        Label {
            height: Theme.itemHeight
            visible: Docker.running > 0
            text: Docker.running
            color: root.tint
        }
    }

    // a square icon button for rows and group headers; `danger` asks for a
    // second click and goes red in between
    component RowButton: MouseArea {
        id: button
        property string icon
        property bool danger: false
        property bool armed: false
        signal activated()

        width: Theme.itemHeight
        height: Theme.itemHeight
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (danger && !armed) { armed = true; return }
            armed = false
            activated()
        }
        onContainsMouseChanged: if (!containsMouse) armed = false

        Rectangle {
            anchors.fill: parent
            color: button.armed ? Theme.error : button.containsMouse ? Theme.hover : "transparent"
        }
        Icon {
            anchors.centerIn: parent
            text: button.icon
            color: button.armed ? Theme.errorText : Theme.fg
        }
    }

    Dropdown {
        id: drawer
        screen: root.bar.screen
        WlrLayershell.namespace: "boxshell-tray"
        open: root.open
        onCloseRequested: root.open = false
        alignRight: true
        boxWidth: 380

        MenuHeader {
            icon: "deployed_code"
            title: "Docker"
            Label {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                color: Theme.dim
                text: !Docker.available ? "not running"
                    : Docker.containers.length === 0 ? "no containers"
                    : `${Docker.running} of ${Docker.containers.length} running`
            }
        }

        Flickable {
            width: parent.width
            height: Math.min(contentHeight, 480)
            contentHeight: list.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: list
                width: parent.width
                spacing: 2

                Repeater {
                    model: Docker.groups

                    Column {
                        id: group
                        required property var modelData
                        readonly property bool expanded: Docker.isExpanded(modelData)
                        readonly property int stopped: modelData.containers.length - modelData.running
                        width: list.width
                        spacing: 2

                        // group header: click to fold
                        MouseArea {
                            id: header
                            width: parent.width
                            height: 32
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Docker.toggle(group.modelData)

                            Rectangle {
                                anchors.fill: parent
                                color: header.containsMouse ? Theme.hover : "transparent"
                            }

                            Icon {
                                id: chevron
                                anchors { left: parent.left; leftMargin: Theme.menuInset - 4; verticalCenter: parent.verticalCenter }
                                text: group.expanded ? "keyboard_arrow_down" : "chevron_right"
                                color: Theme.dim
                            }
                            Label {
                                anchors { left: chevron.right; leftMargin: 4; right: headerSide.left; rightMargin: 8
                                          verticalCenter: parent.verticalCenter }
                                elide: Text.ElideRight
                                text: group.modelData.name
                                font.bold: true
                                color: group.modelData.compose ? Theme.fg : Theme.dim
                            }

                            Item {
                                id: headerSide
                                anchors { right: parent.right; rightMargin: 3; verticalCenter: parent.verticalCenter }
                                width: header.containsMouse && headerButtons.width > 0 ? headerButtons.width : count.width + Theme.menuInset - 3
                                height: Theme.itemHeight

                                Label {
                                    id: count
                                    anchors { right: parent.right; rightMargin: Theme.menuInset - 3; verticalCenter: parent.verticalCenter }
                                    visible: !(header.containsMouse && headerButtons.width > 0)
                                    color: Theme.dim
                                    text: `${group.modelData.running}/${group.modelData.containers.length}`
                                }

                                Row {
                                    id: headerButtons
                                    anchors.right: parent.right
                                    visible: header.containsMouse
                                    spacing: 2

                                    RowButton {
                                        visible: group.modelData.compose && group.stopped > 0
                                        icon: "play_arrow"
                                        onActivated: Docker.actProject("start", group.modelData)
                                    }
                                    RowButton {
                                        visible: group.modelData.compose && group.modelData.running > 0
                                        icon: "stop"
                                        onActivated: Docker.actProject("stop", group.modelData)
                                    }
                                    RowButton {
                                        visible: !group.modelData.compose && group.stopped > 0
                                        icon: "delete_sweep"
                                        danger: true
                                        onActivated: Docker.removeStopped(group.modelData)
                                    }
                                }
                            }
                        }

                        Repeater {
                            model: group.expanded ? group.modelData.containers : []

                            MouseArea {
                                id: entry
                                required property var modelData
                                readonly property bool running: modelData.state === "running"
                                readonly property string busy: Docker.busy[modelData.id] ?? ""
                                readonly property var stat: Docker.stats[modelData.name]

                                width: list.width
                                height: 32
                                hoverEnabled: true

                                Rectangle {
                                    anchors.fill: parent
                                    color: entry.containsMouse ? Theme.hover : "transparent"
                                }

                                Rectangle {
                                    id: dot
                                    anchors { left: parent.left; leftMargin: Theme.menuInset + 18 + 4 + 4; verticalCenter: parent.verticalCenter }
                                    width: 6
                                    height: 6
                                    color: entry.modelData.health === "unhealthy" ? Theme.error
                                         : entry.running ? Theme.accent : Theme.dim
                                }

                                Label {
                                    anchors { left: dot.right; leftMargin: 10; right: side.left; rightMargin: 8
                                              verticalCenter: parent.verticalCenter }
                                    elide: Text.ElideRight
                                    text: entry.modelData.name
                                    color: entry.running ? Theme.fg : Theme.dim
                                }

                                Item {
                                    id: side
                                    readonly property bool showButtons: entry.containsMouse && entry.busy === ""
                                    anchors { right: parent.right; rightMargin: 3; verticalCenter: parent.verticalCenter }
                                    width: showButtons ? buttons.width : status.width + Theme.menuInset - 3
                                    height: Theme.itemHeight

                                    Label {
                                        id: status
                                        anchors { right: parent.right; rightMargin: Theme.menuInset - 3; verticalCenter: parent.verticalCenter }
                                        visible: !side.showButtons
                                        color: entry.busy !== "" ? Theme.fg
                                             : entry.modelData.health === "unhealthy" ? Theme.error : Theme.dim
                                        font.pixelSize: Theme.fontSize - 1
                                        text: entry.busy !== "" ? `${entry.busy}…`
                                            : entry.modelData.health === "unhealthy" ? "unhealthy"
                                            : entry.running && entry.stat ? `${entry.stat.cpu}  ${entry.stat.mem}`
                                            : Docker.shortStatus(entry.modelData)
                                    }

                                    Row {
                                        id: buttons
                                        anchors.right: parent.right
                                        visible: side.showButtons
                                        spacing: 2

                                        RowButton {
                                            visible: entry.running && entry.modelData.port !== ""
                                            icon: "open_in_new"
                                            onActivated: { Docker.openPort(entry.modelData); root.open = false }
                                        }
                                        RowButton {
                                            icon: "article"
                                            onActivated: { Docker.logs(entry.modelData); root.open = false }
                                        }
                                        RowButton {
                                            visible: entry.running
                                            icon: "terminal"
                                            onActivated: { Docker.shell(entry.modelData); root.open = false }
                                        }
                                        RowButton {
                                            visible: entry.running
                                            icon: "restart_alt"
                                            onActivated: Docker.act("restart", entry.modelData)
                                        }
                                        RowButton {
                                            icon: entry.running ? "stop" : "play_arrow"
                                            onActivated: Docker.act(entry.running ? "stop" : "start", entry.modelData)
                                        }
                                        RowButton {
                                            visible: !entry.running
                                            icon: "delete"
                                            danger: true
                                            onActivated: Docker.act("rm", entry.modelData)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
