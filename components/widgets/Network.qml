import QtQuick
import QtQuick.Layouts

import Quickshell.Io

import TopBar.Networking

import qs

Item {
    id: root

    property int fontSize: Config.general.fontSize
    property color colFg: Config.colors.fg
    property color colAction: Config.colors.action
    property color colOffline: Config.colors.red
    property color colPassive: Config.colors.passive
    property bool isOnline: false
    property color colOnline: States.ecoMode ? root.colPassive : root.isOnline
                                               ? root.colFg : root.colOffline
    readonly property var devicesList: Networking.devices.values
    readonly property string uplinkIcon: hasActiveVpn ? "" : ""
    readonly property bool hasActiveVpn: {
        var devices = devicesList;

        for (var i = 0; i < devices.length; i++) {
            var dev = devices[i];

            if (dev && dev.connected && dev.name) {
                var name = dev.name.toLowerCase();

                if (name.startsWith("tun") || name.startsWith("tap")
                        || name.startsWith("wg") || name.startsWith("ppp")) {
                    return true;
                }
            }
        }

        return false;
    }
    readonly property var primaryDevice: {
        var devices = devicesList;
        if (devices.length === 0)
            return null;

        var connectedDev = null;
        var firstDev = null;

        for (var i = 0; i < devices.length; i++) {
            var dev = devices[i];
            if (!dev)
                continue;

            if (!firstDev)
                firstDev = dev;

            if (dev.state === ConnectionState.Connected) {
                connectedDev = dev;
                return dev;
            }
        }

        return connectedDev || firstDev;
    }
    readonly property bool isPrimaryWifi: {
        if (!primaryDevice)
            return false;

        return primaryDevice.type === DeviceType.Wifi;
    }
    readonly property string ifIcon: {
        if (isPrimaryWifi)
            return "󰖩";
        else
            return "󰈀";
    }

    implicitWidth: section.implicitWidth
    implicitHeight: section.implicitHeight

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    Process {
        id: netifRestart

        command: ["sh", "-c",
            "notify-send -u normal 'Reloading the network' ; doas service netif restart"]

        Component.onCompleted: running = false
    }

    Process {
        id: onlineCheck

        command: ["host", "-W", "1", "8.8.8.8"]
        running: !States.ecoMode

        onExited: (exitCode, exitStatus) => {
            var randomValue = Math.floor(Math.random() * (5000 - 1000) + 1000);
            tmr.interval = 3000 + randomValue;
            root.isOnline = (exitCode === 0);
            tmr.start();
        }
    }

    Timer {
        id: tmr

        running: !States.ecoMode

        onTriggered: {
            onlineCheck.running = true;
        }
    }

    RowLayout {
        id: section

        anchors.fill: parent
        spacing: 6

        Text {
            id: onlineIcon

            property bool isHovered: false

            text: root.uplinkIcon
            color: root.colOnline
            font.family: "Symbols Nerd Font"
            font.pixelSize: root.fontSize
            visible: !States.ecoMode

            Behavior on color {
                ColAnim {}
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onEntered: {
                    onlineIcon.isHovered = true;
                }
                onExited: {
                    onlineIcon.isHovered = false;
                }
                onClicked: {
                    netifRestart.running = true;
                }
            }
        }

        Text {
            text: root.ifIcon
            color: root.colFg
            font.family: "Symbols Nerd Font"
            font.pixelSize: root.fontSize
        }
    }
}
