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
        Layout.topMargin: 100
        Layout.alignment: Qt.AlignHCenter

        Text {
            color: Config.colors.fg
            font.family: Config.appearance.fontFamily
            font.pixelSize: Config.appearance.fontSize * 2
            font.bold: true
            text: "TopBar"
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter

        Rectangle {
            border.width: 1
            border.color: Config.colors.passive
            color: "transparent"
            implicitWidth: versionString.width + 12
            implicitHeight: versionString.height + 6
            radius: Config.appearance.cornerRadius

            TextEdit {
                id: versionString

                anchors.centerIn: parent
                text: Version.full
                font.family: Config.appearance.fontFamily
                font.pixelSize: Config.appearance.fontSize
                font.bold: false
                color: Config.colors.fg
                readOnly: true
                selectByMouse: true
            }
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter

        Text {
            color: Config.colors.fg
            verticalAlignment: Qt.AlignVCenter
            visible: Version.distributor != "Unset"
            font.family: Config.appearance.fontFamily
            font.pixelSize: Config.appearance.fontSize * 1.2
            font.bold: false
            font.italic: true
            text: Version.distributor
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter

        Text {
            color: Config.colors.fg
            font.family: Config.appearance.fontFamily
            font.pixelSize: Config.appearance.fontSize - 1
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
            font.family: Config.appearance.fontFamily
            font.pixelSize: Config.appearance.fontSize - 1
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
            font.family: Config.appearance.fontFamily
            font.pixelSize: Config.appearance.fontSize - 1
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
