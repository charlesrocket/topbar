pragma Singleton

import Quickshell
import Quickshell.Io

import QtQuick

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

    property real cpuTemp: System.cpuTemp
    property real pchTemp: System.pchTemp
    property real cpuUsage: System.cpuUsage
    property real cpuCores: System.cpuCores
    property real diskUsage: System.diskUsage
    property string diskMountPoint: System.diskMountPoint
    property real memoryUsage: System.memoryUsage
    property var jails: System.jails
    property int jailCount: System.jails.length

    property bool ecoMode: States.ecoMode
    property string configDisk: Config.dashboard.disk

    onConfigDiskChanged: System.setDiskMountPoint(configDisk)
    onEcoModeChanged: System.interval = ecoMode ? 35000 : 3000

    readonly property string desktop: Quickshell.env("XDG_CURRENT_DESKTOP").toLowerCase() || Quickshell.env("XDG_SESSION_DESKTOP").toLowerCase()
    readonly property string user: Quickshell.env("USER").toLowerCase()
    readonly property string shell: Quickshell.env("SHELL").split("/").pop().toLowerCase()
    readonly property string home: Quickshell.env("HOME")
    readonly property string config: Quickshell.env("XDG_CONFIG_HOME")
                                     + "/topbar" || root.home
                                     + "/.config/topbar"


    FileView {
        id: os
        path: "/etc/os-release"

        onLoaded: {
            const lines = text().split("\n");
            const fd = key => lines.find(l => l.startsWith(`${key}=`))?.split("=")[1].replace(/"/g, "") ?? "";

            root.osName = fd("NAME");
            root.osPrettyName = fd("PRETTY_NAME");
            root.osId = fd("ID");
        }
    }
}
