import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io

import qs

Item {
    id: root

    property int slideDuration: Config.general.animDuration
    property color colMain: Config.colors.fg
    property color colButton: Config.colors.accent
    property color colGreen: Config.colors.green
    property color colPurple: Config.colors.purple
    property string fontFamily: "FiraCode Nerd Font"
    property int fontSize: Config.general.fontSize

    function toggleEcoMode() {
        States.ecoMode = !States.ecoMode;

        if (States.ecoMode) {
            hyprctlBatch.running = true;
            notify.command = ["notify-send", "-u", "low", "ECO MODE ON"];
        } else {
            hyprctlReload.running = true;
            notify.command = ["notify-send", "-u", "low", "ECO MODE OFF"];
        }

        notify.running = true;
    }

    function toggleAwakeMode() {
        States.keepAwake = !States.keepAwake;

        if (States.keepAwake) {
            notify.command = ["notify-send", "-u", "low", "AWAKE MODE ON"];
        } else {
            notify.command = ["notify-send", "-u", "low", "AWAKE MODE OFF"];
        }

        notify.running = true;
    }

    Layout.alignment: Qt.AlignVCenter
    implicitWidth: (hoverDetector.hovered ? dateContainer.width + 8 : 0)
                   + clockText.width
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

        command: ["hyprctl", "--quiet", "--batch",
            "keyword animations:enabled false;keyword decoration:blur:enabled false;keyword decoration:shadow:enabled false;"]

        Component.onCompleted: running = false
    }

    Process {
        id: notify

        Component.onCompleted: running = false
    }

    RowLayout {
        id: dateContainer

        anchors.right: clockContainer.left
        anchors.rightMargin: hoverDetector.hovered ? 8 : 0
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10
        opacity: hoverDetector.hovered ? 1 : 0
        scale: hoverDetector.hovered ? 1 : 0
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

            Behavior on color {
                ColAnim {}
            }

            font {
                family: "Symbols Nerd Font"
                pixelSize: root.fontSize + 1
                bold: true
            }

            TapHandler {
                onTapped: root.toggleEcoMode()
            }
        }

        Text {
            id: coffeeBtn

            text: States.keepAwake ? "󰅶" : "󰾪"
            color: States.keepAwake ? root.colPurple : root.colMain
            Layout.bottomMargin: 2

            Behavior on color {
                ColAnim {}
            }

            font {
                family: "Symbols Nerd Font"
                pixelSize: root.fontSize + 1
                bold: true
            }

            TapHandler {
                onTapped: root.toggleAwakeMode()
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

            TapHandler {
                onTapped: States.sessionPresent = true
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
        function onHoveredChanged() {
            if (hoverDetector.hovered) {
                dateText.text = Qt.formatDateTime(clock.date,
                                                  "ddd dd MMMM yyyy");
            }
        }

        target: hoverDetector
    }

    HoverHandler {
        id: hoverDetector
    }
}
