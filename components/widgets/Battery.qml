import QtQuick

import Quickshell.Services.UPower

import qs
import qs.core

Item {
    id: root

    property color colMain: Config.colors.fg
    property color colCharging: Config.colors.yellow
    property color colGood: Config.colors.green
    property color colBad: Config.colors.red
    property color colBg: Config.colors.dark
    property int slideDuration: Config.general.animDuration
    property int fontSize: Config.general.fontSize
    property var fontFamily: "Hack Nerd Font"

    function secondsToHhMm(seconds) {
        var date = new Date(0, 0, 0, 0, 0, seconds);
        return Qt.formatTime(date, "hh:mm");
    }

    function batteryInfo() {
        if (States.battery.isDischarging)
            return "󱐋 " + States.battery.percentage + "% " + secondsToHhMm(
                        States.battery.device.timeToEmpty);
        if (States.battery.isCharging)
            return "󱐋 " + States.battery.percentage + "% " + secondsToHhMm(
                        States.battery.device.timeToFull);
        if (States.battery.isFullyCharged || States.battery.isEmpty)
            return "󱐋 " + States.battery.percentage + "% " + Math.round(
                        States.battery.device.energyCapacity) + " Wh";
    }

    implicitWidth: (hoverDetector.containsMouse ? infoContainer.width + 8 : 0)
                   + battText.width
    implicitHeight: battText.height

    Behavior on implicitWidth {
        NumberAnimation {
            duration: root.slideDuration
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        id: infoContainer

        anchors.right: battContainer.left
        anchors.rightMargin: hoverDetector.containsMouse ? 8 : 0
        width: infoText.contentWidth + 10
        height: infoText.contentHeight
        color: root.colBg
        radius: 6
        opacity: hoverDetector.containsMouse ? 1 : 0
        scale: hoverDetector.containsMouse ? 1 : 0
        transformOrigin: Item.Right
        visible: opacity > 0

        Behavior on anchors.rightMargin {
            NumberAnimation {
                duration: root.slideDuration
                easing.type: Easing.OutCubic
            }
        }
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

        Text {
            id: infoText

            anchors.centerIn: parent
            text: ""
            color: root.colMain

            font {
                family: root.fontFamily
                pixelSize: root.fontSize - 2
                bold: true
            }
        }
    }

    Item {
        id: battContainer

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: battText.width
        height: battText.height

        Text {
            id: battText

            visible: UPower.onBattery || States.battery.isCharging
                     || States.battery.isDischarging || States.battery.isEmpty
                     || States.battery.isFullyCharged
            text: States.battery.device?.ready ? `${States.battery.getIcon()}` :
                                                 ""
            color: {
                if (States.battery.isCharging)
                    return root.colCharging;
                if (States.battery.percentage >= 90)
                    return root.colGood;
                if (States.battery.percentage <= 34 || root.isEmpty)
                    return root.colBad;
                return root.colMain;
            }

            Behavior on color {
                ColAnim {}
            }

            font {
                family: "Symbols Nerd Font"
                pixelSize: root.fontSize
                bold: true
            }
        }
    }

    Connections {
        function onContainsMouseChanged() {
            if (hoverDetector.containsMouse) {
                infoText.text = `${root.batteryInfo()}`;
            }
        }

        target: hoverDetector
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
