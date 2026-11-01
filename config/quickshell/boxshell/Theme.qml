pragma Singleton
import QtQuick
import Quickshell
import qs.services

// Colours and sizes in one place. Colours follow the wallpaper (see
// services/Scheme.qml); kanagawa is the fallback until the palette is ready.
Singleton {
    readonly property bool p: Scheme.ready === true

    readonly property color bg:      p ? Scheme.get("surface")            : "#1F1F28"
    readonly property color surface: p ? Scheme.get("surface_container")  : "#2A2A37"
    readonly property color fg:      p ? Scheme.get("on_surface")         : "#DCD7BA"
    readonly property color dim:     p ? Scheme.get("outline")            : "#727169"
    readonly property color accent:  p ? Scheme.get("primary")            : "#76946A"
    readonly property color accentText: p ? Scheme.get("on_primary")        : "#1F1F28"
    readonly property color warn:    p ? Scheme.get("tertiary")           : "#E6C384"
    readonly property color error:   p ? Scheme.get("error")              : "#E82424"
    readonly property color errorText: p ? Scheme.get("on_error")         : "#1F1F28"

    // See-through background for everything boxshell draws; Hyprland blurs
    // what's behind it (layer rule in hypr/config/rules.lua), like behind
    // Alacritty. Denser the lighter the wallpaper under the bar, so the light
    // text always reads.
    readonly property real glassAlpha: 0.55 + 0.35 * Scheme.brightness
    readonly property color glass: Qt.rgba(bg.r, bg.g, bg.b, glassAlpha)

    // `c` fully transparent. Fade hover colours to this instead of
    // "transparent", which is transparent black: a ColorAnimation from it
    // passes through dark shades on the way.
    function clear(c: color): color {
        return Qt.rgba(c.r, c.g, c.b, 0)
    }

    // Dropdown menus: box padding around the rows (row highlights reach this
    // close to the box edge), where text/graphs/sliders start inside a row or
    // the box, and the gap between bar and menu. A menu's edge lines up with
    // the edge of the bar item that opened it.
    readonly property int menuPadding: 6
    readonly property int menuInset: 10
    readonly property int menuGap: 4

    readonly property string font: "JetBrains Mono"
    readonly property int fontSize: 13
    // sharp corners to match the square look; icons are ligature names
    readonly property string iconFont: "Material Symbols Sharp"
    readonly property int iconSize: 18

    readonly property int barHeight: 32
    // match Hyprland gaps_out so the bar lines up with windows
    readonly property int gapSide: 14
    readonly property int gapTop: 6
    // Bar items: all itemHeight tall, centred in the bar on whole pixels
    // ((barHeight - itemHeight) / 2 must stay whole). An item that is a single
    // icon is an itemHeight square; items with text get itemPadding on each
    // side. `spacing` goes between items.
    readonly property int itemHeight: 26
    // the same gap on all four sides of the bar's end items
    readonly property int itemInset: (barHeight - itemHeight) / 2
    readonly property int itemPadding: 8
    readonly property int spacing: 4
    readonly property int border: 1
}
