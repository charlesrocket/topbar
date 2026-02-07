pragma Singleton

import Quickshell
import QtQuick

import qs

Singleton {
    // check
    readonly property bool settingsAvailable: typeof Settings !== 'undefined'

    // colors
    readonly property color colBg: getSetting("colors.bg", "#aa000000")
    readonly property color colBgE: getSetting("colors.bgE", "#000000")
    readonly property color colFg: getSetting("colors.fg", "#b0b4bc")
    readonly property color colPassive: getSetting("colors.passive", "#4e4e4e")
    readonly property color colDark: getSetting("colors.dark", Qt.darker(colPassive, 1.5))
    readonly property color colAction: getSetting("colors.action", "#0db9d7")
    readonly property color colAccent: getSetting("colors.accent", "#cc0000")
    readonly property color colRed: getSetting("colors.red", "#cc0000")
    readonly property color colYellow: getSetting("colors.yellow", "#ffd700")
    readonly property color colGreen: getSetting("colors.green", "#9ece6a")

    // workspaces
    readonly property string ws01: getSetting("workspaces.one", "")
    readonly property string ws02: getSetting("workspaces.two", "")
    readonly property string ws03: getSetting("workspaces.three", "")
    readonly property string ws04: getSetting("workspaces.four", "")
    readonly property string ws05: getSetting("workspaces.five", "")
    readonly property string ws06: getSetting("workspaces.six", "󰉕")
    readonly property string ws07: getSetting("workspaces.seven", "")
    readonly property string ws08: getSetting("workspaces.eight", "")
    readonly property string ws09: getSetting("workspaces.nine", "")
    readonly property string ws10: getSetting("workspaces.ten", "")

    // general
    readonly property string fontFamily: getSetting("font", "Hack Nerd Font")
    readonly property int fontSize: getSetting("fontSize", 14)
    readonly property int cornerRadius: getSetting("radius", 8)
    readonly property int animDuration: getSetting("duration", 250)
    readonly property int barHeight: getSetting("barHeight", 30)
    readonly property int extraPadding: getSetting("barExtraPadding", 8)
    readonly property string wallpaper: getSetting("wallpaper", States.defaultWallpaper)

    // widgets
    readonly property bool systemTray: getSetting("systemTray", false)
    readonly property bool systemStats: getSetting("systemStats", false)

    // logout commands
    readonly property var logout: QtObject {
        readonly property color background: getSetting("logout.color", "#aa202020")
        readonly property var commands: QtObject {
            readonly property string lock: getSetting("logout.commands.lock", "hyprlock &")
            readonly property string logout: getSetting("logout.commands.logout", "hyprctl dispatch exit | pkill mango")
            readonly property string suspend: getSetting("logout.commands.suspend", "zzz")
            readonly property string hibernate: getSetting("logout.commands.hibernate", "acpiconf -s 4")
            readonly property string shutdown: getSetting("logout.commands.shutdown", "shutdown -p now")
            readonly property string reboot: getSetting("logout.commands.reboot", "shutdown -r now")
        }
    }

    function getSetting(path, defaultValue) {
        if (!settingsAvailable)
            return defaultValue;

        var obj = Settings;
        var parts = path.split('.');

        for (var i = 0; i < parts.length; i++) {
            if (obj === undefined || obj === null)
                return defaultValue;

            obj = obj[parts[i]];
        }

        return obj ?? defaultValue;
    }
}
