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

    readonly property string font: "JetBrains Mono"
    readonly property int fontSize: 12
    // sharp corners to match the square look; icons are ligature names
    readonly property string iconFont: "Material Symbols Sharp"
    readonly property int iconSize: 16

    readonly property int barHeight: 32
    // match Hyprland gaps_out so the bar lines up with windows
    readonly property int gapSide: 14
    readonly property int gapTop: 6
    readonly property int spacing: 12
    readonly property int border: 1
}
