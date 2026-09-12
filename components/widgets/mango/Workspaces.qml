import QtQuick
import QtQuick.Layouts

import TopBar.Mango

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
    property MangoIpcOutput mangoOutput: States.mangoOutput
    required property var names

    spacing: 6

    Repeater {
        model: mangoOutput ? mangoOutput.tags : []

        Text {
            id: button

            required property int index
            required property MangoTag modelData
            property bool isHovered: false

            text: root.names[index]
            color: isHovered ? root.colAction : button.modelData.active
                               ? root.colActive : (button.modelData.clientCount
                                                   > 0 ? root.colNormal :
                                                         root.colPassive)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
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

                onClicked: root.mangoOutput.setTags(1 << button.modelData.index)
                onEntered: button.isHovered = true
                onExited: button.isHovered = false
            }
        }
    }

    Text {
        id: tagZero

        property bool isHovered: false

        text: root.names[9]
        color: isHovered ? root.colAction : (root.mangoOutput
                                             && root.mangoOutput.tags.every(t
                                                                            => t.active)
                                             ? root.colNormal : root.colPassive)
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

            onClicked: root.mangoOutput.setTags(-1)
            onEntered: tagZero.isHovered = true
            onExited: tagZero.isHovered = false
        }
    }
}
