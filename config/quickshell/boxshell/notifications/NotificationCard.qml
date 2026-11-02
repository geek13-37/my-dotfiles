import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs
import qs.widgets

// One popup. Left click runs the default action, right click dismisses.
// Every notification goes away by itself: the line along the bottom counts
// down (5s, 10s for critical ones, at most 10s whatever the app asks) and
// pauses only while the mouse is moving over it.
// Fades in on creation and out again before closing.
Rectangle {
    id: card
    required property Notification modelData
    readonly property Notification n: modelData
    readonly property bool critical: n?.urgency === NotificationUrgency.Critical
    readonly property var buttons: (n?.actions ?? []).filter(a => a.identifier !== "default")

    width: parent?.width ?? 0
    height: content.implicitHeight + 24
    color: Theme.glass
    // no outline on the glass; a critical one keeps a red edge
    border.color: Theme.error
    border.width: critical ? Theme.border : 0

    // play the exit animation, then run `done` (dismiss, expire, invoke...)
    function close(done) {
        if (leave.running) return
        leave.done = done
        leave.start()
    }

    Component.onCompleted: enter.start()

    NumberAnimation {
        id: enter
        target: card; property: "opacity"; from: 0; to: 1; duration: 120
    }

    NumberAnimation {
        id: leave
        property var done
        target: card; property: "opacity"; to: 0; duration: 120
        onFinished: done()
    }

    function iconSource(): string {
        if (!n) return ""
        if (n.image) return n.image
        const icon = n.appIcon
        if (icon === "") return ""
        if (icon.startsWith("/")) return "file://" + icon
        if (icon.includes("://")) return icon
        return Quickshell.iconPath(icon, true)
    }

    // true while the pointer moves over the card, false a moment after it
    // stops, so a cursor left lying here doesn't hold the card forever
    property bool touched: false
    HoverHandler {
        onPointChanged: {
            card.touched = true
            untouch.restart()
        }
        onHoveredChanged: if (!hovered) card.touched = false
    }
    Timer {
        id: untouch
        interval: 1500
        onTriggered: card.touched = false
    }

    // behind the content so action buttons get their clicks first
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (!card.n) return
            const main = card.n.actions.find(a => a.identifier === "default")
            if (mouse.button === Qt.LeftButton && main) card.close(() => main.invoke())
            else card.close(() => card.n.dismiss())
        }
    }

    Row {
        id: content
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
        spacing: 10

        IconImage {
            id: icon
            source: card.iconSource()
            visible: source != ""
            implicitSize: 32
        }

        Column {
            width: content.width - (icon.visible ? icon.width + content.spacing : 0)
            spacing: 4

            Label {
                width: parent.width
                text: card.n?.appName ?? ""
                color: Theme.dim
                font.pixelSize: Theme.fontSize - 1
                elide: Text.ElideRight
            }
            Label {
                width: parent.width
                text: card.n?.summary ?? ""
                font.bold: true
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
            Label {
                width: parent.width
                visible: text !== ""
                text: card.n?.body ?? ""
                textFormat: Text.StyledText
                wrapMode: Text.Wrap
                maximumLineCount: 4
                elide: Text.ElideRight
            }

            Row {
                visible: card.buttons.length > 0
                topPadding: 4
                spacing: 6

                Repeater {
                    model: card.buttons

                    MouseArea {
                        id: action
                        required property NotificationAction modelData
                        implicitWidth: actionLabel.implicitWidth + 20
                        implicitHeight: 24
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: card.close(() => modelData.invoke())

                        Rectangle {
                            anchors.fill: parent
                            color: action.containsMouse ? Qt.tint(Theme.surface, Theme.hover) : Theme.surface
                        }
                        Label {
                            id: actionLabel
                            anchors.centerIn: parent
                            text: action.modelData.text
                            color: Theme.fg
                        }
                    }
                }
            }
        }
    }

    // countdown line
    Rectangle {
        anchors { left: parent.left; bottom: parent.bottom; margins: card.border.width }
        height: 2
        color: card.critical ? Theme.error : Theme.accent

        NumberAnimation on width {
            from: card.width - 2 * card.border.width
            to: 0
            // expireTimeout is in seconds; -1 "server decides", 0 "never"
            duration: card.critical ? 10000
                    : Math.min(10000, (card.n?.expireTimeout ?? -1) > 0 ? card.n.expireTimeout * 1000 : 5000)
            running: true
            paused: card.touched
            onFinished: card.close(() => card.n?.expire())
        }
    }
}
