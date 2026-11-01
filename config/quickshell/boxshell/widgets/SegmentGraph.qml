import QtQuick
import qs

// A history graph made of square segments: one column per sample (newest on
// the right), each a stack of `rows` squares lit up to its value. Same look
// as the Segments level bars.
Canvas {
    id: root

    // 0..1, oldest first
    property var values: []
    property int columns: 60
    property int rows: 8
    property int gap: 1
    property color onColor: Theme.accent
    property color offColor: Theme.surface

    onValuesChanged: requestPaint()
    onOnColorChanged: requestPaint()
    onOffColorChanged: requestPaint()
    onWidthChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        // Whole-pixel edges so it stays crisp, spread so the graph fills its
        // width and height exactly: some squares end up a pixel wider.
        const colX = c => Math.round(c * (width + gap) / columns)
        const rowY = r => Math.round(r * (height + gap) / rows)
        const offset = columns - values.length
        for (let c = 0; c < columns; c++) {
            const value = c >= offset ? values[c - offset] : 0
            const lit = c >= offset ? Math.max(value > 0.005 ? 1 : 0, Math.round(value * rows)) : 0
            const x = colX(c)
            const w = colX(c + 1) - x - gap
            for (let r = 0; r < rows; r++) {
                // r counts from the bottom
                const y = height - rowY(r + 1) + gap
                const h = rowY(r + 1) - rowY(r) - gap
                ctx.fillStyle = r < lit ? onColor : offColor
                ctx.fillRect(x, y, w, h)
            }
        }
    }
}
