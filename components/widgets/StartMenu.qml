import QtQuick
import QtQuick.Layouts

import qs
import qs.core

RowLayout {
    id: root

    property int animDuration: 250
    property int fontSize: Config.appearance.fontSize
    property string fontFamily: "Symbols Nerd Font"
    property color colNormal: Config.colors.fg
    property color colActive: Config.colors.accent
    property color colPassive: Qt.darker(Config.colors.passive, 1.5)
    property color colAction: Config.colors.action

    spacing: 6

    Text {
        id: icon

        property bool isHovered: false

        text: States.getOsIcon()
        color: isHovered ? root.colAction : root.colNormal
        leftPadding: 4
        rightPadding: 4

        Behavior on color {
            ColAnim {}
        }

        font {
            family: root.fontFamily
            pixelSize: root.fontSize
            bold: true
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: icon.isHovered = true
            onExited: icon.isHovered = false
        }
    }
}
