pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import QtQuick
import QtQuick.Layouts

import "../.."

Loader {
    id: root
    active: States.logoutPresent

    property color backgroundColor: Config.logout.background

    default property list<LogoutButton> buttons

    sourceComponent: Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window

            property var modelData

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"

            contentItem {
                focus: true
                Keys.onPressed: event => {
                    if (event.key == Qt.Key_Escape) {
                        States.logoutPresent = false;
                    } else {
                        for (let i = 0; i < root.buttons.length; i++) {
                            let button = root.buttons[i];

                            if (event.key == button.keybind)
                                button.exec();
                        }
                    }
                }
            }

            anchors {
                top: true
                left: true
                bottom: true
                right: true
            }

            Rectangle {
                color: root.backgroundColor
                anchors.fill: parent

                MouseArea {
                    anchors.fill: parent
                    onClicked: States.logoutPresent = false

                    GridLayout {
                        anchors.centerIn: parent
                        width: parent.width * 0.50
                        height: parent.height * 0.50
                        columns: 3
                        columnSpacing: 0
                        rowSpacing: 0

                        Repeater {
                            model: root.buttons
                            delegate: Rectangle {
                                id: buttonRect

                                required property LogoutButton modelData
                                required property int index

                                readonly property int row: Math.floor(index / 3)
                                readonly property int col: index % 3
                                readonly property int totalRows: Math.ceil(root.buttons.length / 3)
                                readonly property int cornerRadius: 80

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: Config.colBg
                                topLeftRadius: (row === 0 && col === 0) ? cornerRadius : 0
                                topRightRadius: (row === 0 && col === 2) ? cornerRadius : 0
                                bottomLeftRadius: (row === totalRows - 1 && col === 0) ? cornerRadius : 0
                                bottomRightRadius: (row === totalRows - 1 && col === 2) ? cornerRadius : 0

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true

                                    onClicked: {
                                        States.logoutPresent = false;
                                        buttonRect.modelData.exec();
                                    }
                                }

                                Item {
                                    anchors.centerIn: parent
                                    width: parent.width
                                    height: 105 + 24 + textLabel.height

                                    Text {
                                        id: icon
                                        color: mouseArea.containsMouse ? Config.colRed : Config.colFg
                                        font.pixelSize: 105
                                        font.family: "Symbols Nerd Font"
                                        text: `${buttonRect.modelData.icon}`

                                        anchors {
                                            horizontalCenter: parent.horizontalCenter
                                            top: parent.top
                                        }

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: Config.animDuration
                                                easing.type: Easing.OutCubic
                                            }
                                        }
                                    }

                                    Text {
                                        id: textLabel
                                        text: buttonRect.modelData.text
                                        color: mouseArea.containsMouse ? Config.colRed : Config.colFg
                                        font.pointSize: 14
                                        font.bold: true
                                        font.family: Config.fontFamily

                                        anchors {
                                            top: icon.bottom
                                            topMargin: 22
                                            horizontalCenter: parent.horizontalCenter
                                        }

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: Config.animDuration
                                                easing.type: Easing.OutCubic
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
