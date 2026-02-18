import Quickshell.Services.SystemTray
import Quickshell.Services.UPower

import QtQuick
import QtQuick.Layouts

import "../widgets/audio"
import "../widgets"
import "../.."

RowLayout {
    Layout.preferredWidth: parent.width / 3
    Layout.alignment: Qt.AlignVCenter

    spacing: 6

    Item {
        Layout.fillWidth: true
    }

    // system stats
    Loader {
        id: stats
        active: !States.ecoMode && Config.widgets.stats
        visible: stats.active
        asynchronous: true
        sourceComponent: Stats {}
    }

    Separator {
        visible: stats.visible
    }

    // audio
    Loader {
        id: audio
        active: Config.widgets.audio
        visible: audio.active
        asynchronous: true
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: item ? item.implicitWidth : 0
        Layout.preferredHeight: item ? item.implicitHeight : 0

        Behavior on Layout.preferredWidth {
            NumberAnimation {
                duration: Config.general.animDuration
                easing.type: Easing.OutCubic
            }
        }

        sourceComponent: Audio {}
    }

    Separator {
        visible: audio.visible
    }

    // bt
    Loader {
        id: bt
        active: !States.ecoMode && Config.widgets.bluetooth
        visible: bt.active
        Layout.alignment: Qt.AlignVCenter
        asynchronous: true
        sourceComponent: Bluetooth {}
    }

    // comms
    Loader {
        id: netwrk
        active: Config.widgets.network
        visible: netwrk.active
        Layout.alignment: Qt.AlignVCenter
        asynchronous: true
        sourceComponent: Network {}
    }

    Separator {
        visible: (bt.visible || netwrk.visible) && (sysTray.visible || localWeather.visible || lang.visible || time.visible || batt.visible)
    }

    // system tray
    Loader {
        id: sysTray
        active: !States.ecoMode && Config.widgets.tray
        visible: sysTray.active && SystemTray.items && SystemTray.items.values.length > 0
        Layout.alignment: Qt.AlignVCenter
        asynchronous: true
        sourceComponent: Tray {}
    }

    // weather
    Loader {
        id: localWeather
        active: !States.ecoMode && Config.widgets.weather
        visible: localWeather.active
        asynchronous: true
        Layout.rightMargin: 2

        sourceComponent: Item {
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
            Weather {}
        }
    }

    // language
    Loader {
        id: lang
        active: Config.widgets.language
        visible: lang.active
        Layout.alignment: Qt.AlignVCenter
        asynchronous: true

        sourceComponent: Item {
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
            HyprLang {}
        }
    }

    // clock
    Loader {
        id: time
        active: Config.widgets.clock
        visible: time.active
        asynchronous: true
        Layout.alignment: Qt.AlignVCenter
        Layout.topMargin: 2
        Layout.leftMargin: -1
        Layout.rightMargin: 2

        sourceComponent: Clock {
            fontSize: Config.general.fontSize + 1
        }
    }

    // battery
    Loader {
        id: batt
        active: (UPower.displayDevice.ready && Config.widgets.battery) || false
        visible: batt.active
        asynchronous: true

        sourceComponent: Battery {
            fontSize: Config.general.fontSize + 2
        }
    }
}
