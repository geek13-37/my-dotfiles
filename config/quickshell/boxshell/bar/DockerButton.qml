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

    // a square while it's just the whale
    implicitWidth: Docker.running > 0 ? row.implicitWidth + Theme.itemPadding * 2 : Theme.itemHeight
    // the count appearing or going doesn't make the neighbours jump
    Behavior on implicitWidth { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    clip: true
    implicitHeight: Theme.itemHeight
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: {
        drawer.anchorX = Theme.gapSide + mapToItem(null, width, 0).x
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
                text: "\uf308"
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
            title: !Docker.available ? "docker isn't running"
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
                        color: hover.hovered ? Theme.accent : Theme.clear(Theme.accent)
                        // what goes on top of the row's colour
                        readonly property color ink: hover.hovered ? Theme.accentText : Theme.fg
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
                            anchors { left: parent.left; leftMargin: Theme.menuInset; verticalCenter: parent.verticalCenter }
                            width: 8
                            height: 8
                            color: entry.modelData.health === "unhealthy" ? Theme.error
                                 : hover.hovered ? entry.ink
                                 : entry.running ? Theme.accent : Theme.dim
                        }

                        Column {
                            anchors { left: dot.right; leftMargin: 10; right: buttons.left; rightMargin: 8
                                      verticalCenter: parent.verticalCenter }
                            spacing: 2
                            Label {
                                width: parent.width
                                elide: Text.ElideRight
                                color: entry.ink
                                text: entry.modelData.project !== ""
                                      ? `${entry.modelData.name}  ·  ${entry.modelData.project}`
                                      : entry.modelData.name
                            }
                            Label {
                                width: parent.width
                                elide: Text.ElideRight
                                font.pixelSize: Theme.fontSize - 2
                                color: hover.hovered ? entry.ink : Theme.dim
                                opacity: hover.hovered ? 0.75 : 1
                                text: entry.modelData.status
                            }
                        }

                        Row {
                            id: buttons
                            anchors { right: parent.right; rightMargin: Theme.menuInset - 5; verticalCenter: parent.verticalCenter }
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
                                        color: button.containsMouse ? entry.ink : Theme.clear(entry.ink)
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }
                                    Icon {
                                        anchors.centerIn: parent
                                        text: button.modelData.icon
                                        color: button.containsMouse ? Theme.accent : entry.ink
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
