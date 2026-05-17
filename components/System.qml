pragma Singleton

import Quickshell
import Quickshell.Io

import QtQuick

import TopBar.System

import ".."

Singleton {
    id: root

    property string id
    property string name
    property string prettyName

    property real cpuTemp: System.cpuTemp
    property real pchTemp: System.pchTemp
    property real cpuUsage: System.cpuUsage
    property real cpuCores: System.cpuCores
    property real diskUsage: System.diskUsage
    property real memoryUsage: System.memoryUsage
    property var jails: System.jails
    property int jailCount: System.jails.length

    property bool ecoMode: States.ecoMode

    onEcoModeChanged: {
        System.interval = ecoMode ? 35000 : 3000;
    }

    readonly property string desktop: Quickshell.env("XDG_CURRENT_DESKTOP").toLowerCase() || Quickshell.env("XDG_SESSION_DESKTOP").toLowerCase()
    readonly property string user: Quickshell.env("USER").toLowerCase()
    readonly property string shell: Quickshell.env("SHELL").split("/").pop().toLowerCase()

    FileView {
        id: os
        path: "/etc/os-release"

        onLoaded: {
            const lines = text().split("\n");
            const fd = key => lines.find(l => l.startsWith(`${key}=`))?.split("=")[1].replace(/"/g, "") ?? "";

            root.name = fd("NAME");
            root.prettyName = fd("PRETTY_NAME");
            root.id = fd("ID");
        }
    }
}
