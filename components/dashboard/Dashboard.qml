import QtQuick
import QtQuick.Layouts

import Quickshell.Io

import ".."

Rectangle {
    id: root

    property real cpuTemp: System.cpuTemp
    property real pchTemp: System.pchTemp
    property int fontSize: Config.general.fontSize
    property string mail: ""
    property string mailErr: ""

    function getTempColor(temp) {
        if (temp > 80)
            return Config.colors.red;
        if (temp > 65)
            return Config.colors.yellow;

        return Config.colors.fg;
    }

    function getOsIcon() {
        if (System.id === "freebsd")
            return "󰣠";
        else
            return "󰌽";
    }

    anchors.fill: parent
    anchors.topMargin: Config.general.borderWidth > 0 ? 8 : 2
    anchors.bottomMargin: 8
    anchors.leftMargin: 8
    anchors.rightMargin: 8

    Process {
        id: checkMail

        command: ["mail"]

        stderr: StdioCollector {
            onStreamFinished: {
                root.mailErr = this.text;
            }
        }
        stdout: StdioCollector {
            onStreamFinished: {
                root.mail = this.text;
            }
        }
    }

    GridLayout {
        id: dashGrid

        anchors.fill: parent
        columns: 2
        rows: 2
        rowSpacing: 8
        columnSpacing: 8

        ColumnLayout {
            spacing: 8

            // info
            Rectangle {
                Layout.preferredWidth: 357
                Layout.preferredHeight: sysinfo.implicitHeight + 20
                color: "transparent"
                border.width: 1
                border.color: Config.colors.passive
                radius: Config.general.cornerRadius

                RowLayout {
                    id: sysinfo

                    anchors.centerIn: parent

                    Loader {
                        active: true
                        asynchronous: true
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 100

                        sourceComponent: UserImage {
                            shadow: false
                        }
                    }

                    ColumnLayout {
                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                color: Config.colors.fg
                                font.pixelSize: root.fontSize * 1.3
                                font.family: "Symbols Nerd Font"
                                Layout.preferredWidth: root.fontSize * 2
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: root.getOsIcon()
                            }

                            Text {
                                color: Config.colors.fg
                                font.family: Config.general.fontFamily
                                font.pixelSize: root.fontSize
                                text: `${System.prettyName || System.name}`
                                elide: Text.ElideRight
                                Layout.maximumWidth: 220
                            }
                        }

                        RowLayout {
                            Text {
                                color: Config.colors.fg
                                font.family: "Symbols Nerd Font"
                                Layout.preferredWidth: root.fontSize * 2
                                font.pixelSize: root.fontSize * 1.3
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: "󰟀"
                            }

                            Text {
                                color: Config.colors.fg
                                font.family: Config.general.fontFamily
                                font.pixelSize: root.fontSize
                                text: System.desktop
                                elide: Text.ElideRight
                                Layout.maximumWidth: 220
                            }

                            Text {
                                color: Config.colors.fg
                                font.family: "Symbols Nerd Font"
                                Layout.preferredWidth: root.fontSize * 2
                                font.pixelSize: root.fontSize * 1.3
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: ""
                            }

                            Text {
                                color: Config.colors.fg
                                font.pixelSize: root.fontSize
                                font.family: Config.general.fontFamily
                                text: System.cpuCores
                                elide: Text.ElideRight
                                Layout.maximumWidth: 220
                            }
                        }

                        RowLayout {
                            Text {
                                color: Config.colors.fg
                                font.family: "Symbols Nerd Font"
                                Layout.preferredWidth: root.fontSize * 2
                                font.pixelSize: root.fontSize * 1.3
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: ""
                            }

                            Text {
                                color: Config.colors.fg
                                font.family: Config.general.fontFamily
                                font.pixelSize: root.fontSize
                                text: System.shell
                                elide: Text.ElideRight
                                Layout.maximumWidth: 220
                            }

                            Text {
                                color: Config.colors.fg
                                font.family: "Symbols Nerd Font"
                                Layout.preferredWidth: root.fontSize * 2
                                font.pixelSize: root.fontSize * 1.3
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: ""
                            }

                            Text {
                                color: Config.colors.fg
                                font.pixelSize: root.fontSize
                                font.family: Config.general.fontFamily
                                text: System.diskMountPoint
                                elide: Text.ElideRight
                                Layout.maximumWidth: 220
                            }
                        }

                        RowLayout {
                            Text {
                                color: Config.colors.fg
                                font.family: "Symbols Nerd Font"
                                Layout.preferredWidth: root.fontSize * 2
                                font.pixelSize: root.fontSize * 1.3
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: ""
                            }

                            Text {
                                color: Config.colors.fg
                                font.pixelSize: root.fontSize
                                font.family: Config.general.fontFamily
                                text: System.user
                                elide: Text.ElideRight
                                Layout.maximumWidth: 220
                            }
                        }
                    }
                }
            }

            Row {
                spacing: 8

                Cal {
                    id: calendar

                    width: 284
                    height: 280
                }

                // temperatures
                Rectangle {
                    width: 65
                    height: 280
                    color: "transparent"
                    border.width: 1
                    border.color: Config.colors.passive
                    radius: Config.general.cornerRadius

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 4

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            spacing: 14

                            // cpu temp
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: false
                                Layout.preferredWidth: 10
                                radius: Config.general.cornerRadius
                                color: Config.colors.extraDark
                                clip: true

                                Rectangle {
                                    readonly property real fraction:
                                        root.cpuTemp > 0 ? Math.min(
                                                               root.cpuTemp
                                                               / 100.0, 1.0) :
                                                           0.0

                                    anchors.bottom: parent.bottom
                                    width: parent.width
                                    height: parent.height * fraction
                                    radius: Config.general.cornerRadius
                                    color: getTempColor(root.cpuTemp)

                                    Behavior on height {
                                        NumberAnimation {
                                            duration: 400
                                            easing.type: Easing.InOutQuad
                                        }
                                    }
                                }
                            }

                            // pch temp
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: false
                                Layout.preferredWidth: 10
                                radius: Config.general.cornerRadius
                                color: Config.colors.extraDark
                                clip: true

                                Rectangle {
                                    readonly property real fraction:
                                        root.pchTemp > 0 ? Math.min(
                                                               root.pchTemp
                                                               / 100.0, 1.0) :
                                                           0.0

                                    anchors.bottom: parent.bottom
                                    width: parent.width
                                    height: parent.height * fraction
                                    radius: Config.general.cornerRadius
                                    color: getTempColor(root.pchTemp)

                                    Behavior on height {
                                        NumberAnimation {
                                            duration: 400
                                            easing.type: Easing.InOutQuad
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            spacing: 8

            // player
            Rectangle {
                Layout.preferredWidth: 270
                Layout.preferredHeight: 320
                color: "transparent"
                border.width: 1
                border.color: Config.colors.passive
                radius: Config.general.cornerRadius

                Player {
                    anchors.fill: parent
                    anchors.margins: 10
                }
            }

            // mail
            Rectangle {
                width: 270
                height: 80
                color: "transparent"
                border.width: 1
                border.color: Config.colors.passive
                radius: Config.general.cornerRadius

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    // icon
                    Text {
                        text: ""
                        color: Config.colors.fg
                        font.pixelSize: root.fontSize * 2
                        font.family: "Symbols Nerd Font"
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        Layout.preferredWidth: root.fontSize * 2
                        Layout.preferredHeight: root.fontSize * 2
                    }

                    // status
                    Text {
                        text: root.mail || root.mailErr.replace(
                                  /\s+for\s+\S+[\s\S]*$/, "")
                        color: Config.colors.fg
                        font.pixelSize: root.fontSize
                        font.family: Config.general.fontFamily
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }

    Timer {
        running: States.dashboardPresent
        interval: 5000
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            calendar.updateDate();
            checkMail.running = true;
        }
    }
}
