pragma Singleton

import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower

import QtQuick

Singleton {
    property PanelWindow barPanel: null
    property var locale: Qt.locale(Config.general.locale)
    property bool barEnabled: true
    property bool ecoMode: false
    property bool preferencesWindowPresent: false
    property bool launcherPresent: false
    property bool sessionPresent: false
    property bool keepAwake: false
    property bool dashboardPresent: false
    property bool dropdownRevealed: false
    property bool blurredBackground: ToplevelManager.activeToplevel && !ecoMode ? true : false
    property var dropdownOwner: null
    property int dropdownX: 0
    property int dropdownY: 0
    property int dropdownHeight: 0
    property int dropdownWidth: 0

    // TODO add local
    property string defaultWallpaper: "https://raw.githubusercontent.com/charlesrocket/misc-files/trunk/puffy-red.png"

    property var battery: QtObject {
        function getIcon(batteryPercentage) {
            if (isCharging || isFullyCharged) {
                if (percentage == 100)
                    return "󰂅";
                if (percentage >= 90)
                    return "󰂋";
                if (percentage >= 80)
                    return "󰂊";
                if (percentage >= 70)
                    return "󰢞";
                if (percentage >= 60)
                    return "󰂉";
                if (percentage >= 50)
                    return "󰢝";
                if (percentage >= 40)
                    return "󰂈";
                if (percentage >= 30)
                    return "󰂇";
                if (percentage >= 20)
                    return "󰂆";
                return "󰢜";
            } else {
                if (percentage == 100)
                    return "󰁹";
                if (percentage >= 90)
                    return "󰂂";
                if (percentage >= 80)
                    return "󰂁";
                if (percentage >= 70)
                    return "󰂀";
                if (percentage >= 60)
                    return "󰁿";
                if (percentage >= 50)
                    return "󰁾";
                if (percentage >= 40)
                    return "󰁽";
                if (percentage >= 30)
                    return "󰁼";
                if (percentage >= 20)
                    return "󰁻";
                return "󰁺";
            }
        }

        readonly property var device: UPower.displayDevice
        readonly property int percentage: device?.ready ? Math.round(device.percentage * 100) : 0
        readonly property bool isCharging: device?.state === 1
        readonly property bool isDischarging: device?.state === 2
        readonly property bool isEmpty: device?.state === 3
        readonly property bool isFullyCharged: device?.state === 4
    }
}
