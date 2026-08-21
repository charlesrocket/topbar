import QtQuick
import QtQuick.Effects

import Quickshell.Services.SystemTray

import qs.core

Item {
    id: root

    property color iconColor: Config.colors.fg
    property int iconSize: Config.appearance.fontSize

    implicitWidth: row.width + 10
    implicitHeight: iconSize + 4

    Rectangle {
        color: Config.colors.extraDark
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        radius: Config.appearance.cornerRadius / 2

        Row {
            id: row

            anchors.centerIn: parent
            spacing: 4

            Repeater {
                model: SystemTray.items

                MouseArea {
                    id: trayElement

                    required property SystemTrayItem modelData

                    width: root.iconSize
                    hoverEnabled: true
                    height: root.iconSize
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: event => {
                        if (event.button === Qt.LeftButton)
                            trayElement.modelData.activate();
                        else if (event.button === Qt.RightButton) {
                            const pos = trayElement.mapToItem(
                                      States.barPanel.contentItem, 0, 0);
                            trayElement.modelData.display(States.barPanel, pos.x,
                                                          pos.y);
                        } else
                            trayElement.modelData.secondaryActivate();
                    }

                    Image {
                        id: icon

                        anchors.fill: parent
                        source: trayElement.modelData.icon
                        sourceSize: Qt.size(root.iconSize, root.iconSize)
                        mipmap: true
                        smooth: false

                        // render as a texture (svg cases)
                        layer.enabled: true
                        layer.smooth: true
                        layer.textureSize: Qt.size(root.iconSize * 2,
                                                   root.iconSize * 2)

                        layer.effect: MultiEffect {
                            saturation: trayElement.containsMouse
                                        | trayElement.containsPress ? 0 : -1.0
                            colorization: trayElement.containsMouse
                                          | trayElement.containsPress ? 0 : 1.0
                            colorizationColor: root.iconColor
                        }
                    }
                }
            }
        }
    }
}
