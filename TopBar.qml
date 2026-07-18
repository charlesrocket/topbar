pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import QtQuick
import QtQuick.Layouts

import "components/bar" as Bar
import "components/notifications"
import "components/lockscreen"
import "components/session"
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
    exclusiveZone: bar.visible ? bar.height + Config.bar.padding : 0
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "topbar"

    ColAnim {}

    Rectangle {
        id: bar
        y: Config.bar.padding
        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: root.screen.width - Config.bar.padding * 2
        implicitHeight: Config.bar.height
        height: Config.bar.height
        color: States.ecoMode ? Config.colors.bge : Config.colors.bg
        radius: Config.general.cornerRadius

        //Bar.DynamicFrame {
        //    barWidth: bar.width
        //    barHeight: bar.height
        //}

        Behavior on y {
            NumberAnimation {
                duration: Config.general.animDuration * 2
                easing.type: Easing.OutQuint
            }
        }

        // startup animation
        transform: Translate {
            id: launchSequence
            y: -(root.implicitHeight)

            Behavior on y {
                NumberAnimation {
                    duration: Config.general.animDuration * 5
                    easing.type: Easing.OutQuint
                }
            }
        }

        Component.onCompleted: {
            launchSequence.y = 0;
            States.barPanel = root;
        }

        // sections
        Loader {
            active: States.barEnabled
            visible: States.barEnabled
            Layout.alignment: Qt.AlignCenter
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12

            sourceComponent: RowLayout {
                Bar.Left {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Layout.alignment: Qt.AlignLeft
                }

                Bar.Center {
                    Layout.fillWidth: false
                    Layout.preferredWidth: 400
                    Layout.alignment: Qt.AlignHCenter
                }

                Bar.Right {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Layout.alignment: Qt.AlignRight
                }
            }
        }

        Timer {
            id: hideTimer
            interval: Config.general.animDuration * 2
            onTriggered: {
                bar.visible = false;
                States.barEnabled = false;
            }
        }

        function hidden(val) {
            if (val) {
                bar.y = -(Config.bar.height);
                hideTimer.start();
            } else {
                States.barEnabled = true;
                bar.y = Config.bar.padding;
                bar.visible = true;
            }
        }
    }

    Region {
        id: itemsRegions
        regions: regions.instances
    }

    Variants {
        id: regions
        model: States.dropdownRevealed ? getAllVisibleItems() : root.contentItem.children

        delegate: Region {
            required property Item modelData
            item: modelData
        }
    }

    Connections {
        target: States

        function onDropdownRevealedChanged() {
            regions.model = States.dropdownRevealed ? getAllVisibleItems() : root.contentItem.children;
            itemsRegions.changed();
        }
    }

    Connections {
        target: launchSequence
        // post-start region refresh
        function onYChanged() {
            itemsRegions.changed();
        }
    }

    IpcHandler {
        target: "topbar"

        function launcher(): void {
            if (Config.desktop.launcher)
                States.launcherPresent = true;
            else
                console.warn("Launcher disabled");
        }

        function config(): void {
            States.preferencesWindowPresent = true;
        }

        function logout(): void {
            States.sessionPresent = true;
        }

        function lock(): void {
            root.lockScreen();
        }

        function hide(): void {
            bar.hidden(true);
        }

        function reveal(): void {
            bar.hidden(false);
        }
    }

    Loader {
        id: notif
        active: Config.notifications.enabled
        visible: notif.active

        sourceComponent: Notifications {}
    }

    Loader {
        id: preferencesWindow
        active: States.preferencesWindowPresent
        visible: preferencesWindow.active
        sourceComponent: Preferences {}
    }

    Loader {
        id: launcher
        active: States.launcherPresent && Config.desktop.launcher
        visible: launcher.active
        sourceComponent: Launcher {}
    }

    Session {
        SessionButton {
            command: Config.session.commands.lock
            keybind: Qt.Key_K
            text: "Lock"
            icon: ""
        }

        SessionButton {
            command: Config.session.commands.logout
            keybind: Qt.Key_E
            text: "Logout"
            icon: "󰗽"
        }

        SessionButton {
            command: Config.session.commands.suspend
            keybind: Qt.Key_S
            text: "Suspend"
            icon: ""
        }

        SessionButton {
            command: Config.session.commands.hibernate
            keybind: Qt.Key_H
            text: "Hibernate"
            icon: "󰅐"
        }

        SessionButton {
            command: Config.session.commands.shutdown
            keybind: Qt.Key_P
            text: "Shutdown"
            icon: "󰤆"
        }

        SessionButton {
            command: Config.session.commands.reboot
            keybind: Qt.Key_R
            text: "Reboot"
            icon: "󰑐"
        }
    }

    Process {
        id: dpmsOff

        command: switch (System.desktop) {
        case "mango":
            return ["mmsg", "-d", "disable_monitor"];
        case "hyprland":
            return ["hyprctl", "dispatch", "dpms", "off"];
        }
    }

    Process {
        id: dpmsOn

        command: switch (System.desktop) {
        case "mango":
            return ["mmsg", "-d", "enable_monitor"];
        case "hyprland":
            return ["hyprctl", "dispatch", "dpms", "on"];
        }
    }

    Process {
        id: suspendProcess
        command: Config.session.commands.suspend
    }

    IdleMonitor {
        timeout: 600
        enabled: !States.keepAwake

        onIsIdleChanged: {
            if (isIdle) {
                lock.locked = true;
            }
        }
    }

    IdleMonitor {
        timeout: 690
        enabled: !States.keepAwake

        onIsIdleChanged: {
            if (isIdle) {
                dpmsOff.running = true;
            } else {
                dpmsOn.running = true;
            }
        }
    }

    IdleMonitor {
        timeout: 3600
        enabled: !States.keepAwake

        onIsIdleChanged: {
            if (isIdle) {
                suspendProcess.running = true;
            }
        }
    }

    LockContext {
        id: lockContext

        onUnlocked: {
            States.barEnabled = true;
            lock.locked = false;
        }
    }

    WlSessionLock {
        id: lock

        WlSessionLockSurface {
            color: "transparent"

            LockScreen {
                anchors.fill: parent
                context: lockContext
            }
        }
    }

    function lockScreen() {
        States.barEnabled = false;
        lock.locked = true;
    }

    function getAllVisibleItems() {
        const items = [];

        function collect(item) {
            if (!item)
                return;

            items.push(item);

            for (const child of item.children) {
                if (child.visible) {
                    collect(child);
                }
            }
        }

        collect(root.contentItem);
        return items;
    }
}
