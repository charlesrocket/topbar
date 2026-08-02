import QtQuick
import QtQuick.Layouts

import TopBar

import qs.core

ColumnLayout {
    id: root

    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 8

    RowLayout {
        Text {
            color: Config.colors.fg
            verticalAlignment: Qt.AlignVCenter
            font.family: Config.general.fontFamily
            font.pixelSize: Config.general.fontSize * 2
            font.bold: true
            text: "TopBar"
        }

        Text {
            color: Config.colors.fg
            font.family: Config.general.fontFamily
            font.pixelSize: Config.general.fontSize * 2
            font.bold: true
            text: Version.major + "." + Version.minor
        }
    }

    Text {
        color: Config.colors.fg
        verticalAlignment: Qt.AlignVCenter
        visible: Version.distributor != "Unset"
        font.family: Config.general.fontFamily
        font.pixelSize: Config.general.fontSize * 1.2
        font.bold: false
        font.italic: true
        text: Version.distributor
    }

    RowLayout {
        Text {
            color: Config.colors.fg
            font.family: Config.general.fontFamily
            font.pixelSize: Config.general.fontSize - 1
            font.bold: false
            text: '<a href="https://codeberg.org/charlesrocket/topbar">homepage'
            textFormat: Text.RichText

            onLinkActivated: link => Qt.openUrlExternally(link)

            MouseArea {
                anchors.fill: parent
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor :
                                                  Qt.ArrowCursor
                acceptedButtons: Qt.NoButton
            }
        }

        Text {
            color: Config.colors.fg
            font.family: Config.general.fontFamily
            font.pixelSize: Config.general.fontSize - 1
            font.bold: false
            text: '<a href="https://codeberg.org/charlesrocket/topbar/issues">issues'
            textFormat: Text.RichText

            onLinkActivated: link => Qt.openUrlExternally(link)

            MouseArea {
                anchors.fill: parent
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor :
                                                  Qt.ArrowCursor
                acceptedButtons: Qt.NoButton
            }
        }

        Text {
            color: Config.colors.fg
            font.family: Config.general.fontFamily
            font.pixelSize: Config.general.fontSize - 1
            font.bold: false
            text: '<a href="https://codeberg.org/charlesrocket/topbar/raw/branch/trunk/LICENSE">license'
            textFormat: Text.RichText

            onLinkActivated: link => Qt.openUrlExternally(link)

            MouseArea {
                anchors.fill: parent
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor :
                                                  Qt.ArrowCursor
                acceptedButtons: Qt.NoButton
            }
        }
    }
}
