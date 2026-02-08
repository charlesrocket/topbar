import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Layouts

import "../.."

Item {
    id: root

    property int slideDuration: Config.animDuration
    property color colMain: Config.colFg
    property color colButton: Config.colAccent
    property color colGreen: Config.colGreen
    property color colPurple: Config.colPurple
    property string fontFamily: "FiraCode Nerd Font"
    property int fontSize: 14

    Layout.alignment: Qt.AlignVCenter
    implicitWidth: (hoverDetector.containsMouse ? dateContainer.width + 8 : 0) + clockText.width
    implicitHeight: clockText.height

    Behavior on implicitWidth {
        NumberAnimation {
            duration: root.slideDuration
            easing.type: Easing.OutCubic
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Process {
        id: hyprctlReload
        command: ["hyprctl", "reload", "--quiet"]
        Component.onCompleted: running = false
    }

    Process {
        id: hyprctlBatch
        command: ["hyprctl", "--quiet", "--batch", "keyword animations:enabled false;keyword decoration:blur:enabled false;keyword decoration:shadow:enabled false;"]
        Component.onCompleted: running = false
    }

    Process {
        id: notify
        Component.onCompleted: running = false
    }

    function toggleEcoMode() {
        States.ecoMode = !States.ecoMode;

        if (States.ecoMode) {
            hyprctlBatch.running = true;
            notify.command = ["notify-send", "-u", "low", "ECO MODE", "ON", "--icon=dialog-information-symbolic"];
        } else {
            hyprctlReload.running = true;
            notify.command = ["notify-send", "-u", "low", "ECO MODE", "OFF", "--icon=dialog-information-symbolic"];
        }

        notify.running = true;
    }

    function toggleAwakeMode() {
        States.keepAwake = !States.keepAwake;

        if (States.keepAwake) {
            notify.command = ["notify-send", "-u", "low", "AWAKE MODE", "ON", "--icon=dialog-information-symbolic"];
        } else {
            notify.command = ["notify-send", "-u", "low", "AWAKE MODE", "OFF", "--icon=dialog-information-symbolic"];
        }

        notify.running = true;
    }

    RowLayout {
        id: dateContainer
        anchors.right: clockContainer.left
        anchors.rightMargin: hoverDetector.containsMouse ? 8 : 0
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10
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
            id: dateText
            text: ""
            color: root.colMain

            font {
                family: root.fontFamily
                pixelSize: root.fontSize - 1
                bold: true
            }
        }

        Text {
            id: ecoBtn
            text: States.ecoMode ? "󰌪" : "󱋙"
            color: States.ecoMode ? root.colGreen : root.colMain
            Layout.bottomMargin: 2

            font {
                family: "Symbols Nerd Font"
                pixelSize: root.fontSize + 1
                bold: true
            }

            Behavior on color {
                ColorAnimation {
                    duration: Config.animDuration
                    easing.type: Easing.OutCubic
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.toggleEcoMode()
            }
        }

        Text {
            id: coffeeBtn
            text: States.keepAwake ? "󰅶" : "󰾪"
            color: States.keepAwake ? root.colPurple : root.colMain
            Layout.bottomMargin: 2

            font {
                family: "Symbols Nerd Font"
                pixelSize: root.fontSize + 1
                bold: true
            }

            Behavior on color {
                ColorAnimation {
                    duration: Config.animDuration
                    easing.type: Easing.OutCubic
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.toggleAwakeMode()
            }
        }

        Text {
            id: powerBtn
            text: ""
            color: root.colButton
            Layout.bottomMargin: 2

            font {
                family: "Symbols Nerd Font"
                pixelSize: root.fontSize + 1
                bold: true
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    States.logoutPresent = true;
                }
            }
        }
    }

    Item {
        id: clockContainer
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: clockText.width
        height: clockText.height

        Text {
            id: clockText
            anchors.centerIn: parent
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: root.colMain

            font {
                family: root.fontFamily
                pixelSize: root.fontSize - 1
                bold: true
            }
        }
    }

    Connections {
        target: hoverDetector

        function onContainsMouseChanged() {
            if (hoverDetector.containsMouse) {
                dateText.text = Qt.formatDateTime(clock.date, "ddd dd MMMM yyyy");
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
