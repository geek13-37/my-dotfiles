pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Current wallpaper plus Material colours (dark scheme) generated from it
// with `noctalia theme`, which also renders the app themes (alacritty, GTK,
// spotify...) listed in theming/templates.toml, like Noctalia itself did.
// The path lives in ~/.local/state/boxshell/wallpaper; change it with
//   qs -c boxshell ipc call wallpaper set <path>
Singleton {
    id: root

    readonly property string stateDir: Quickshell.env("HOME") + "/.local/state/boxshell"
    // the wallpaper picker lists the pictures in here
    readonly property string wallpaperDir: Quickshell.env("HOME") + "/Pictures"
    readonly property string defaultWallpaper: Quickshell.env("HOME") + "/Pictures/abstract-swirls.jpg"

    // wallpapers are cropped to fill the screen, measure them the same way
    readonly property int screenW: Quickshell.screens[0]?.width ?? 1920
    readonly property int screenH: Quickshell.screens[0]?.height ?? 1080

    readonly property string wallpaper: wallpaperFile.text().trim() || defaultWallpaper
    // palette from `noctalia theme --dark`; empty until the first run finishes
    property var colors: ({})
    readonly property bool ready: colors.surface !== undefined

    // how light the wallpaper is under the bar, 0 (black) to 1 (white);
    // the bar blurs and tints its backdrop more the lighter this is
    property real brightness: 0.3

    function get(name: string): color {
        return colors[name]
    }

    function setWallpaper(path: string) {
        wallpaperFile.setText(path)
    }

    onWallpaperChanged: regenerate()
    Component.onCompleted: regenerate()

    // the previous wallpaper can still be in the works when the picker
    // switches again; run once more when it finishes
    property bool pending: false
    function regenerate() {
        if (measure.running || palette.running) pending = true
        else run()
    }
    // Measure brightness first, then the palette, then the app themes.
    // Commands are built here: a binding on `wallpaper` may not have updated
    // yet when this runs from onWallpaperChanged.
    function run() {
        // -alpha remove: on PNGs with an alpha channel the mean would
        // average in the (opaque, so ~1.0) alpha and call dark pictures light
        measure.command = ["magick", wallpaper, "-background", "black", "-alpha", "remove", "-resize", `${screenW}x${screenH}^`,
                           "-gravity", "center", "-extent", `${screenW}x${screenH}`, "+repage",
                           "-gravity", "northwest", "-crop", `${screenW}x40+0+0`,
                           "-colorspace", "Gray", "-format", "%[fx:mean]", "info:"]
        measure.running = true
    }
    function runPalette() {
        palette.command = ["noctalia", "theme", wallpaper, "--dark"]
        palette.running = true
    }
    function runTemplates() {
        if (templates.running) {
            templates.pending = true
            return
        }
        templates.command = ["noctalia", "theme", wallpaper, "--dark",
                             "-c", Quickshell.shellPath("theming/templates.toml")]
        templates.running = true
    }

    FileView {
        id: wallpaperFile
        path: root.stateDir + "/wallpaper"
        watchChanges: true
        onFileChanged: reload()
        // first run: no state file yet
        printErrors: false
    }

    Process {
        id: palette
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.colors = JSON.parse(text)
                    root.runTemplates()
                } catch (e) {
                    console.warn("boxshell: palette not parsed:", e)
                }
            }
        }
        onRunningChanged: {
            if (!running && root.pending) {
                root.pending = false
                root.run()
            }
        }
    }

    Process {
        id: measure
        stdout: StdioCollector {
            onStreamFinished: {
                const value = parseFloat(text)
                if (!isNaN(value)) root.brightness = value
                root.runPalette()
            }
        }
    }

    // app themes: slower (a couple of seconds, runs hooks like spicetify),
    // so the bar doesn't wait for it
    Process {
        id: templates
        property bool pending: false
        onRunningChanged: {
            if (!running && pending) {
                pending = false
                root.runTemplates()
            }
        }
    }

    IpcHandler {
        target: "wallpaper"
        function set(path: string): void { root.setWallpaper(path) }
        function get(): string { return root.wallpaper }
    }
}
