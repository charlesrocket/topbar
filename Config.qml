pragma Singleton

import Quickshell
import QtQuick

import qs

Singleton {
    // check
    readonly property bool settingsAvailable: typeof Settings !== 'undefined'

    // general
    property var general: QtObject {
        // see https://doc.qt.io/qt-6/qlocale.html
        property string locale: getSetting("general.locale", "AnyTerritory")
        property string fontFamily: getSetting("general.font", "Hack Nerd Font")
        property int fontSize: getSetting("general.fontSize", 14)
        property int borderWidth: getSetting("general.borderWidth", 0)
        property int cornerRadius: getSetting("general.radius", 8)
        property int animDuration: getSetting("general.animDuration", 250)
        property string wallpaper: getSetting("general.wallpaper", States.defaultWallpaper)
        property bool blur: getSetting("general.blur", true)
        property bool shadows: getSetting("general.shadows", true)
    }

    // colors
    property var colors: QtObject {
        property color bg: getSetting("colors.bg", "#aa000000")
        property color bgl: getSetting("colors.bgl", "#80404040")
        property color bge: getSetting("colors.bge", "#000000") // eco mode
        property color fg: getSetting("colors.fg", "#b0b4bc")
        property color border: getSetting("colors.border", "#aa4e4e4e")
        property color passive: getSetting("colors.passive", "#4e4e4e")
        property color dark: getSetting("colors.dark", Qt.darker(passive, 1.5))
        property color extraDark: getSetting("colors.extraDark", Qt.darker(dark, 1.2))
        property color action: getSetting("colors.action", "#0db9d7")
        property color accent: getSetting("colors.accent", "#cc0000")
        property color red: getSetting("colors.red", "#cc0000")
        property color yellow: getSetting("colors.yellow", "#ffd700")
        property color purple: getSetting("colors.purple", "#bf00ff")
        property color green: getSetting("colors.green", "#9ece6a")
    }

    // bar
    property var bar: QtObject {
        property int height: getSetting("bar.height", 30)
        // should be in sync with the compositor's (outer) gaps
        property int padding: getSetting("bar.padding", 8)

        property var title: QtObject {
            property int width: getSetting("bar.title.width", 400)
            property string empty: getSetting("bar.title.empty", "")
        }
    }

    property var desktop: QtObject {
        property bool launcher: getSetting("desktop.launcher", true)
        property bool osd: getSetting("desktop.osd", false)
    }

    property var dashboard: QtObject {
        property string disk: getSetting("dashboard.disk", "/")

        property var player: QtObject {
            property bool queueButtons: getSetting("dashboard.player.queueButtons", false)
            property bool notifications: getSetting("dashboard.player.notifications", false)
        }
    }

    property var notifications: QtObject {
        property bool enabled: getSetting("notifications.enabled", true)
        property int width: getSetting("notifications.width", 300)
    }

    // widgets
    property var widgets: QtObject {
        property bool workspaces: getSetting("widgets.workspaces", true)
        property bool title: getSetting("widgets.title", true)
        property bool stats: getSetting("widgets.stats", false)
        property bool audio: getSetting("widgets.audio", true)
        property bool bluetooth: getSetting("widgets.bluetooth", false)
        property bool network: getSetting("widgets.network", false)
        property bool tray: getSetting("widgets.tray", false)
        property bool jails: getSetting("widgets.jails", true)
        property bool weather: getSetting("widgets.weather", true)
        property bool language: getSetting("widgets.language", false)
        property bool clock: getSetting("widgets.clock", true)
        property bool battery: getSetting("widgets.battery", true)
    }

    // lockscreen
    property var lockscreen: QtObject {
        property string wallpaper: getSetting("lockscreen.wallpaper", States.defaultWallpaper)
        property bool buttons: getSetting("lockscreen.buttons", true)
        property bool clock: getSetting("lockscreen.clock", true)
        property bool battery: getSetting("lockscreen.battery", true)
        property bool shadows: getSetting("lockscreen.shadows", true)
        property bool username: getSetting("lockscreen.username", true) // full name
        property bool icon: getSetting("lockscreen.icon", true) // user icon
    }

    // session
    property var session: QtObject {
        property color background: getSetting("session.background", "#aa202020")

        property var commands: QtObject {
            property string lock: getSetting("session.commands.lock", "quickshell -c topbar ipc call bar lock")
            property string logout: getSetting("session.commands.logout", "pkill mango | hyprctl dispatch exit")
            property string suspend: getSetting("session.commands.suspend", "zzz")
            property string hibernate: getSetting("session.commands.hibernate", "acpiconf -s 4")
            property string shutdown: getSetting("session.commands.shutdown", "shutdown -p now")
            property string reboot: getSetting("session.commands.reboot", "shutdown -r now")
        }
    }

    // workspaces
    property var workspaces: QtObject {
        property string one: getSetting("workspaces.one", "1")
        property string two: getSetting("workspaces.two", "2")
        property string three: getSetting("workspaces.three", "3")
        property string four: getSetting("workspaces.four", "4")
        property string five: getSetting("workspaces.five", "5")
        property string six: getSetting("workspaces.six", "6")
        property string seven: getSetting("workspaces.seven", "7")
        property string eight: getSetting("workspaces.eight", "8")
        property string nine: getSetting("workspaces.nine", "9")
        property string ten: getSetting("workspaces.ten", "0")
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
