pragma ComponentBehavior: Bound

import Quickshell.Services.SystemTray

import QtQuick
import QtQuick.Effects

import ".."

Item {
    id: root
    implicitWidth: row.width + 10
    implicitHeight: iconSize + 4

    property color iconColor: Config.colors.fg
    property int iconSize: Config.general.fontSize

    Rectangle {
        color: Config.colors.extraDark
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        radius: Config.general.cornerRadius / 2

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 4

            Repeater {
                model: SystemTray.items

                MouseArea {
                    id: trayElement
                    width: root.iconSize
                    height: root.iconSize
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    required property SystemTrayItem modelData

                    onClicked: event => {
                        if (event.button === Qt.LeftButton)
                            trayElement.modelData.activate();
                        else if (event.button === Qt.RightButton) {
                            const pos = trayElement.mapToItem(States.barPanel.contentItem, 0, 0);
                            trayElement.modelData.display(States.barPanel, pos.x, pos.y);
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
                        layer.textureSize: Qt.size(root.iconSize * 2, root.iconSize * 2)
                        layer.effect: MultiEffect {
                            saturation: -1.0
                            colorization: 1.0
                            colorizationColor: root.iconColor
                        }
                    }
                }
            }
        }
    }
}
