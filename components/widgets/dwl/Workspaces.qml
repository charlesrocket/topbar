pragma ComponentBehavior: Bound

import Quickshell.DWL

import QtQuick
import QtQuick.Layouts

import "../../.."
import "../.."

RowLayout {
    id: root
    spacing: 6

    property int animDuration: 250
    property int fontSize: Config.general.fontSize
    property string fontFamily: "Symbols Nerd Font"
    property color colNormal: Config.colors.fg
    property color colActive: Config.colors.accent
    property color colPassive: Qt.darker(Config.colors.passive, 1.5)
    property color colAction: Config.colors.action
    property DwlIpcOutput dwlOutput: DwlIpc.outputs.length > 0 ? DwlIpc.outputs[0] : null

    required property var names

    Repeater {
        model: dwlOutput ? dwlOutput.tags : []

        Text {
            id: button

            required property int index
            required property DwlTag modelData

            property bool isHovered: false

            text: root.names[index]
            color: isHovered ? root.colAction : modelData.active ? root.colActive : (modelData.clientCount > 0 ? root.colNormal : root.colPassive)

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

                onClicked: root.dwlOutput.setTags(1 << modelData.index)
                onEntered: button.isHovered = true
                onExited: button.isHovered = false
            }
        }
    }
}
