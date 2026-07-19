pragma Singleton

import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower

import TopBar.DWL

import QtQuick

Singleton {
    property PanelWindow barPanel: null
    property DwlIpcOutput dwlOutput: DwlIpc.outputs.length > 0 ? DwlIpc.outputs[0] : null

    property var locale: Qt.locale(Config.general.locale)
    property bool barEnabled: true
    property bool ecoMode: false

    property bool sessionPresent: false
    property bool keepAwake: false

    property bool preferencesWindowPresent: false
    property bool launcherPresent: false
    property bool dashboardPresent: false

    property bool dropdownRevealed: false
    property var dropdownOwner: null
    property int dropdownX: 0
    property int dropdownY: 0
    property int dropdownHeight: 0
    property int dropdownWidth: 0

    property bool fullScreen: ToplevelManager.activeToplevel ? ToplevelManager.activeToplevel.fullscreen : false

    property bool blurredBackground: {
        const output = DwlIpc.outputs.find(o => o.active);
        const activeTag = output?.tags.find(tag => tag.active);
        const hasClients = (activeTag?.clientCount ?? 0) > 0;
        return hasClients || (hasClients && !ecoMode);
    }

    onFullScreenChanged: {
        ecoMode = fullScreen;
    }

    // TODO add local
    property string defaultWallpaper: "https://codeberg.org/charlesrocket/misc-files/raw/branch/trunk/puffy-red.png"

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
