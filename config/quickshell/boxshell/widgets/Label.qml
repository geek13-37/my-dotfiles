import QtQuick
import qs

// Text with the shell's font and colours.
Text {
    color: Theme.fg
    font.family: Theme.font
    font.pixelSize: Theme.fontSize
    // Regular looks thin at this size
    font.weight: Font.Medium
    verticalAlignment: Text.AlignVCenter
    // FreeType with hinting, like other apps: QML's own renderer makes small
    // text look blocky
    renderType: Text.NativeRendering
}
