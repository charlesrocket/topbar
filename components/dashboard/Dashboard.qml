import Quickshell
import Quickshell.Io

import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../.."
import ".."

Rectangle {
    id: root
    anchors.fill: parent
    anchors.margins: 8

    property real cpuTemp
    property real pchTemp
    property int fontSize: Config.general.fontSize
    property string mail: ""
    property string mailErr: ""

    Process {
        id: sysctl
        command: ["sysctl", "hw.acpi.thermal.tz0.temperature", "dev.pchtherm.0.temperature"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.split("\n");

                lines.forEach(line => {
                    const match = line.match(/^(\S+):\s*([\d.]+)C/);
                    if (!match) return;

                    const [, key, val] = match;
                    if (key === "hw.acpi.thermal.tz0.temperature")
                        root.cpuTemp = parseFloat(val);
                    else if (key === "dev.pchtherm.0.temperature")
                        root.pchTemp = parseFloat(val);
                });
            }
        }
    }

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
                Layout.preferredWidth: 352
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
                    width: 280
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
                                    anchors.bottom: parent.bottom
                                    width: parent.width
                                    height: parent.height * fraction
                                    radius: Config.general.cornerRadius
                                    color: getTempColor(root.cpuTemp)

                                    readonly property real fraction: root.cpuTemp > 0
                                        ? Math.min(root.cpuTemp / 100.0, 1.0)
                                        : 0.0


                                    Behavior on height {
                                        NumberAnimation { duration: 400; easing.type: Easing.InOutQuad }
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
                                    anchors.bottom: parent.bottom
                                    width: parent.width
                                    height: parent.height * fraction
                                    radius: Config.general.cornerRadius
                                    color: getTempColor(root.pchTemp)

                                    readonly property real fraction: root.pchTemp > 0
                                        ? Math.min(root.pchTemp / 100.0, 1.0)
                                        : 0.0


                                    Behavior on height {
                                        NumberAnimation { duration: 400; easing.type: Easing.InOutQuad }
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
                        renderType: Text.NativeRendering
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        Layout.preferredWidth: root.fontSize * 2
                        Layout.preferredHeight: root.fontSize * 2
                    }

                    // status
                    Text {
                        text: root.mail || root.mailErr.slice(root.mailErr - (System.user.length + 4))
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
            sysctl.running = true;
            checkMail.running = true;
        }
    }

    function getTempColor(temp) {
        if (temp > 80) return Config.colors.red;
        if (temp > 50) return Config.colors.yellow;

        return Config.colors.fg;
    }

    function getOsIcon() {
        if (System.id === "freebsd")
            return "󰣠";
        else
            return "󰌽";
    }
}
