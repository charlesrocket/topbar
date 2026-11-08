pragma Singleton

import QtQuick

import Quickshell
import Quickshell.Services.UPower
import Quickshell.Wayland

import TopBar.Devd
import TopBar.Mango
import TopBar.System

import qs.core

Singleton {
    id: root

    property var codebergClient: null
    property var githubClient: null
    readonly property Devd dev: Devd
    readonly property bool codebergEnabled: Config.services.codeberg
    readonly property bool githubEnabled: Config.services.github
    readonly property bool systemPollingEnabled: anyBarVisible
                                                 || dashboardPresent
    readonly property string configDisk: Config.bar.dashboard.disk
    readonly property string xdgSession: Quickshell.env("XDG_SESSION_DESKTOP")
    readonly property string xdgDesktop: Quickshell.env("XDG_CURRENT_DESKTOP")
    readonly property string desktop: (xdgSession || xdgDesktop).toLowerCase()
    readonly property bool isMango: desktop === "mango"
    readonly property string user: Quickshell.env("USER").toLowerCase()
    readonly property string shell: Quickshell.env("SHELL").split("/").pop(
                                        ).toLowerCase()
    readonly property string home: Quickshell.env("HOME")
    readonly property string config: Quickshell.env("XDG_CONFIG_HOME")
                                     + "/topbar" || root.home
                                     + "/.config/topbar"
    readonly property bool anyBarVisible: {
        const panels = root.barPanels;
        if (!panels)
            return false;
        for (let i = 0; i < panels.length; i++) {
            const p = panels[i];
            if (p && p.barVisible)
                return true;
        }
        return false;
    }
    property var mangoOutput: null
    property var locale: Qt.locale(Config.general.locale)
    property bool ecoMode: false
    property bool barsLocked: false
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
    readonly property bool hasVisibleWindow: {
        if (root.ecoMode)
            return false;

        if (root.isMango) {
            const outputs = MangoIpc.outputs;
            const output = outputs.find(o => o.active);
            const tag = output?.tags.find(t => t.active);
            return (tag?.clientCount ?? 0) > 0;
        }

        const tls = ToplevelManager.toplevels;
        return !!(tls && tls.values && tls.values.length > 0);
    }
    property var barPanels: []
    property var primaryBarPanel: null
    readonly property var activeBarScreen: {
        const tl = ToplevelManager.activeToplevel;
        if (!tl)
            return null;
        const screens = tl.screens;
        return (screens && screens.length > 0) ? screens[0] : null;
    }
    readonly property var barPanel: {
        const scr = root.activeBarScreen;
        const p = root.barForScreen(scr);
        return p ? p : root.primaryBarPanel;
    }
    // disable for now (we are doing this via nullspace)
    property bool blurredBackground: false
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

    signal osdRequested(string icon, int value, bool muted)

    function registerBarPanel(panel) {
        if (!panel)
            return;
        const current = root.barPanels;
        if (!current)
            return;
        if (current.indexOf(panel) >= 0)
            return;
        root.barPanels = current.concat([panel]);
        if (!root.primaryBarPanel)
            root.primaryBarPanel = panel;
    }

    function unregisterBarPanel(panel) {
        if (!panel)
            return;
        const current = root.barPanels;
        if (!current)
            return;
        const idx = current.indexOf(panel);
        if (idx < 0)
            return;
        const next = current.slice();
        next.splice(idx, 1);
        root.barPanels = next;
        if (root.primaryBarPanel === panel) {
            root.primaryBarPanel = next.length > 0 ? next[0] : null;
        }
    }

    function barForScreen(screen) {
        if (!screen)
            return null;
        const panels = root.barPanels;
        if (!panels)
            return null;
        const n = panels.length;
        for (let i = 0; i < n; i++) {
            const p = panels[i];
            if (p && p.screen && p.screen.name === screen.name)
                return p;
        }
        return null;
    }

    function barForName(name) {
        if (!name)
            return null;
        const panels = root.barPanels;
        if (!panels)
            return null;
        const n = panels.length;
        for (let i = 0; i < n; i++) {
            const p = panels[i];
            if (p && p.screen && p.screen.name === name)
                return p;
        }
        return null;
    }

    function forEachBar(fn) {
        const panels = root.barPanels;
        if (!panels)
            return;
        const n = panels.length;
        if (!n)
            return;
        for (let i = 0; i < n; i++) {
            const p = panels[i];
            if (p)
                fn(p);
        }
    }

    function hideAllBars() {
        root.forEachBar(p => {
            if (p.setBarVisible)
                p.setBarVisible(false);
        });
    }

    function revealAllBars() {
        root.forEachBar(p => {
            if (p.setBarVisible)
                p.setBarVisible(true);
        });
    }

    function barNames() {
        const out = [];
        root.forEachBar(p => {
            if (p.screen && p.screen.name)
                out.push(p.screen.name);
        });
        return out.join(",");
    }

    function requestOsd(icon, value, muted) {
        if (!Config.desktop.osd)
            return;
        root.osdRequested(icon, value, muted);
    }

    function updateMangoState() {
        if (!root.isMango) {
            root.mangoOutput = null;
            return;
        }

        const outputs = MangoIpc.outputs;
        root.mangoOutput = outputs.length > 0 ? outputs[0] : null;
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
    onDashboardPresentChanged: root.uptime = System.uptime()
    onFullScreenChanged: ecoMode = fullScreen
    Component.onCompleted: root.updateMangoState()

    Connections {
        function onOutputsChanged() {
            root.updateMangoState();
        }

        target: root.isMango ? MangoIpc : null
    }

    Connections {
        function onValuesChanged() {
            root.hasVisibleWindowChanged?.();
        }

        target: ToplevelManager.toplevels
    }

    Binding {
        target: System
        property: "pollingEnabled"
        value: States.systemPollingEnabled
        restoreMode: Binding.RestoreNone
    }
}
