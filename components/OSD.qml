import QtQuick
import QtQuick.Layouts

import Quickshell

Scope {
    id: root

    required property string icon
    required property bool muted
    required property int value
    property bool osdPresent: false

    function trigger() {
        root.osdPresent = true;
        hideTimer.restart();
    }

    Timer {
        id: hideTimer

        interval: 1200

        onTriggered: root.osdPresent = false
    }

    LazyLoader {
        active: root.osdPresent && !States.ecoMode

        PanelWindow {
            anchors.bottom: true
            margins.bottom: screen.height / 5
            exclusiveZone: 0
            implicitWidth: 300
            implicitHeight: 50
            color: "transparent"

            mask: Region {}

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: Config.colors.bg

                RowLayout {
                    spacing: 8

                    anchors {
                        fill: parent
                        leftMargin: 15
                        rightMargin: 15
                    }

                    Text {
                        text: root.icon
                        color: root.muted ? Config.colors.red : Config.colors.fg
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 24
                        font.bold: true
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 10
                        radius: 20
                        color: Config.colors.passive

                        Rectangle {
                            color: root.muted ? Config.colors.red : Config.colors.fg
                            width: parent.width * (root.value / 100.0)
                            radius: parent.radius

                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }
                        }
                    }
                }
            }
        }
    }
}
