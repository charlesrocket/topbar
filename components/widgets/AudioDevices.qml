import Quickshell
import Quickshell.Services.OSS

import QtQuick
import QtQuick.Layouts

import "../.."

Item {
    id: root

    required property color colBg
    required property color colMain
    required property color colDecor
    required property color colActive
    required property color colCheck
    required property color colWinBorder
    required property color colButtonHover

    property int cornerRadius: 8
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14

    implicitWidth: buttonText.implicitWidth
    implicitHeight: buttonText.implicitHeight

    function getActiveDeviceIcon() {
        for (var i = 0; i < OSS.devices.length; i++) {
            const device = OSS.devices[i];

            if (device.isDefault) {
                const mode = device.mode;

                if (mode === 1 || mode === 3)
                    return "󰓃";
                if (mode === 2)
                    return "󰍰";
            }
        }

        return "󰤽";
    }

    Text {
        id: buttonText
        text: OSS.headphonesConnected ? "󰋋" : root.getActiveDeviceIcon()
        color: root.colMain

        font {
            family: "Symbols Nerd Font"
            pixelSize: root.fontSize
            bold: true
        }

        Behavior on color {
            ColorAnimation {
                duration: Config.animDuration
                easing.type: Easing.OutCubic
            }
        }
    }

    MouseArea {
        id: buttonMouseArea
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            buttonText.color = root.colButtonHover;
            menu.show = true;
        }

        onExited: {
            buttonText.color = root.colMain;
            menu.timer.start();
        }
    }

    Connections {
        target: OSS

        function onHeadphonesChanged(state) {
            buttonText.text = state ? "󰋋" : root.getActiveDeviceIcon();
        }
    }

    Connections {
        target: OSS

        function onDevicesChanged() {
            buttonText.text = root.getActiveDeviceIcon();
        }
    }

    Dropdown {
        id: menu
        boxParent: buttonText

        Rectangle {
            id: devices
            color: root.colBg
            radius: root.cornerRadius
            border.color: root.colWinBorder
            implicitWidth: layout.implicitWidth + 24
            implicitHeight: layout.implicitHeight + 24

            ColumnLayout {
                id: layout
                anchors.centerIn: parent
                anchors.margins: 12
                spacing: 8

                Repeater {
                    model: OSS.devices

                    delegate: Rectangle {
                        required property var modelData

                        Layout.fillWidth: true
                        implicitWidth: rowLayout.implicitWidth + 16
                        implicitHeight: rowLayout.implicitHeight + 16
                        color: mouseArea.containsMouse ? "#11ffffff" : "transparent"
                        border.width: modelData.isDefault ? 2 : 0
                        border.color: root.colActive
                        radius: 6

                        Behavior on color {
                            ColorAnimation {
                                duration: Config.animDuration
                                easing.type: Easing.OutCubic
                            }
                        }

                        RowLayout {
                            id: rowLayout
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 10

                            Text {
                                text: {
                                    if (modelData.mode === 1)
                                        return "";
                                    if (modelData.mode === 2)
                                        return "󰻃";
                                    return "󰤽";
                                }

                                horizontalAlignment: Text.AlignHCenter
                                Layout.preferredWidth: 24
                                color: root.colMain
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: root.fontSize + 8
                                font.bold: true
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: modelData.description || modelData.name
                                    color: root.colMain
                                    font.family: root.fontFamily
                                    font.pixelSize: root.fontSize
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    font.bold: true
                                }

                                Text {
                                    text: modelData.name
                                    color: root.colMain
                                    font.family: root.fontFamily
                                    font.pixelSize: root.fontSize - 2
                                    visible: modelData.description && modelData.description !== modelData.name
                                }
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked: {
                                OSS.setDefaultDevice(modelData.deviceId);
                                menu.show = false;
                            }
                        }
                    }
                }
            }
        }
    }
}
