import QtQuick
import QtQuick.Layouts

import ".."

RowLayout {
    id: root
    spacing: 6

    property int fontSize: Config.general.fontSize
    property color colBar: Config.colors.dark
    property color colWarning: Config.colors.yellow
    property color colCritical: Config.colors.red
    property color colFg: Config.colors.fg
    property string mountPoint: "/"
    property int barWidth: 8
    property int barHeight: 14

    RowLayout {
        spacing: 6

        Text {
            text: ""
            color: root.colFg
            font.family: "Symbols Nerd Font"
            font.pixelSize: root.fontSize
            font.bold: true
        }

        Rectangle {
            Layout.preferredWidth: root.barWidth
            Layout.preferredHeight: root.barHeight
            color: root.colBar
            border.width: 1
            border.color: Qt.darker(root.colFg, 1.5)
            radius: 2

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 1
                height: System.cpuUsage * (parent.height - 2)
                radius: 1

                color: {
                    const pct = System.cpuUsage;

                    if (pct > 0.90)
                        return root.colCritical;
                    if (pct > 0.75)
                        return root.colWarning;

                    return root.colFg;
                }

                Behavior on height {
                    NumberAnimation {
                        duration: 250
                    }
                }
            }
        }
    }

    RowLayout {
        spacing: 6

        Text {
            text: "󰚗"
            color: root.colFg
            font.family: "Symbols Nerd Font"
            font.pixelSize: root.fontSize
            font.bold: true
        }

        Rectangle {
            Layout.preferredWidth: root.barWidth
            Layout.preferredHeight: root.barHeight
            color: root.colBar
            border.width: 1
            border.color: Qt.darker(root.colFg, 1.5)
            radius: 2

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 1
                height: System.memoryUsage * (parent.height - 2)
                radius: 1

                color: {
                    const pct = System.memoryUsage;

                    if (pct > 0.90)
                        return root.colCritical;
                    if (pct > 0.75)
                        return root.colWarning;

                    return root.colFg;
                }

                Behavior on height {
                    NumberAnimation {
                        duration: 250
                    }
                }
            }
        }
    }

    RowLayout {
        spacing: 6

        Text {
            text: ""
            color: root.colFg
            font.family: "Symbols Nerd Font"
            font.pixelSize: root.fontSize
            font.bold: true
        }

        Rectangle {
            Layout.preferredWidth: root.barWidth
            Layout.preferredHeight: root.barHeight
            color: root.colBar
            border.width: 1
            border.color: Qt.darker(Config.colors.fg, 1.5)
            radius: 2

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 1
                height: System.diskUsage * (parent.height - 2)
                radius: 1

                color: {
                    const pct = System.diskUsage;

                    if (pct > 0.90)
                        return root.colCritical;
                    if (pct > 0.80)
                        return root.colWarning;

                    return root.colFg;
                }

                Behavior on height {
                    NumberAnimation {
                        duration: 250
                    }
                }
            }
        }
    }
}
