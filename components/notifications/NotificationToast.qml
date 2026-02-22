pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Notifications

import QtQuick
import QtQuick.Layouts

import "../.."

Rectangle {
    id: root

    property string fontFamily: Config.general.fontFamily
    property var notification: null

    signal dismissed
    signal expired

    readonly property bool ready: notification !== null
    readonly property int timeoutMs: ready && notification.expireTimeout > 0 ? notification.expireTimeout : 5000

    readonly property color urgencyColor: {
        if (!ready)
            return Config.colors.border;

        switch (notification.urgency) {
        case NotificationUrgency.Critical:
            return Config.colors.red;
        case NotificationUrgency.Low:
            return Config.colors.action;
        default:
            return Config.colors.fg;
        }
    }

    implicitWidth: Config.notifications.width
    implicitHeight: contentLayout.implicitHeight + 24

    radius: Config.general.cornerRadius
    color: Config.colors.bg
    border.width: Config.general.borderWidth
    border.color: urgencyColor

    // slide-in from the right
    transform: Translate {
        id: slideIn
        x: 400
    }

    Component.onCompleted: slideInAnim.start()

    NumberAnimation {
        id: slideInAnim
        target: slideIn
        property: "x"
        from: Config.notifications.width
        to: 0
        duration: Config.general.animDuration
        easing.type: Easing.OutQuint
    }

    // auto-expire timer
    Timer {
        id: expireTimer
        interval: root.timeoutMs
        running: root.ready
        onTriggered: root.expired()
    }

    // progress bar
    Rectangle {
        anchors {
            bottom: parent.bottom
            right: parent.right
        }

        height: 3
        radius: root.radius
        color: root.urgencyColor
        opacity: 0.8

        NumberAnimation on width {
            from: root.implicitWidth - 2
            to: 0
            duration: root.timeoutMs
            running: expireTimer.running
            easing.type: Easing.Linear
        }
    }

    // close button
    Text {
        id: closeButton
        text: ""
        color: Qt.darker(Config.colors.fg, 1.3)
        font.pixelSize: 16
        font.bold: false
        font.family: "Symbols Nerd Font"

        anchors {
            top: parent.top
            right: parent.right
            margins: 12
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.dismissed()
        }
    }

    ColumnLayout {
        id: contentLayout

        anchors {
            left: parent.left
            right: closeButton.left
            rightMargin: 8
            top: parent.top
            topMargin: 12
            leftMargin: 12
        }

        // app name
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: root.ready ? root.notification.appName === "notify-send" ? "" : root.notification.appName : ""
                color: Qt.darker(Config.colors.fg, 1.3)
                font.pixelSize: 14
                font.family: root.fontFamily
                font.weight: Font.Medium
                elide: Text.ElideRight
                Layout.fillWidth: true
                visible: text.length > 0
            }
        }

        // summary / title
        Text {
            text: root.ready ? root.notification.summary : ""
            color: Config.colors.fg
            font.pixelSize: 14
            font.family: root.fontFamily
            font.weight: Font.Medium
            wrapMode: Text.WordWrap
            textFormat: Text.PlainText
            Layout.fillWidth: true
            visible: text.length > 0
        }

        // body

        Text {
            text: root.ready ? root.notification.body : ""
            color: Config.colors.fg
            font.pixelSize: 13
            font.family: root.fontFamily
            wrapMode: Text.WordWrap
            textFormat: Text.PlainText
            Layout.fillWidth: true
            visible: text.length > 0
        }

        // action buttons
        Flow {
            Layout.fillWidth: true
            spacing: 6
            visible: root.ready && root.notification.actions.length > 0

            Repeater {
                model: root.ready ? root.notification.actions : []

                delegate: Text {
                    required property var modelData

                    text: modelData.text
                    color: Config.colors.fg
                    font.pixelSize: 12
                    font.family: root.fontFamily
                    leftPadding: 8
                    rightPadding: 8
                    topPadding: 4
                    bottomPadding: 4

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            parent.modelData.invoke();
                            root.dismissed();
                        }
                    }
                }
            }
        }
    }

    HoverHandler {
        onHoveredChanged: expireTimer.running = !hovered
    }
}
