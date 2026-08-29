pragma Singleton

import QtQuick

import Quickshell
import Quickshell.Services.UPower
import Quickshell.Wayland
import TopBar.DWL

import TopBar.Devd
import TopBar.System

import qs.core

Singleton {
    id: root

    property var codebergClient: null
    property var githubClient: null
    readonly property Devd dev: Devd
    readonly property bool codebergEnabled: Config.services.codeberg
    readonly property bool githubEnabled: Config.services.github
    readonly property string configDisk: Config.bar.dashboard.disk
    readonly property string desktop: Quickshell.env(
                                          "XDG_CURRENT_DESKTOP").toLowerCase()
                                      || Quickshell.env(
                                          "XDG_SESSION_DESKTOP").toLowerCase()
    readonly property string user: Quickshell.env("USER").toLowerCase()
    readonly property string shell: Quickshell.env("SHELL").split("/").pop(
                                        ).toLowerCase()
    readonly property string home: Quickshell.env("HOME")
    readonly property string config: Quickshell.env("XDG_CONFIG_HOME")
                                     + "/topbar" || root.home
                                     + "/.config/topbar"
    property PanelWindow barPanel: null
    property DwlIpcOutput dwlOutput: DwlIpc.outputs.length > 0
                                     ? DwlIpc.outputs[0] : null
    property var locale: Qt.locale(Config.general.locale)
    property bool barEnabled: true
    property bool ecoMode: false
    property bool sessionPresent: false
    property bool keepAwake: false
    property bool settingsPresent: false
    property bool launcherPresent: false
    property bool dashboardPresent: false
    property bool dropdownRevealed: false
    property Item dropdownOwner: null
    property int dropdownX: 0
    property int dropdownY: 0
    property int dropdownHeight: 0
    property int dropdownWidth: 0
    property bool fullScreen: ToplevelManager.activeToplevel
                              ? ToplevelManager.activeToplevel.fullscreen :
                                false
    property bool blurredBackground: {
        const output = DwlIpc.outputs.find(o => o.active);
        const activeTag = output?.tags.find(tag => tag.active);
        const hasClients = (activeTag?.clientCount ?? 0) > 0;
        return hasClients || (hasClients && !ecoMode);
    }

    // TODO add local
    property string defaultWallpaper:
        "https://codeberg.org/charlesrocket/misc-files/raw/branch/trunk/puffy-red.png"
    property string osId
    property string osName
    property string osPrettyName
    property string userName
    property real cpuTemp: System.cpuTemp
    property real pchTemp: System.pchTemp
    property real cpuUsage: System.cpuUsage
    property real cpuCores: System.cpuCores
    property real diskUsage: System.diskUsage
    property string diskMountPoint: System.diskMountPoint
    property real memoryUsage: System.memoryUsage
    property real cpu: System.cpu
    property real gpu: System.gpu
    property real mem: System.installedMemory
    property var jails: System.jails
    property int jailCount: System.jails.length
    property string uptime: "00:00"
    property QtObject battery: QtObject {
        readonly property var device: UPower.displayDevice
        readonly property int percentage: device?.ready ? Math.round(
                                                              device.percentage
                                                              * 100) : 0
        readonly property bool isCharging: device?.state === 1
        readonly property bool isDischarging: device?.state === 2
        readonly property bool isEmpty: device?.state === 3
        readonly property bool isFullyCharged: device?.state === 4

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
    }

    function getOsIcon() {
        if (root.osId === "freebsd")
            return "󰣠";
        else if (root.osName.toLowerCase().includes("linux"))
            return "󰌽";
        else
            return "";
    }

    function updateUptime() {
        root.uptime = System.uptime();
    }

    function changeUserIcon(path) {
        System.setUserIcon(path);
    }

    onConfigDiskChanged: System.setDiskMountPoint(configDisk)
    onEcoModeChanged: System.interval = ecoMode ? 35000 : 3000
    onDashboardPresentChanged: {
        root.uptime = System.uptime();
    }
    onFullScreenChanged: {
        ecoMode = fullScreen;
    }
}
