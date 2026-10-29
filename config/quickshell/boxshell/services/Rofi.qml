pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs

// Writes the current colours for rofi to ~/.cache/boxshell/colors.rasi,
// which config/rofi/config.rasi imports.
Singleton {
    id: root
    function rgba(c: color): string {
        const ch = v => Math.round(v * 255)
        return `rgba(${ch(c.r)}, ${ch(c.g)}, ${ch(c.b)}, ${Math.round(c.a * 100)}%)`
    }

    readonly property string text: `* {
    bg:      ${Theme.bg};
    glass:   ${rgba(Theme.glass)};
    surface: ${Theme.surface};
    fg:      ${Theme.fg};
    dim:     ${Theme.dim};
    accent:  ${Theme.accent};
    on-accent: ${Theme.accentText};
    font:    "${Theme.font} ${Theme.fontSize}";
}
`
    // colours change one by one when the palette switches; write once at the end
    onTextChanged: writeLater.restart()

    Timer {
        id: writeLater
        interval: 200
        onTriggered: file.setText(root.text)
    }

    FileView {
        id: file
        path: Quickshell.env("HOME") + "/.cache/boxshell/colors.rasi"
        printErrors: false
    }
}
