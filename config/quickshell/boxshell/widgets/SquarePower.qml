import QtQuick
import QtQuick.Shapes
import qs

// A square power symbol (the usual one is a circle): an outlined square open
// at the top with a bar through the gap. 2px lines on whole pixels so it
// stays crisp; drawn in an 18px box like the Material icons.
Shape {
    id: root
    property color color: Theme.fg

    width: 18
    height: 18
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        strokeColor: root.color
        strokeWidth: 2
        fillColor: "transparent"
        capStyle: ShapePath.FlatCap
        joinStyle: ShapePath.MiterJoin

        // square from x 4..14, y 5..15 (line centres), open from x 7 to 11 at the top
        startX: 11; startY: 5
        PathLine { x: 14; y: 5 }
        PathLine { x: 14; y: 15 }
        PathLine { x: 4; y: 15 }
        PathLine { x: 4; y: 5 }
        PathLine { x: 7; y: 5 }
    }

    ShapePath {
        strokeColor: root.color
        strokeWidth: 2
        capStyle: ShapePath.FlatCap

        // the bar through the gap
        startX: 9; startY: 2
        PathLine { x: 9; y: 10 }
    }
}
