pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

import QtQuick
import QtQuick.Layouts

import "../.."

Item {
    id: root

    property var notifications: []

    NotificationServer {
        id: server

        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: false
        imageSupported: true
        keepOnReload: false

        onNotification: notif => {
            notif.tracked = true;
            root.notifications = [notif].concat(root.notifications);
        }
    }

    function removeNotification(notif) {
        if (notif && notif.tracked)
            notif.dismiss();

        root.notifications = root.notifications.filter(n => n !== notif);
    }

    function expireNotification(notif) {
        if (notif && notif.tracked)
            notif.expire();

        root.notifications = root.notifications.filter(n => n !== notif);
    }

    PanelWindow {
        WlrLayershell.namespace: "notifications"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore
        implicitWidth: Config.notifications.width + (Config.bar.padding * 2)
        implicitHeight: stack.implicitHeight + (Config.bar.padding)
        color: "transparent"
        visible: root.notifications.length > 0
        margins.top: Config.bar.height + (Config.bar.padding * 3)

        anchors {
            top: true
            right: true
        }

        ColumnLayout {
            id: stack
            spacing: 6

            anchors {
                top: parent.top
                right: parent.right
                rightMargin: Config.bar.padding * 2
            }

            Repeater {
                model: ScriptModel { // TODO fix flickering
                    values: root.notifications
                }

                delegate: NotificationToast {
                    required property var modelData

                    notification: modelData
                    Layout.alignment: Qt.AlignRight
                    onDismissed: root.removeNotification(modelData)
                    onExpired: root.expireNotification(modelData)
                }
            }
        }
    }
}
