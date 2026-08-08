pragma Singleton

import QtQuick

import Quickshell
import Quickshell.Io

import TopBar
import TopBar.Devd
import TopBar.System

Singleton {
    id: root

    readonly property string version: Version.full
    readonly property Devd dev: Devd
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
    property var cpu: System.cpu
    property var gpu: System.gpu
    property var mem: System.installedMemory
    property var jails: System.jails
    property int jailCount: System.jails.length
    property string uptime: "00:00"
    readonly property bool ecoMode: States.ecoMode
    readonly property string configDisk: Config.dashboard.disk
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

    Process {
        running: true
        command: ["sh", "-c", "getent passwd " + root.user]

        stdout: StdioCollector {
            onStreamFinished: {
                var parts = this.text.split(":");

                if (parts.length >= 5) {
                    root.userName = parts[4].trim();
                }
            }
        }
    }

    FileView {
        id: os

        path: "/etc/os-release"

        onLoaded: {
            const lines = text().split("\n");
            const fd = key => lines.find(l => l.startsWith(`${key}=`))?.split(
                                  "=")[1].replace(/"/g, "") ?? "";

            root.osName = fd("NAME");
            root.osPrettyName = fd("PRETTY_NAME");
            root.osId = fd("ID");
        }
    }
}
