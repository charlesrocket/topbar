pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.OSS
import Quickshell.Services.UPower

import QtQuick
import QtQuick.Layouts

import qs // Settings.qml
import "components"

PanelWindow {
    id: root

    property color colBg: Settings.colors.bg ?? "#aa000000" // background
    property color colBgE: Settings.colors.bgE ?? "#000000" // eco mode background
    property color colFg: Settings.colors.fg ?? "#b0b4bc" // main color
    property color colMuted: Settings.colors.muted ?? "#aa4e4e4e" // passive color
    property color colDark: Settings.colors.dark ?? Qt.darker(colMuted, 1.5) // dark stuff
    property color colCyan: Settings.colors.cyan ?? "#0db9d7" // action color
    property color colRed: Settings.colors.red ?? "#cc0000" // evil color
    property color colBlue: Settings.colors.blue ?? "#7aa2f7" // some stuff
    property color colYellow: Settings.colors.yellow ?? "#ffd700" // danger zone
    property color colGreen: Settings.colors.green ?? "#9ece6a" // zoot zone
    property color colPurple: Settings.colors.purple ?? "#bf00ff" // more stuff

    property string ws01: Settings.workspaces.one ?? "" // 01
    property string ws02: Settings.workspaces.two ?? "" // 02
    property string ws03: Settings.workspaces.three ?? "" // 03
    property string ws04: Settings.workspaces.four ?? "" // 04
    property string ws05: Settings.workspaces.five ?? "" // 05
    property string ws06: Settings.workspaces.six ?? "󰉕" // 06
    property string ws07: Settings.workspaces.seven ?? "" // 07
    property string ws08: Settings.workspaces.eight ?? "" // 08
    property string ws09: Settings.workspaces.tine ?? "" // 09
    property string ws10: Settings.workspaces.ten ?? "" // 10

    property string fontFamily: Settings.font ?? "Hack Nerd Font" // main font
    property int fontSize: Settings.fontSize ?? 14 // base size

    property int cornerRadius: Settings.radius ?? 8 // base radius
    property int animDuration: Settings.duration ?? 250 // base animations

    property int barHeight: Settings.barHeight ?? 30
    property int extraPadding: Settings.barExtraPadding ?? 16

    property var screen: Quickshell.screens[0]
    property bool ecoMode: false // via clock widget

    implicitWidth: screen.width - extraPadding
    implicitHeight: barHeight + extraPadding / 2

    anchors.top: true
    color: "transparent"

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
        interval: 100
        onTriggered: OSS.refresh()
    }

    // bar
    Rectangle {
        id: bar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        border.width: 1
        border.color: root.colMuted
        height: root.barHeight
        color: root.ecoMode ? root.colBgE : root.colBg
        radius: root.cornerRadius

        // startup animation
        transform: Translate {
            id: slideTransform
            y: -(root.implicitHeight)

            Behavior on y {
                NumberAnimation {
                    duration: root.animDuration * 5
                    // OutBounce is alright too
                    easing.type: Easing.OutQuint
                }
            }
        }

        Component.onCompleted: {
            slideTransform.y = 0;
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
                    names: [root.ws01, root.ws02, root.ws03, root.ws04, root.ws05, root.ws06, root.ws07, root.ws08, root.ws09, root.ws10]
                    fontSize: root.fontSize
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
                    colBg: root.colBg
                    colFg: root.colFg
                    colMuted: root.colMuted
                    fontFamily: root.fontFamily
                    fontSize: root.fontSize
                    animDuration: root.animDuration
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
                    active: !root.ecoMode
                    visible: stats.active
                    asynchronous: true

                    sourceComponent: Stats {
                        fontSize: root.fontSize
                        colBar: root.colDark
                        colCpu: root.colFg
                        colMem: root.colFg
                        colDisk: root.colFg
                    }
                }

                BarSeparator {
                    visible: !root.ecoMode
                    colMain: root.colMuted
                }

                // audio
                RowLayout {
                    spacing: 6

                    // devices
                    AudioDevices {
                        colBg: root.colBg
                        colMain: root.colFg
                        colDecor: root.colMuted
                        colActive: root.colRed
                        colCheck: root.colGreen
                        colWinBorder: root.colMuted
                        fontFamily: root.fontFamily
                        fontSize: root.fontSize
                    }

                    // mic
                    Audio {
                        id: mic
                        mic: true
                        slideDuration: root.animDuration
                        visible: mic.control
                        colMuted: root.colRed
                    }

                    // speaker
                    Audio {
                        id: speaker
                        slideDuration: root.animDuration
                        visible: speaker.control
                        colMuted: root.colRed
                    }
                }

                BarSeparator {
                    colMain: root.colMuted
                }

                // bt
                Bluetooth {
                    colMain: root.colFg
                    fontSize: root.fontSize
                }

                // comms
                Network {
                    ecoMode: root.ecoMode
                    colFg: root.colFg
                    fontSize: root.fontSize
                }

                BarSeparator {
                    colMain: root.colMuted
                }

                // weather
                Loader {
                    id: wthr
                    active: !root.ecoMode
                    visible: wthr.active
                    asynchronous: true
                    Layout.rightMargin: 2

                    sourceComponent: Weather {
                        fontFamily: "FiraCode Nerd Font"
                        fontSize: root.fontSize
                        colMain: root.colFg
                        colBg: "transparent"
                        colBorder: root.colCyan
                    }
                }

                // language
                HyprLang {
                    colMain: root.colFg
                    colBorder: Qt.darker(root.colRed, 1.5)
                    colBackground: "transparent"
                    fontFamily: "SpaceMono Nerd Font"
                }

                // time
                Clock {
                    slideDuration: root.animDuration
                    fontFamily: "FiraCode Nerd Font"
                    fontSize: root.fontSize + 1
                    colMain: root.colFg
                    colBtn: root.colRed
                    Layout.topMargin: 2
                    Layout.leftMargin: -1
                    Layout.rightMargin: 2
                    ecoMode: root.ecoMode

                    onEcoModeChanged: {
                        if (root.ecoMode !== ecoMode) {
                            root.ecoMode = ecoMode;
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
                        fontSize: root.fontSize + 2
                        fontFamily: root.fontFamily
                        slideDuration: root.animDuration
                        colMain: root.colFg
                        colGood: root.colGreen
                        colBad: root.colRed
                        colCharging: root.colYellow
                        colBg: root.colDark
                    }
                }
            }
        }
    }
}
