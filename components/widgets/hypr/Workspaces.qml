import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts

import "../.."

RowLayout {
    id: root

    property int animDuration: 250
    property int fontSize: Config.general.fontSize
    property string fontFamily: "Symbols Nerd Font"
    property color colNormal: Config.colors.fg
    property color colActive: Config.colors.accent
    property color colPassive: Qt.darker(Config.colors.passive, 1.5)
    property color colAction: Config.colors.action

    required property var names

    Repeater {
        model: 10

        Text {
            id: button

            required property int index
            property bool isHovered: false
            property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

            text: root.names[index]
            color: isHovered ? root.colAction : isActive ? root.colActive : (ws ? root.colNormal : root.colPassive)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            leftPadding: 4
            rightPadding: 4

            font {
                family: root.fontFamily
                pixelSize: root.fontSize
                bold: true
            }

            Behavior on color {
                ColAnim {}
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
}
