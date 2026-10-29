pragma Singleton
import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.services
import qs.widgets

// Wallpaper carousel: a strip of cards across the middle of the screen.
// Left/Right (or h/l), the wheel anywhere or a click scroll it; Enter or a
// click on the middle card applies; Esc or a click outside closes. Under the
// middle card: a mock bar and swatches in the colours that wallpaper gives.
// Also: qs -c boxshell ipc call wallpapers toggle
Singleton {
    id: root

    property bool open: false

    function toggle() {
        open = !open
    }

    function apply(path: string) {
        Scheme.setWallpaper(path)
        open = false
    }

    function step(delta: real) {
        if (delta < 0) strip.incrementCurrentIndex()
        else if (delta > 0) strip.decrementCurrentIndex()
    }

    // path -> palette from `noctalia theme --dark`, filled in one by one
    // while the picker is open; kept for the next time
    property var palettes: ({})

    function loadPalettes() {
        if (paletteProc.running) return
        for (let i = 0; i < files.count; i++) {
            const path = files.get(i, "filePath")
            if (palettes[path] === undefined) {
                paletteProc.path = path
                paletteProc.command = ["noctalia", "theme", path, "--dark"]
                paletteProc.running = true
                return
            }
        }
    }

    Process {
        id: paletteProc
        property string path
        stdout: StdioCollector {
            onStreamFinished: {
                // a new object, or bindings on `palettes` don't notice
                const all = Object.assign({}, root.palettes)
                try {
                    all[paletteProc.path] = JSON.parse(text)
                } catch (e) {
                    all[paletteProc.path] = null
                }
                root.palettes = all
            }
        }
        onRunningChanged: if (!running && root.open) root.loadPalettes()
    }

    onOpenChanged: {
        if (!open) return
        // start on the wallpaper in use
        for (let i = 0; i < files.count; i++) {
            if (files.get(i, "filePath") === Scheme.wallpaper) {
                strip.currentIndex = i
                strip.positionViewAtIndex(i, ListView.Center)
                break
            }
        }
        loadPalettes()
        // the window only gets the keyboard once it's shown
        focusLater.restart()
    }

    Timer {
        id: focusLater
        interval: 50
        onTriggered: strip.forceActiveFocus()
    }

    IpcHandler {
        target: "wallpapers"
        function toggle(): void { root.toggle() }
    }

    FolderListModel {
        id: files
        folder: "file://" + Scheme.wallpaperDir
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
        showDirs: false
    }

    PanelWindow {
        screen: Quickshell.screens.find(s => Hyprland.monitorFor(s) === Hyprland.focusedMonitor)
                ?? Quickshell.screens[0]
        // keep the window until the closing animation has finished
        visible: root.open || dim.opacity > 0

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "boxshell-wallpapers"
        WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"

        // dim the desktop behind the strip; a click on it closes
        Rectangle {
            id: dim
            anchors.fill: parent
            color: "black"
            opacity: root.open ? 0.5 : 0
            Behavior on opacity { NumberAnimation { duration: 220 } }

            MouseArea {
                anchors.fill: parent
                onPressed: root.open = false
            }

            // scroll from anywhere on the screen, not just over the cards
            WheelHandler {
                onWheel: event => root.step(event.angleDelta.y || event.angleDelta.x)
            }
        }

        ListView {
            id: strip
            readonly property int cardWidth: 400
            readonly property int cardHeight: 225

            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: cardHeight + 110
            orientation: ListView.Horizontal
            spacing: 16
            model: files
            // scroll card by card with keys and wheel, no free flicking
            interactive: false

            // the current card always sits in the middle
            highlightRangeMode: ListView.StrictlyEnforceRange
            preferredHighlightBegin: (width - cardWidth) / 2
            preferredHighlightEnd: (width + cardWidth) / 2
            highlightMoveDuration: 280

            // rise into place when opening
            opacity: root.open ? 1 : 0
            transform: Translate {
                y: root.open ? 0 : 40
                Behavior on y { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
            }
            Behavior on opacity { NumberAnimation { duration: 220 } }

            // ListView turns its own key navigation off with interactive: false
            Keys.onPressed: event => {
                switch (event.key) {
                case Qt.Key_Left:
                case Qt.Key_H:
                    root.step(1)
                    break
                case Qt.Key_Right:
                case Qt.Key_L:
                    root.step(-1)
                    break
                case Qt.Key_Return:
                case Qt.Key_Enter:
                    root.apply(files.get(currentIndex, "filePath"))
                    break
                case Qt.Key_Escape:
                    root.open = false
                    break
                default:
                    return
                }
                event.accepted = true
            }

            WheelHandler {
                onWheel: event => root.step(event.angleDelta.y || event.angleDelta.x)
            }

            delegate: Item {
                id: card
                required property string filePath
                required property string fileName
                required property int index
                readonly property bool current: ListView.isCurrentItem

                width: strip.cardWidth
                height: strip.height

                Rectangle {
                    id: frame
                    width: parent.width
                    height: strip.cardHeight
                    color: Theme.surface
                    border.color: card.current ? Theme.accent : Theme.surface
                    border.width: card.current ? 2 : 1

                    // side cards shrink and fade
                    scale: card.current ? 1 : 0.82
                    opacity: card.current ? 1 : 0.55
                    Behavior on scale { NumberAnimation { duration: 280; easing.type: Easing.OutBack } }
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    Image {
                        anchors { fill: parent; margins: frame.border.width }
                        source: "file://" + card.filePath
                        // decode thumbnails at card size, not 4K
                        sourceSize.width: strip.cardWidth
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        opacity: status === Image.Ready ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }

                    // marks the wallpaper in use
                    Rectangle {
                        visible: card.filePath === Scheme.wallpaper
                        anchors { top: parent.top; right: parent.right; margins: 8 }
                        width: 24
                        height: 24
                        color: Theme.accent
                        Icon {
                            anchors.centerIn: parent
                            text: "check"
                            color: Theme.accentText
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: card.current ? root.apply(card.filePath) : strip.currentIndex = card.index
                    }
                }

                // what the shell will look like with this wallpaper
                Column {
                    readonly property var pal: root.palettes[card.filePath] ?? null

                    anchors { top: frame.bottom; topMargin: 14; horizontalCenter: parent.horizontalCenter }
                    width: parent.width
                    spacing: 8
                    opacity: card.current ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    Label {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideMiddle
                        text: card.fileName
                    }

                    // mock bar: workspaces, clock, a couple of icons
                    Rectangle {
                        id: mock
                        readonly property var p: parent.pal
                        width: parent.width
                        height: 26
                        color: p ? p.surface : Theme.bg
                        border.color: p ? p.surface_container : Theme.surface
                        border.width: 1
                        visible: p !== null
                        Behavior on color { ColorAnimation { duration: 200 } }

                        Row {
                            anchors { left: parent.left; leftMargin: 5; verticalCenter: parent.verticalCenter }
                            spacing: 3
                            Repeater {
                                model: 3
                                Rectangle {
                                    required property int index
                                    width: 18
                                    height: 16
                                    color: index === 0 && mock.p ? mock.p.primary : "transparent"
                                    Label {
                                        anchors.centerIn: parent
                                        text: index + 1
                                        font.pixelSize: Theme.fontSize - 2
                                        color: !mock.p ? Theme.fg : index === 0 ? mock.p.on_primary : mock.p.on_surface
                                    }
                                }
                            }
                        }
                        Label {
                            anchors.centerIn: parent
                            text: "Thu 29 Oct  16:20"
                            font.pixelSize: Theme.fontSize - 2
                            color: mock.p ? mock.p.on_surface : Theme.fg
                        }
                        Row {
                            anchors { right: parent.right; rightMargin: 6; verticalCenter: parent.verticalCenter }
                            spacing: 6
                            Icon { text: "volume_up"; font.pixelSize: 13; color: mock.p ? mock.p.on_surface : Theme.fg }
                            Icon { text: "power_settings_new"; font.pixelSize: 13; color: mock.p ? mock.p.on_surface : Theme.fg }
                        }
                    }

                    // main colours: accents, then surfaces
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 4
                        visible: parent.pal !== null
                        Repeater {
                            model: ["primary", "secondary", "tertiary", "error", "surface_container", "on_surface"]
                            Rectangle {
                                required property string modelData
                                width: 22
                                height: 12
                                color: mock.p ? mock.p[modelData] : "transparent"
                            }
                        }
                    }
                }
            }
        }
    }
}
