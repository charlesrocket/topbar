import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import TopBar.Nullspace

ShellRoot {
    Scope {
        Variants {
            model: Quickshell.screens

            PanelWindow {
                required property var modelData
                property string currentLayout: NullspaceIpc.kbLayout

                screen: modelData
                anchors.top: true
                anchors.left: true
                anchors.right: true
                implicitHeight: 30
                color: "#1e1e2e"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 2

                    // Space indicators
                    Repeater {
                        model: NullspaceIpc.spaces

                        delegate: Rectangle {
                            required property NullspaceSpace modelData

                            width: 22
                            height: 22
                            radius: 4
                            color: modelData.active ? "#89b4fa" : (
                                                          modelData.clientCount
                                                          > 0 ? "#313244" :
                                                                "transparent")

                            Text {
                                anchors.centerIn: parent
                                text: modelData.index + 1
                                color: modelData.active ? "#1e1e2e" : "#cdd6f4"
                                font.pixelSize: 12
                                font.bold: modelData.active
                            }

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton

                                // Left click: switch to space
                                // Right click: move focused window to space
                                onClicked: mouse => {
                                    if (mouse.button === Qt.RightButton) {
                                        NullspaceIpc.moveFocusedToSpace(
                                                    modelData.index);
                                    } else {
                                        NullspaceIpc.switchSpace(
                                                    modelData.index);
                                    }
                                }
                            }
                        }
                    }

                    // Layout name
                    Text {
                        text: NullspaceIpc.layoutName
                        color: "#a6e3a1"
                        font.pixelSize: 12
                        font.family: "monospace"
                        visible: NullspaceIpc.available

                        MouseArea {
                            anchors.fill: parent

                            onClicked: NullspaceIpc.cycleLayout()
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        id: layoutText

                        text: {
                            if (!currentLayout)
                                return "XX";
                            if (currentLayout.includes('(')
                                    && currentLayout.includes(')')) {
                                const match = currentLayout.match(
                                          /\(([^)]+)\)/);
                                return match ? match[1] :
                                               currentLayout.substring(0,
                                                                       2).toUpperCase(
                                                   );
                            }

                            const firstWord = currentLayout.split(' ')[0];
                            return firstWord.length <= 3 ? firstWord :
                                                           firstWord.substring(0,
                                                                               2).toUpperCase(
                                                               );
                        }
                        font.pixelSize: 12
                        font.bold: true
                        color: "#f38ba8"
                    }

                    // Focused window title
                    Text {
                        text: NullspaceIpc.focusedTitle
                        color: "#cdd6f4"
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        Layout.maximumWidth: 300
                    }
                }

                Text {
                    visible: !NullspaceIpc.available
                    anchors.centerIn: parent
                    text: "Nullspace not available"
                    color: "#f38ba8"
                    font.pixelSize: 12
                }
            }
        }
    }
}
