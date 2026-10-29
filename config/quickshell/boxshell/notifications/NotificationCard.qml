import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs
import qs.widgets

// One popup. Left click runs the default action, right click dismisses.
// The line along the bottom counts down to expiry and pauses on hover.
// Slides in from the right on creation and out again before closing.
Rectangle {
    id: card
    required property Notification modelData
    readonly property Notification n: modelData
    readonly property bool critical: n?.urgency === NotificationUrgency.Critical
    readonly property var buttons: (n?.actions ?? []).filter(a => a.identifier !== "default")

    width: parent?.width ?? 0
    height: content.implicitHeight + 24
    color: Theme.glass
    border.color: critical ? Theme.error : Theme.surface
    border.width: Theme.border

    // play the exit animation, then run `done` (dismiss, expire, invoke...)
    function close(done) {
        if (leave.running) return
        leave.done = done
        leave.start()
    }

    Component.onCompleted: enter.start()

    ParallelAnimation {
        id: enter
        NumberAnimation { target: card; property: "x"; from: 380; to: 0; duration: 320; easing.type: Easing.OutBack }
        NumberAnimation { target: card; property: "opacity"; from: 0; to: 1; duration: 200 }
    }

    ParallelAnimation {
        id: leave
        property var done
        NumberAnimation { target: card; property: "x"; to: 380; duration: 220; easing.type: Easing.InCubic }
        NumberAnimation { target: card; property: "opacity"; to: 0; duration: 220 }
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

    HoverHandler { id: hover }

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
                            color: action.containsMouse ? Theme.accent : Theme.surface
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }
                        Label {
                            id: actionLabel
                            anchors.centerIn: parent
                            text: action.modelData.text
                            color: action.containsMouse ? Theme.accentText : Theme.fg
                        }
                    }
                }
            }
        }
    }

    // countdown line; critical notifications stay until dismissed
    Rectangle {
        anchors { left: parent.left; bottom: parent.bottom; margins: Theme.border }
        height: 2
        visible: !card.critical
        color: Theme.accent

        NumberAnimation on width {
            from: card.width - 2 * Theme.border
            to: 0
            // expireTimeout is in seconds, -1 means "server decides"
            duration: (card.n?.expireTimeout ?? -1) > 0 ? card.n.expireTimeout * 1000 : 5000
            running: !card.critical
            paused: running && hover.hovered
            onFinished: card.close(() => card.n?.expire())
        }
    }
}
