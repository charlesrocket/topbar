pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Services.OSS
import Quickshell.Services.UPower

import QtQuick
import QtQuick.Layouts

import "components"

PanelWindow {
    id: root

    property var screen: Quickshell.screens[0]

    anchors {
        top: true
        left: true
        right: true
    }

    mask: itemsRegions
    color: "transparent"
    implicitHeight: screen.height
    exclusiveZone: bar.visible ? bar.height + Config.extraPadding : 0

    Rectangle {
        id: bar
        y: Config.extraPadding
        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: root.screen.width - Config.extraPadding * 2
        implicitHeight: Config.barHeight
        border.width: 1
        border.color: Config.colMuted
        height: Config.barHeight
        color: Config.ecoMode ? Config.colBgE : Config.colBg
        radius: Config.cornerRadius

        // startup animation
        transform: Translate {
            id: launchSequence
            y: -(root.implicitHeight)

            Behavior on y {
                NumberAnimation {
                    duration: Config.animDuration * 5
                    // OutBounce is alright too
                    easing.type: Easing.OutQuint
                }
            }
        }

        Component.onCompleted: {
            launchSequence.y = 0;
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 13
            anchors.rightMargin: 12

            // left section
            RowLayout {
                Layout.preferredWidth: parent.width / 3
                spacing: 6

                // workspaces
                HyprWorkspaces {
                    names: [Config.ws01, Config.ws02, Config.ws03, Config.ws04, Config.ws05, Config.ws06, Config.ws07, Config.ws08, Config.ws09, Config.ws10]
                    fontSize: Config.fontSize
                    fontFamily: "Symbols Nerd Font"
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            // center section
            RowLayout {
                Layout.preferredWidth: parent.width / 3

                Item {
                    Layout.fillWidth: true
                }

                // active window title
                WindowTitle {
                    emptyTitle: "" // idle
                    colBg: Config.colBg
                    colFg: Config.colFg
                    colMuted: Config.colMuted
                    fontFamily: Config.fontFamily
                    fontSize: Config.fontSize
                    animDuration: Config.animDuration
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            // right section
            RowLayout {
                Layout.preferredWidth: parent.width / 3
                spacing: 6

                Item {
                    Layout.fillWidth: true
                }

                // system stats
                Loader {
                    id: stats
                    active: !Config.ecoMode && Config.systemStats
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
                    visible: !Config.ecoMode
                    colMain: Config.colMuted
                }

                // audio
                RowLayout {
                    spacing: 6

                    // devices
                    AudioDevices {
                        colBg: Config.colBg
                        colMain: Config.colFg
                        colDecor: Config.colMuted
                        colActive: Config.colRed
                        colCheck: Config.colGreen
                        colWinBorder: Config.colMuted
                        fontFamily: Config.fontFamily
                        fontSize: Config.fontSize
                    }

                    // mic
                    Audio {
                        id: mic
                        mic: true
                        slideDuration: Config.animDuration
                        visible: mic.control
                        colMuted: Config.colRed
                    }

                    // speaker
                    Audio {
                        id: speaker
                        slideDuration: Config.animDuration
                        visible: speaker.control
                        colMuted: Config.colRed
                    }
                }

                BarSeparator {
                    colMain: Config.colMuted
                }

                // bt
                Bluetooth {
                    colMain: Config.colFg
                    fontSize: Config.fontSize
                }

                // comms
                Network {
                    ecoMode: Config.ecoMode
                    colFg: Config.colFg
                    fontSize: Config.fontSize
                }

                BarSeparator {
                    colMain: Config.colMuted
                }

                // system tray
                Loader {
                    id: sysTray
                    active: !Config.ecoMode && Config.systemTray
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
                    active: !Config.ecoMode
                    visible: localWeather.active
                    asynchronous: true
                    Layout.rightMargin: 2

                    sourceComponent: Weather {
                        fontFamily: "FiraCode Nerd Font"
                        fontSize: Config.fontSize
                        colMain: Config.colFg
                        colBg: "transparent"
                        colBorder: Config.colCyan
                    }
                }

                // language
                HyprLang {
                    colMain: Config.colFg
                    colBorder: Qt.darker(Config.colRed, 1.5)
                    colBackground: "transparent"
                    fontFamily: "SpaceMono Nerd Font"
                }

                // time
                Clock {
                    slideDuration: Config.animDuration
                    fontFamily: "FiraCode Nerd Font"
                    fontSize: Config.fontSize + 1
                    colMain: Config.colFg
                    colButton: Config.colRed
                    Layout.topMargin: 2
                    Layout.leftMargin: -1
                    Layout.rightMargin: 2
                    ecoMode: Config.ecoMode

                    onEcoModeChanged: {
                        if (Config.ecoMode !== ecoMode) {
                            Config.ecoMode = ecoMode;
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
                        colBad: Config.colRed
                        colCharging: Config.colYellow
                        colBg: Config.colDark
                    }
                }
            }
        }
    }

    Region {
        id: itemsRegions
        regions: regions.instances
    }

    Variants {
        id: regions
        model: root.contentItem.children

        delegate: Region {
            required property Item modelData
            item: modelData
        }
    }

    Connections {
        target: launchSequence
        // post-start region refresh
        function onYChanged() {
            itemsRegions.changed();
        }
    }

    // Global shortcuts depend on Hyprland bindings:
    // bind = , XF86AudioMute, global, quickshell:volume-mute

    GlobalShortcut {
        name: "volume-up"
        onPressed: {
            refreshOSS.start();
        }
    }

    GlobalShortcut {
        name: "volume-down"
        onPressed: {
            refreshOSS.start();
        }
    }

    GlobalShortcut {
        name: "volume-mute"
        onPressed: {
            refreshOSS.start();
        }
    }

    // update audio
    Timer {
        id: refreshOSS
        interval: 50
        onTriggered: OSS.refresh()
    }
}
