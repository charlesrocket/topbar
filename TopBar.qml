pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.OSS

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

            LeftSection {}

            CenterSection {}

            RightSection {}
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
