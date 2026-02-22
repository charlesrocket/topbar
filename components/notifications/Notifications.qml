pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Notifications

import QtQuick
import QtQuick.Layouts

import "../.."

Item {
    id: root

    implicitWidth: Config.notifications.width
    implicitHeight: stack.implicitHeight

    property var notifications: []

    NotificationServer {
        id: server

        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: false
        imageSupported: false
        keepOnReload: false

        onNotification: notif => {
            notif.tracked = true;
            root.notifications = [notif].concat(root.notifications);
        }
    }

    function removeNotification(notif) {
        notif.dismiss();
        root.notifications = root.notifications.filter(n => n !== notif);
    }

    function expireNotification(notif) {
        notif.expire();
        root.notifications = root.notifications.filter(n => n !== notif);
    }

    ColumnLayout {
        id: stack
        spacing: 6

        anchors {
            top: parent.top
            right: parent.right
        }

        Repeater {
            model: ScriptModel {
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
