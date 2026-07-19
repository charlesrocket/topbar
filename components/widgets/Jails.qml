pragma ComponentBehavior: Bound

import QtQuick
import QtQml

import ".."

Item {
    id: root

    property color colMain: Config.colors.fg
    property color colBg: "transparent"
    property color colBorder: Config.colors.purple
    property int slideDuration: Config.general.animDuration
    property int fontSize: Config.general.fontSize
    property string fontFamily: "FiraCode Nerd Font"
    property string icon: "󰆧"
    property var jails: System.jails
    property int jailCount: jails.length

    implicitWidth: (hoverDetector.containsMouse ? infoContainer.width + 8 : 0) + jailText.width
    implicitHeight: jailText.height

    onJailsChanged: flashAnimation.restart()

    SequentialAnimation {
        id: flashAnimation

        ColorAnimation {
            target: jailText
            property: "color"
            to: Config.colors.purple
            duration: 150
            easing.type: Easing.OutCubic
        }

        ColorAnimation {
            target: jailText
            property: "color"
            to: root.colMain
            duration: 600
            easing.type: Easing.InCubic
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: root.slideDuration
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        id: infoContainer
        anchors.right: jailContainer.left
        anchors.rightMargin: hoverDetector.containsMouse ? 8 : 0
        anchors.verticalCenter: parent.verticalCenter
        width: infoText.contentWidth + 10
        height: infoText.contentHeight + 2
        color: root.colBg
        radius: 6
        border.width: 1
        border.color: root.colBorder
        opacity: hoverDetector.containsMouse ? 1 : 0
        scale: hoverDetector.containsMouse ? 1 : 0
        transformOrigin: Item.Right
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: root.slideDuration
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: root.slideDuration
                easing.type: Easing.OutCubic
            }
        }

        Behavior on anchors.rightMargin {
            NumberAnimation {
                duration: root.slideDuration
                easing.type: Easing.OutCubic
            }
        }

        Text {
            id: infoText
            anchors.centerIn: parent
            anchors.verticalCenter: parent.verticalCenter
            text: root.jailCount
            color: root.colMain

            font {
                family: root.fontFamily
                pixelSize: root.fontSize - 1
                bold: true
            }
        }
    }

    Item {
        id: jailContainer
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: jailText.width
        height: jailText.height

        Text {
            id: jailText

            text: root.icon
            color: root.colMain
            font.bold: true

            font {
                family: "Symbols Nerd Font"
                pixelSize: root.fontSize + 1
                bold: true
            }
        }
    }

    MouseArea {
        id: hoverDetector
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true

        onPressed: function (mouse) {
            mouse.accepted = false;
        }
    }
}
