pragma ComponentBehavior: Bound

import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts

import "../.."

Repeater {
    id: root
    model: 10

    required property var names

    property int animDuration: 250
    property int fontSize: Config.fontSize
    property string fontFamily: "Symbols Nerd Font"
    property color colNormal: Config.colFg
    property color colActive: Config.colAccent
    property color colPassive: Qt.darker(Config.colPassive, 1.5)
    property color colAction: Config.colAction

    Text {
        id: button

        required property int index
        property bool isHovered: false
        property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
        property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

        text: root.names[index]
        color: isHovered ? root.colAction : isActive ? root.colActive : (ws ? root.colNormal : root.colPassive)

        leftPadding: 4
        rightPadding: 4

        font {
            family: root.fontFamily
            pixelSize: root.fontSize
            bold: true
        }

        Behavior on color {
            ColorAnimation {
                duration: root.animDuration
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onClicked: Hyprland.dispatch("workspace " + (parent.index + 1))
            onEntered: button.isHovered = true
            onExited: button.isHovered = false
        }
    }
}
