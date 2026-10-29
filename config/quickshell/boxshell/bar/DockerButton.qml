import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services
import qs.widgets

// Docker containers, like Noctalia's mini-docker: the bar shows how many run,
// the menu starts, stops and restarts them.
MouseArea {
    id: root
    required property var bar
    property bool open: false

    implicitWidth: row.implicitWidth + Theme.itemPadding * 2
    implicitHeight: Theme.itemHeight
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: {
        drawer.anchorX = Theme.gapSide + mapToItem(null, width, 0).x + drawer.padding
        open = !open
        if (open) Docker.refresh()
    }

    readonly property color tint: !Docker.available ? Theme.dim
                                : containsMouse || open ? Theme.accent : Theme.fg

    HoverBox { active: root.containsMouse || root.open }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 3
        // the whale; Material Symbols has none, the Nerd Font does
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "\uf308"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Theme.iconSize
            color: root.tint
        }
        Label {
            anchors.verticalCenter: parent.verticalCenter
            visible: Docker.running > 0
            text: Docker.running
            color: root.tint
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

        Label {
            leftPadding: 6
            topPadding: 4
            bottomPadding: 4
            font.bold: true
            text: !Docker.available ? "docker isn't running"
                : `containers  ·  ${Docker.running} running`
        }

        Flickable {
            width: parent.width
            height: Math.min(contentHeight, 420)
            contentHeight: list.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: list
                width: parent.width
                spacing: 2

                Repeater {
                    model: Docker.containers

                    Rectangle {
                        id: entry
                        required property var modelData
                        readonly property bool running: modelData.state === "running"
                        readonly property bool busy: Docker.busy[modelData.id] === true

                        width: list.width
                        height: 44
                        color: hover.hovered ? Theme.surface : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }
                        HoverHandler { id: hover }

                        // pulse while docker is working on it
                        SequentialAnimation on opacity {
                            running: entry.busy
                            loops: Animation.Infinite
                            onRunningChanged: if (!running) entry.opacity = 1
                            NumberAnimation { to: 0.4; duration: 400 }
                            NumberAnimation { to: 1; duration: 400 }
                        }

                        Rectangle {
                            id: dot
                            anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                            width: 8
                            height: 8
                            color: entry.modelData.health === "unhealthy" ? Theme.error
                                 : entry.running ? Theme.accent : Theme.dim
                        }

                        Column {
                            anchors { left: dot.right; leftMargin: 10; right: buttons.left; rightMargin: 8
                                      verticalCenter: parent.verticalCenter }
                            spacing: 2
                            Label {
                                width: parent.width
                                elide: Text.ElideRight
                                text: entry.modelData.project !== ""
                                      ? `${entry.modelData.name}  ·  ${entry.modelData.project}`
                                      : entry.modelData.name
                            }
                            Label {
                                width: parent.width
                                elide: Text.ElideRight
                                font.pixelSize: Theme.fontSize - 2
                                color: Theme.dim
                                text: entry.modelData.status
                            }
                        }

                        Row {
                            id: buttons
                            anchors { right: parent.right; rightMargin: 4; verticalCenter: parent.verticalCenter }
                            spacing: 2

                            Repeater {
                                model: [
                                    entry.running ? { icon: "stop", action: "stop" } : { icon: "play_arrow", action: "start" },
                                    { icon: "restart_alt", action: "restart" },
                                ]

                                MouseArea {
                                    id: button
                                    required property var modelData
                                    width: 28
                                    height: 28
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    enabled: !entry.busy
                                    onClicked: Docker.act(modelData.action, entry.modelData.id)

                                    Rectangle {
                                        anchors.fill: parent
                                        color: button.containsMouse ? Theme.accent : "transparent"
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }
                                    Icon {
                                        anchors.centerIn: parent
                                        text: button.modelData.icon
                                        color: button.containsMouse ? Theme.accentText : Theme.fg
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
