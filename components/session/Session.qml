import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import qs
import qs.core

Loader {
    id: root

    property color backgroundColor: Config.session.background
    default property list<SessionButton> buttons

    active: States.sessionPresent

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
                        States.sessionPresent = false;
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

                    onClicked: States.sessionPresent = false

                    GridLayout {
                        anchors.centerIn: parent
                        width: parent.width * 0.50
                        height: parent.height * 0.50
                        columns: 3
                        columnSpacing: 0
                        rowSpacing: 0

                        Repeater {
                            id: buttonRepeater

                            model: root.buttons

                            delegate: Rectangle {
                                id: buttonRect

                                required property SessionButton modelData
                                required property int index
                                readonly property int row: Math.floor(index / 3)
                                readonly property int col: index % 3
                                readonly property int totalRows: Math.ceil(
                                                                     root.buttons.length
                                                                     / 3)
                                readonly property int cornerRadius: 80

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: Config.colors.bg
                                focus: true
                                topLeftRadius: (row === 0 && col === 0)
                                               ? cornerRadius : 0
                                topRightRadius: (row === 0 && col === 2)
                                                ? cornerRadius : 0
                                bottomLeftRadius: (row === totalRows - 1 && col
                                                   === 0) ? cornerRadius : 0
                                bottomRightRadius: (row === totalRows - 1
                                                    && col === 2)
                                                   ? cornerRadius : 0
                                KeyNavigation.right: buttonRepeater.itemAt(
                                                         index + 1)
                                KeyNavigation.left: buttonRepeater.itemAt(index
                                                                          - 1)
                                KeyNavigation.down: buttonRepeater.itemAt(index
                                                                          + 3)
                                KeyNavigation.up: buttonRepeater.itemAt(index
                                                                        - 3)

                                Keys.onReturnPressed: {
                                    States.sessionPresent = false;
                                    modelData.exec();
                                }
                                Keys.onEnterPressed: {
                                    States.sessionPresent = false;
                                    modelData.exec();
                                }
                                Component.onCompleted: {
                                    if (index === 0) {
                                        forceActiveFocus();
                                    }
                                }

                                MouseArea {
                                    id: mouseArea

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onEntered: buttonRect.forceActiveFocus()
                                    onClicked: {
                                        States.sessionPresent = false;
                                        buttonRect.modelData.exec();
                                    }
                                }

                                FocusScope {
                                    width: parent.width
                                    height: 105 + 24 + textLabel.height

                                    Item {
                                        anchors.centerIn: parent

                                        Text {
                                            id: icon

                                            color: (mouseArea.containsMouse
                                                    || buttonRect.activeFocus)
                                                   ? Config.colors.accent :
                                                     Config.colors.fg
                                            font.pixelSize: 105
                                            font.family: "Symbols Nerd Font"
                                            text: `${buttonRect.modelData.icon}`
                                            focus: true

                                            Behavior on color {
                                                ColAnim {}
                                            }

                                            anchors {
                                                horizontalCenter:
                                                    parent.horizontalCenter
                                                top: parent.top
                                            }
                                        }

                                        Text {
                                            id: textLabel

                                            text: buttonRect.modelData.text
                                            color: (mouseArea.containsMouse
                                                    || buttonRect.activeFocus)
                                                   ? Config.colors.accent :
                                                     Config.colors.fg
                                            font.pointSize: 14
                                            font.bold: true
                                            font.family:
                                                Config.general.fontFamily

                                            Behavior on color {
                                                ColAnim {}
                                            }

                                            anchors {
                                                top: icon.bottom
                                                topMargin: 22
                                                horizontalCenter:
                                                    parent.horizontalCenter
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
