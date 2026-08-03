import QtQuick
import QtQuick.Layouts

import qs
import qs.bar
import qs.core

Item {
    id: root

    property color colBg: States.ecoMode ? Config.colors.bge : Config.colors.bg
    property color colMain: Config.colors.fg
    property color colDecor: Config.colors.passive
    property color colActive: Config.colors.accent
    property color colCheck: Config.colors.green
    property int cornerRadius: 8
    property string fontFamily: Config.general.fontFamily
    property int fontSize: Config.general.fontSize
    property bool hpConnected: snd.headphonesConnected
    required property var snd

    function getActiveDeviceIcon() {
        for (var i = 0; i < snd.devices.length; i++) {
            const device = snd.devices[i];

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

    function getCurrentIcon() {
        return snd.headphonesConnected ? "󰋋" : root.getActiveDeviceIcon();
    }

    implicitWidth: icon.implicitWidth
    implicitHeight: Config.general.fontSize + 2
    Layout.alignment: Qt.AlignVCenter

    Text {
        id: icon

        color: root.colMain
        anchors.centerIn: parent
        Layout.alignment: Qt.AlignVCenter
        text: {
            if (root.hpConnected)
                return "󰋋";

            for (var i = 0; i < snd.devices.length; i++) {
                const device = snd.devices[i];
                if (device.isDefault) {
                    if (device.mode === 1 || device.mode === 3)
                        return "󰓃";
                    if (device.mode === 2)
                        return "󰍰";
                }
            }

            return "󰤽";
        }

        Behavior on color {
            ColAnim {}
        }

        font {
            family: "Symbols Nerd Font"
            pixelSize: Config.general.fontSize + 2
            bold: true
        }

        Connections {
            function onHeadphonesChanged(state) {
                root.hpConnected = state;
            }

            target: snd
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            menu.show = true;
        }
        onExited: {
            menu.timer.start();
        }
    }

    Dropdown {
        id: menu

        boxParent: icon

        Rectangle {
            id: devices

            color: "transparent"
            radius: root.cornerRadius
            implicitWidth: layout.implicitWidth + 26
            implicitHeight: layout.implicitHeight + 24

            ColumnLayout {
                id: layout

                anchors.centerIn: parent
                anchors.margins: 12
                spacing: 8

                Repeater {
                    model: snd.devices

                    delegate: Rectangle {
                        required property var modelData

                        Layout.fillWidth: true
                        implicitWidth: rowLayout.implicitWidth + 16
                        implicitHeight: rowLayout.implicitHeight + 16
                        color: mouseArea.containsMouse ? "#11ffffff" :
                                                         "transparent"
                        border.width: modelData.isDefault ? 2 : 0
                        border.color: root.colActive
                        radius: 6

                        Behavior on color {
                            ColAnim {}
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
                                font.pixelSize: Config.general.fontSize + 8
                                font.bold: true
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: modelData.description
                                          || modelData.name
                                    color: root.colMain
                                    font.family: root.fontFamily
                                    font.pixelSize: Config.general.fontSize
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    font.bold: true
                                }

                                Text {
                                    text: modelData.name
                                    color: root.colMain
                                    font.family: root.fontFamily
                                    font.pixelSize: Config.general.fontSize - 2
                                    visible: modelData.description
                                             && modelData.description
                                             !== modelData.name
                                }
                            }
                        }

                        MouseArea {
                            id: mouseArea

                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked: {
                                snd.setDefaultDevice(modelData.deviceId);
                                menu.show = false;
                            }
                        }
                    }
                }
            }
        }
    }
}
