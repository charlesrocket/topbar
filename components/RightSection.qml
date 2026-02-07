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
        sourceComponent: Stats {}
    }

    BarSeparator {
        visible: !States.ecoMode
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
            AudioDevices {}

            // mic
            Audio {
                id: mic
                mic: true
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

    BarSeparator {}

    // bt
    Bluetooth {}

    // comms
    Network {}

    BarSeparator {}

    // system tray
    Loader {
        id: sysTray
        active: !States.ecoMode && Config.systemTray
        visible: sysTray.active && SystemTray.items && SystemTray.items.values.length > 0
        asynchronous: true
        sourceComponent: Tray {}
    }

    // weather
    Loader {
        id: localWeather
        active: !States.ecoMode
        visible: localWeather.active
        asynchronous: true
        Layout.rightMargin: 2
        sourceComponent: Weather {}
    }

    // language
    HyprLang {}

    // time
    Clock {
        fontSize: Config.fontSize + 1
        Layout.topMargin: 2
        Layout.leftMargin: -1
        Layout.rightMargin: 2
    }

    // battery
    Loader {
        id: batt
        active: UPower.displayDevice.ready
        visible: batt.active
        asynchronous: true

        sourceComponent: Battery {
            fontSize: Config.fontSize + 2
        }
    }
}
