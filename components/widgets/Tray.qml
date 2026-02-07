pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.SystemTray

import QtQuick
import QtQuick.Effects

import "../.."

Item {
    id: root

    property color iconColor: Config.colFg
    property int iconSize: Config.fontSize

    implicitWidth: row.width
    implicitHeight: iconSize

    Row {
        id: row
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
                    // cannot find a way to call context menu under wayland
                    if (event.button === Qt.LeftButton)
                        trayElement.modelData.activate();
                    else
                        trayElement.modelData.secondaryActivate();
                }

                Image {
                    id: icon
                    anchors.fill: parent
                    source: trayElement.modelData.icon
                    sourceSize: Qt.size(root.iconSize, root.iconSize)
                    smooth: true

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
