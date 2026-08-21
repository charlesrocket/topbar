import QtQuick
import QtQuick.Layouts

import qs.core

RowLayout {
    id: root

    property int fontSize: Config.appearance.fontSize
    property color colBar: Config.colors.dark
    property color colWarning: Config.colors.yellow
    property color colCritical: Config.colors.red
    property color colFg: Config.colors.fg
    property string mountPoint: "/"
    property int barWidth: 8
    property int barHeight: 14

    spacing: 6

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
                height: States.cpuUsage * (parent.height - 2)
                radius: 1
                color: {
                    const pct = States.cpuUsage;

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
                height: States.memoryUsage * (parent.height - 2)
                radius: 1
                color: {
                    const pct = States.memoryUsage;

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
                height: States.diskUsage * (parent.height - 2)
                radius: 1
                color: {
                    const pct = States.diskUsage;

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
