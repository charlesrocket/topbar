import QtQuick
import QtQuick.Layouts

import Quickshell.WindowManager

import qs
import qs.core

RowLayout {
    id: root

    property int animDuration: Config.appearance.animDuration
    property int fontSize: Config.appearance.fontSize
    property string fontFamily: "Symbols Nerd Font"
    property color colNormal: Config.colors.fg
    property color colActive: Config.colors.accent
    property color colPassive: Qt.darker(Config.colors.passive, 1.5)
    property color colAction: Config.colors.action
    required property var names

    spacing: 6

    Repeater {
        model: WindowManager.windowsets

        Text {
            id: button

            required property var modelData
            readonly property var windowset: modelData
            readonly property int workspaceNumber: windowset.coordinates.length
                                                   > 0 ? windowset.coordinates[0] :
                                                         -1
            readonly property string displayName: workspaceNumber >= 0
                                                  && workspaceNumber
                                                  < root.names.length
                                                  ? root.names[workspaceNumber] :
                                                    (windowset.name !== ""
                                                     ? windowset.name :
                                                       workspaceNumber.toString(
                                                           ))

            visible: windowset.shouldDisplay
            text: displayName
            color: mouseArea.containsMouse ? root.colAction : windowset.active
                                             ? root.colActive :
                                               windowset.urgent
                                               ? root.colAction :
                                                 windowset.shouldDisplay
                                                 ? root.colNormal :
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
                    if (mouse.button === Qt.RightButton) {
                        // not supported
                    } else {
                        if (button.windowset.canActivate)
                            button.windowset.activate();
                    }
                }
            }
        }
    }
}
