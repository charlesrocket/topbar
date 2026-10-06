import QtQuick
import QtQuick.Layouts

import TopBar.Nullspace

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
    required property var names

    spacing: 6

    Repeater {
        model: 10

        Text {
            id: button

            required property int index

            // spaces layout is 123456790
            readonly property int spaceIndex: button.index === 9 ? 0 :
                                                                   button.index
                                                                   + 1
            readonly property NullspaceSpace space:
                NullspaceIpc.spaces[button.spaceIndex]

            text: root.names[button.index]
            color: mouseArea.containsMouse ? root.colAction : (space
                                                               && space.active)
                                             ? root.colActive : (space
                                                                 && space.clientCount
                                                                 > 0) ? root.colNormal :
                                                                        root.colPassive
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
                id: mouseArea

                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton)
                        NullspaceIpc.moveFocusedToSpace(button.spaceIndex);
                    else
                        NullspaceIpc.switchSpace(button.spaceIndex);
                }
            }
        }
    }
}
