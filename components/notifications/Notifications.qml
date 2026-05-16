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
        notif.dismiss();
        root.notifications = root.notifications.filter(n => n !== notif);
    }

    function expireNotification(notif) {
        notif.expire();
        root.notifications = root.notifications.filter(n => n !== notif);
    }

    PanelWindow {
        WlrLayershell.namespace: "notifications"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        visible: root.notifications.length > 0

        implicitWidth: Config.notifications.width + Config.bar.padding
        implicitHeight: stack.implicitHeight + Config.bar.padding
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

                topMargin: Config.bar.padding
                rightMargin: Config.bar.padding
            }

            Repeater {
                model: ScriptModel {
                    // TODO fix blinking
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
