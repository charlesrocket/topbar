import Quickshell

import QtQuick
import QtQuick.Shapes

import "../.."

Shape {
    id: root

    required property int barWidth
    required property int barHeight

    property int sw: Config.general.borderWidth > 0 ? Config.general.borderWidth : 0
    property int cr: Config.general.cornerRadius
    property int ramp: cr * 2

    preferredRendererType: Shape.CurveRenderer
    width: barWidth + sw
    height: barHeight + sw
    x: -sw / 2
    y: -sw / 2

    ShapePath {
        strokeColor: Config.colors.border
        strokeWidth: root.sw
        fillColor: "transparent"

        // top-left corner start
        startX: root.cr
        startY: 0

        // top edge
        PathLine {
            x: bar.width - root.cr
            y: 0
        }

        // top-right corner
        PathArc {
            x: bar.width
            y: root.cr
            radiusX: root.cr
            radiusY: root.cr
        }

        // right edge down
        PathLine {
            x: bar.width
            y: bar.height - root.cr
        }

        // bottom-right corner
        PathArc {
            x: bar.width - root.cr
            y: bar.height
            radiusX: root.cr
            radiusY: root.cr
        }

        // bottom edge right side, up to dropdown right ramp
        PathLine {
            x: States.dropdownRevealed ? States.dropdownX + States.dropdownWidth + root.ramp : root.cr
            y: bar.height + Config.general.borderWidth
        }

        // dropdown gap
        PathMove {
            x: States.dropdownRevealed ? States.dropdownX + States.dropdownWidth + root.ramp : root.cr
            y: bar.height + Config.general.borderWidth
        }

        // ramp into dropdown right side (curves down and left)
        PathArc {
            x: States.dropdownRevealed ? States.dropdownX + States.dropdownWidth : root.cr
            y: States.dropdownRevealed ? bar.height + root.ramp : bar.height
            radiusX: root.ramp
            radiusY: root.ramp
            direction: PathArc.Counterclockwise
        }

        // dropdown right edge down
        PathLine {
            x: States.dropdownRevealed ? States.dropdownX + States.dropdownWidth : root.cr
            y: States.dropdownRevealed ? bar.height + States.dropdownHeight - root.cr : bar.height
        }

        // dropdown bottom-right corner
        PathArc {
            x: States.dropdownRevealed ? States.dropdownX + States.dropdownWidth - root.cr : root.cr
            y: States.dropdownRevealed ? bar.height + States.dropdownHeight : bar.height
            radiusX: root.cr
            radiusY: root.cr
            direction: PathArc.Clockwise
        }

        // dropdown bottom edge
        PathLine {
            x: States.dropdownRevealed ? States.dropdownX + root.cr : root.cr
            y: States.dropdownRevealed ? bar.height + States.dropdownHeight : bar.height
        }

        // dropdown bottom-left corner
        PathArc {
            x: States.dropdownRevealed ? States.dropdownX : root.cr
            y: States.dropdownRevealed ? bar.height + States.dropdownHeight - root.cr : bar.height
            radiusX: root.cr
            radiusY: root.cr
            direction: PathArc.Clockwise
        }

        // dropdown left edge up
        PathLine {
            x: States.dropdownRevealed ? States.dropdownX : root.cr
            y: States.dropdownRevealed ? bar.height + root.ramp : bar.height
        }

        // ramp back to bar bottom (curves up and left)
        PathArc {
            x: States.dropdownRevealed ? States.dropdownX - root.ramp : root.cr
            y: bar.height + Config.general.borderWidth
            radiusX: root.ramp
            radiusY: root.ramp
            direction: PathArc.Counterclockwise
        }

        // bottom edge left side
        PathLine {
            x: root.cr
            y: bar.height
        }

        // bottom-left corner
        PathArc {
            x: 0
            y: bar.height - root.cr
            radiusX: root.cr
            radiusY: root.cr
        }

        // left edge up
        PathLine {
            x: 0
            y: root.cr
        }

        // top-left corner close
        PathArc {
            x: root.cr
            y: 0
            radiusX: root.cr
            radiusY: root.cr
        }
    }
}
