import Quickshell.Services.SystemTray
import Quickshell.Services.UPower

import QtQuick
import QtQuick.Layouts

import ".."
import "widgets"

RowLayout {
    Layout.preferredWidth: parent.width / 3
    spacing: 6

    Item {
        Layout.fillWidth: true
    }

    // system stats
    Loader {
        id: stats
        active: !States.ecoMode && Config.systemStats
        visible: stats.active
        asynchronous: true

        sourceComponent: Stats {
            fontSize: Config.fontSize
            colBar: Config.colDark
            colCpu: Config.colFg
            colMem: Config.colFg
            colDisk: Config.colFg
        }
    }

    BarSeparator {
        visible: !States.ecoMode
        colMain: Config.colPassive
    }

    // audio
    Item {
        Layout.preferredWidth: audioRow.implicitWidth
        implicitHeight: audioRow.implicitHeight

        Behavior on Layout.preferredWidth {
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Easing.OutCubic
            }
        }

        RowLayout {
            id: audioRow
            anchors.right: parent.right
            spacing: 6

            // devices
            AudioDevices {
                colBg: Config.colBg
                colMain: Config.colFg
                colDecor: Config.colPassive
                colActive: Config.colAccent
                colCheck: Config.colGreen
                colWinBorder: Config.colPassive
                fontFamily: Config.fontFamily
                fontSize: Config.fontSize
            }

            // mic
            Audio {
                id: mic
                mic: true
                colPassive: Config.colAccent
                opacity: mic.control ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.animDuration
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // speaker
            Audio {
                id: speaker
                colPassive: Config.colAccent
                opacity: speaker.control ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.animDuration
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }

    BarSeparator {
        colMain: Config.colPassive
    }

    // bt
    Bluetooth {
        colMain: Config.colFg
        fontSize: Config.fontSize
    }

    // comms
    Network {
        ecoMode: States.ecoMode
        fontSize: Config.fontSize
    }

    BarSeparator {
        colMain: Config.colPassive
    }

    // system tray
    Loader {
        id: sysTray
        active: !States.ecoMode && Config.systemTray
        visible: sysTray.active && SystemTray.items && SystemTray.items.values.length > 0
        asynchronous: true

        sourceComponent: Tray {
            iconSize: Config.fontSize
            iconColor: Config.colFg
        }
    }

    // weather
    Loader {
        id: localWeather
        active: !States.ecoMode
        visible: localWeather.active
        asynchronous: true
        Layout.rightMargin: 2

        sourceComponent: Weather {
            fontFamily: "FiraCode Nerd Font"
            fontSize: Config.fontSize
            colMain: Config.colFg
            colBg: "transparent"
            colBorder: Config.colAction
        }
    }

    // language
    HyprLang {
        colBorder: Qt.darker(Config.colAccent, 1.5)
        fontFamily: "SpaceMono Nerd Font"
    }

    // time
    Clock {
        slideDuration: Config.animDuration
        fontFamily: "FiraCode Nerd Font"
        fontSize: Config.fontSize + 1
        colMain: Config.colFg
        colButton: Config.colAccent
        Layout.topMargin: 2
        Layout.leftMargin: -1
        Layout.rightMargin: 2
        ecoMode: States.ecoMode

        onEcoModeChanged: {
            if (States.ecoMode !== ecoMode) {
                States.ecoMode = ecoMode;
            }
        }
    }

    // battery
    Loader {
        id: batt
        active: UPower.displayDevice.ready
        visible: batt.active
        asynchronous: true

        sourceComponent: Battery {
            fontSize: Config.fontSize + 2
            fontFamily: Config.fontFamily
            slideDuration: Config.animDuration
            colMain: Config.colFg
            colGood: Config.colGreen
            colBad: Config.colAccent
            colCharging: Config.colYellow
            colBg: Config.colDark
        }
    }
}
