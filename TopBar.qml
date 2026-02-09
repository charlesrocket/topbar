pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.OSS
import Quickshell.Wayland

import QtQuick
import QtQuick.Layouts

import "components/lockscreen"
import "components/logout"
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
    exclusiveZone: bar.visible ? bar.height + Config.bar.extraPadding : 0

    Rectangle {
        id: bar
        y: Config.bar.extraPadding
        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: root.screen.width - Config.bar.extraPadding * 2
        implicitHeight: Config.bar.height
        border.width: 1
        border.color: Config.colors.border
        height: Config.bar.height
        color: States.ecoMode ? Config.colors.bge : Config.colors.bg
        radius: Config.general.cornerRadius

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

            LeftSection {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.alignment: Qt.AlignLeft
            }

            CenterSection {
                Layout.fillWidth: false
                Layout.preferredWidth: 400
                Layout.alignment: Qt.AlignHCenter
            }

            RightSection {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.alignment: Qt.AlignRight
            }
        }

        Timer {
            id: hideTimer
            interval: Config.general.animDuration * 2
            onTriggered: bar.visible = false
        }

        function hidden(val) {
            if (val) {
                bar.y = -(Config.barHeight);
                hideTimer.start();
            } else {
                bar.y = Config.extraPadding;
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

        function logout(): void {
            States.logoutPresent = true;
        }

        function lock(): void {
            lock.locked = true;
        }
    }

    Logout {
        LogoutButton {
            command: Config.logout.commands.lock
            keybind: Qt.Key_K
            text: "Lock"
            icon: ""
        }

        LogoutButton {
            command: Config.logout.commands.logout
            keybind: Qt.Key_E
            text: "Logout"
            icon: "󰗽"
        }

        LogoutButton {
            command: Config.logout.commands.suspend
            keybind: Qt.Key_S
            text: "Suspend"
            icon: ""
        }

        LogoutButton {
            command: Config.logout.commands.hibernate
            keybind: Qt.Key_H
            text: "Hibernate"
            icon: "󰅐"
        }

        LogoutButton {
            command: Config.logout.commands.shutdown
            keybind: Qt.Key_P
            text: "Shutdown"
            icon: "󰤆"
        }

        LogoutButton {
            command: Config.logout.commands.reboot
            keybind: Qt.Key_R
            text: "Reboot"
            icon: "󰑐"
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

    Process {
        id: dpmsOff
        command: ["hyprctl", "dispatch", "dpms", "off"]
    }

    Process {
        id: dpmsOn
        command: ["hyprctl", "dispatch", "dpms", "on"]
    }

    Process {
        id: suspendProcess
        command: Config.logout.commands.suspend
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

    Component.onCompleted: {
        if (this.WlrLayershell != null) {
            this.WlrLayershell.layer = WlrLayer.Top;
        }
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
