pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick

import Quickshell
import Quickshell.Io

import qs.core

Singleton {
    id: root

    readonly property string path: States.config + "/settings.json"
    property alias general: settings.general
    property alias bar: settings.bar
    property alias desktop: settings.desktop
    property alias notifications: settings.notifications
    property alias services: settings.services
    property alias lockscreen: settings.lockscreen
    property alias session: settings.session
    property alias workspaces: settings.workspaces
    property alias appearance: settings.appearance
    property alias colors: colorsObj

    signal saveFailed
    signal saveSucceeded

    function save() {
        fileView.writeAdapter();
    }

    FileView {
        id: fileView

        path: root.path
        watchChanges: Config.general.configWatch

        onFileChanged: reload()
        onAdapterUpdated: if (Config.general.configWatch)
                              writeAdapter()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                writeAdapter();
        }
        onSaveFailed: error => root.saveFailed()
        onSaved: root.saveSucceeded()

        JsonAdapter {
            id: settings

            // general
            property JsonObject general: JsonObject {
                property string locale: "AnyTerritory"
                property string wallpaper: States.defaultWallpaper
                property bool configWatch: true
            }

            // appearance
            property JsonObject appearance: JsonObject {
                property string fontFamily: "Hack Nerd Font"
                property int fontSize: 14
                property int borderWidth: 1
                property int cornerRadius: 8
                property int animDuration: 250
                property bool blur: true
                property bool shadows: true

                // colors
                property JsonObject colors: JsonObject {
                    id: colorsObj

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

                // dashboard
                property JsonObject dashboard: JsonObject {
                    property string disk: "/"
                    property JsonObject player: JsonObject {
                        property bool queueButtons: false
                        property bool notifications: false
                    }
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
            }

            // desktop
            property JsonObject desktop: JsonObject {
                property bool launcher: true
                property bool osd: true
            }

            // toasts
            property JsonObject notifications: JsonObject {
                property bool enabled: true
                property int width: 300
            }

            // services
            property JsonObject services: JsonObject {
                property bool codeberg: false
                property bool github: false
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
                    property string lock:
                        "quickshell -c topbar ipc call bar lock"
                    property string logout: "pkill mango | hyprshutdown"
                    property string suspend: "zzz"
                    property string hibernate: "acpiconf -s 4"
                    property string shutdown: "shutdown -p now"
                    property string reboot: "shutdown -r now"
                }
                property JsonObject timeouts: JsonObject { // in seconds
                    property int screen: 600
                    property int display: 690
                    property int sleep: 3600
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
}
