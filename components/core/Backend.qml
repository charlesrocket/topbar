import QtQuick

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import qs
import qs.lockscreen
import qs.notifications
import qs.session
import qs.settings

Scope {
    id: root

    function lockScreen() {
        States.barEnabled = false;
        lock.locked = true;
    }

    IpcHandler {
        function launcher() {
            if (Config.desktop.launcher)
                States.launcherPresent = true;
            else
                console.warn("Launcher disabled");
        }

        function settings() {
            States.settingsPresent = true;
        }

        function logout() {
            States.sessionPresent = true;
        }

        function lock() {
            root.lockScreen();
        }

        target: "main"
    }

    Loader {
        id: notif

        active: Config.notifications.enabled
        visible: notif.active

        sourceComponent: Notifications {}
    }

    Loader {
        id: settingsWindow

        active: States.settingsPresent
        visible: settingsWindow.active

        sourceComponent: Settings {}
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
            keybind: Qt.Key_L
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
        timeout: Config.session.timeouts.screen
        enabled: !States.keepAwake

        onIsIdleChanged: {
            if (isIdle) {
                lock.locked = true;
            }
        }
    }

    IdleMonitor {
        timeout: Config.session.timeouts.display
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
        timeout: Config.session.timeouts.sleep
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
}
