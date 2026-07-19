pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Io

import QtQuick

Singleton {
    id: root

    readonly property string path: Quickshell.env("HOME") + "/.config/topbar/settings.json"

    FileView {
        id: fileView
        path: root.path
        watchChanges: Config.general.configWatch
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()

        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                writeAdapter();
        }

        JsonAdapter {
            id: settings

            // general
            property JsonObject general: JsonObject {
                property string locale: "AnyTerritory"
                property string fontFamily: "Hack Nerd Font"
                property int fontSize: 14
                property int borderWidth: 0
                property int cornerRadius: 8
                property int animDuration: 250
                property string wallpaper: States.defaultWallpaper
                property bool blur: true
                property bool shadows: true
                property bool configWatch: true

            }

            // colors
            property JsonObject colors: JsonObject {
                property string bg: "#aa000000"
                property string bgl: "#80404040"
                property string bge: "#000000" // eco mode
                property string fg: "#b0b4bc"
                property string border: "#aa4e4e4e"
                property string passive: "#4e4e4e"
                property string dark: Qt.darker(passive, 1.5)
                property string extraDark: Qt.darker(dark, 1.2)
                property string action: "#0db9d7"
                property string accent: "#cc0000"
                property string red: "#cc0000"
                property string yellow: "#ffd700"
                property string purple: "#bf00ff"
                property string green: "#9ece6a"
            }

            // bar
            property JsonObject bar: JsonObject {
                property int height: 30
                // should be in sync with the compositor's (outer) gaps
                property int padding: 8

                property JsonObject title: JsonObject {
                    property int width: 400
                    property string empty: ""
                }
            }

            // desktop
            property JsonObject desktop: JsonObject {
                property bool launcher: true
                property bool osd: false
            }

            // dashboard
            property JsonObject dashboard: JsonObject {
                property string disk: "/"

                property JsonObject player: JsonObject {
                    property bool queueButtons: false
                    property bool notifications: false
                }
            }

            // toasts
            property JsonObject notifications: JsonObject {
                property bool enabled: true
                property int width: 300
            }

            // widgets
            property JsonObject widgets: JsonObject {
                property bool workspaces: true
                property bool title: true
                property bool stats: false
                property bool audio: true
                property bool bluetooth: false
                property bool network: false
                property bool tray: false
                property bool jails: true
                property bool weather: true
                property bool language: false
                property bool clock: true
                property bool battery: true
            }

            // lockscreen
            property JsonObject lockscreen: JsonObject {
                property string wallpaper: States.defaultWallpaper
                property bool buttons: true
                property bool clock: true
                property bool battery: true
                property bool shadows: true
                property bool username: true // full name
                property bool icon: true // user icon
            }

            // session
            property JsonObject session: JsonObject {
                property string background: "#aa202020"

                property JsonObject commands: JsonObject {
                    property string lock: "quickshell -c topbar ipc call bar lock"
                    property string logout: "pkill mango | hyprctl dispatch exit"
                    property string suspend: "zzz"
                    property string hibernate: "acpiconf -s 4"
                    property string shutdown: "shutdown -p now"
                    property string reboot: "shutdown -r now"
                }
            }

            // workspaces
            property JsonObject workspaces: JsonObject {
                property string one: "1"
                property string two: "2"
                property string three: "3"
                property string four: "4"
                property string five: "5"
                property string six: "6"
                property string seven: "7"
                property string eight: "8"
                property string nine: "9"
                property string ten: "0"
            }
        }
    }

    property alias general: settings.general
    property alias bar: settings.bar
    property alias desktop: settings.desktop
    property alias dashboard: settings.dashboard
    property alias notifications: settings.notifications
    property alias widgets: settings.widgets
    property alias lockscreen: settings.lockscreen
    property alias session: settings.session
    property alias workspaces: settings.workspaces

    property var colors: QtObject {
        property color bg: settings.colors.bg
        property color bgl: settings.colors.bgl
        property color bge: settings.colors.bge
        property color fg: settings.colors.fg
        property color border: settings.colors.border
        property color passive: settings.colors.passive
        property color dark: settings.colors.dark
        property color extraDark: settings.colors.extraDark
        property color action: settings.colors.action
        property color accent: settings.colors.accent
        property color red: settings.colors.red
        property color yellow: settings.colors.yellow
        property color purple: settings.colors.purple
        property color green: settings.colors.green
    }
}
