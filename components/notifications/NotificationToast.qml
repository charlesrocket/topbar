import Quickshell.Services.Notifications
import Quickshell.Widgets

import QtQuick
import QtQuick.Layouts

import ".."

Rectangle {
    id: root

    property string fontFamily: Config.general.fontFamily
    property var notification: null
    property real hoverPauseStart: 0
    property int timeoutMs: ready && notification.expireTimeout > 0 ? notification.expireTimeout : 5000

    signal dismissed
    signal expired

    readonly property bool ready: notification !== null
    readonly property bool hasImage: ready && notification.image !== ""
    readonly property bool hasAppIcon: ready && notification.appIcon !== ""

    readonly property color urgencyColor: {
        if (!ready)
            return Config.colors.border;

        switch (notification.urgency) {
        case NotificationUrgency.Critical:
            return Config.colors.red;
        case NotificationUrgency.Low:
            return Config.colors.passive;
        default:
            return Config.colors.fg;
        }
    }

    implicitWidth: Config.notifications.width
    implicitHeight: bodyRow.implicitHeight + 24

    radius: Config.general.cornerRadius
    color: States.ecoMode ? Config.colors.bge : Config.colors.bg
    border.width: Config.general.borderWidth
    border.color: Config.colors.border
    Component.onCompleted: slideInAnim.start()

    transform: Translate {
        id: slide
        x: Config.notifications.width
    }

    NumberAnimation {
        id: slideInAnim
        target: slide
        property: "x"
        from: Config.notifications.width
        to: 0
        duration: Config.general.animDuration
        easing.type: Easing.OutQuint
    }

    NumberAnimation {
        id: slideOutAnim
        target: slide
        property: "x"
        from: 0
        to: Config.notifications.width
        duration: Config.general.animDuration
        easing.type: Easing.InQuint

        onStopped: {
            if (slideOutAnim.pendingDismiss)
                root.dismissed();
            else
                root.expired();
        }

        property bool pendingDismiss: false
    }

    // auto-expire timer
    Timer {
        id: expireTimer
        interval: root.timeoutMs
        running: root.ready
        onTriggered: root.expire()
    }

    // close button
    Rectangle {
        id: closeButtonCont
        opacity: 0
        implicitWidth: closeButton.implicitWidth + 16
        implicitHeight: closeButton.implicitHeight + 8
        color: Config.colors.bge
        border.width: 1
        border.color: Config.colors.accent
        radius: Config.general.cornerRadius
        z: 1

        anchors {
            top: parent.top
            right: parent.right
            margins: 8
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Config.general.animDuration
                easing.type: Easing.InOutQuad
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.dismiss()
        }

        Text {
            id: closeButton
            text: ""
            color: Qt.darker(Config.colors.fg, 1.3)
            font.pixelSize: 16
            font.bold: false
            font.family: "Symbols Nerd Font"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.dismiss()
            }
        }
    }

    // content row
    RowLayout {
        id: bodyRow
        spacing: 6

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: 12
            leftMargin: 12
            rightMargin: 12
            bottomMargin: 12
        }

        // text content
        ColumnLayout {
            id: contentLayout
            Layout.fillWidth: true
            spacing: 6

            // app name
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                visible: root.notification.appName && root.ready
                Layout.alignment: Qt.AlignVCenter

                // app icon
                Item {
                    id: iconContainer
                    visible: root.hasAppIcon && root.notification.appName
                    implicitWidth: 12
                    implicitHeight: 12

                    IconImage {
                        id: appIconImage
                        anchors.fill: parent
                        source: root.hasAppIcon ? root.notification.appIcon : ""
                        visible: root.hasAppIcon
                        mipmap: true
                    }
                }

                Text {
                    text: root.ready ? (root.notification.appName === "notify-send" ? "" : root.notification.appName) : ""
                    color: Qt.darker(Config.colors.fg, 1.3)
                    font.pixelSize: 14
                    font.family: root.fontFamily
                    font.weight: Font.Light
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
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                visible: root.ready
                Layout.alignment: Qt.AlignVCenter

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

                // image
                Item {
                    visible: root.hasImage
                    implicitWidth: 28
                    implicitHeight: 28

                    Image {
                        anchors.fill: parent
                        visible: root.hasImage
                        source: root.hasImage ? root.notification.image : ""
                        mipmap: true
                        smooth: false
                    }
                }
            }

            // action buttons
            Flow {
                Layout.fillWidth: true
                layoutDirection: Qt.LeftToRight
                visible: root.ready && root.notification.actions.length > 0
                spacing: 8

                Repeater {
                    model: root.ready ? root.notification.actions : []
                    delegate: Rectangle {
                        required property var modelData

                        implicitWidth: label.implicitWidth + 24
                        implicitHeight: label.implicitHeight + 10
                        radius: Config.general.cornerRadius
                        color: "transparent"
                        border.color: buttonArea.containsMouse ? Config.colors.action : Config.colors.fg
                        border.width: 1

                        Behavior on border.color {
                            ColAnim {}
                        }

                        Text {
                            id: label
                            anchors.centerIn: parent
                            text: parent.modelData.text
                            color: Config.colors.fg
                            font.pixelSize: 14
                            font.family: root.fontFamily
                            font.bold: false
                        }

                        MouseArea {
                            id: buttonArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                parent.modelData.invoke();
                                root.dismiss();
                            }
                        }
                    }
                }
            }
        }
    }

    // timeout progress bar
    Rectangle {
        id: progressBar
        height: 2
        radius: 2
        color: root.urgencyColor
        opacity: 0.9
        width: root.implicitWidth - Config.general.cornerRadius * 2

        anchors {
            bottom: parent.bottom
            right: parent.right
            leftMargin: 5
            rightMargin: 5
            bottomMargin: 3
        }

        NumberAnimation on width {
            id: progressAnim
            target: progressBar
            property: "width"
            from: root.timeoutMs / root.timeoutMs * (root.implicitWidth - 2)
            to: 0
            duration: root.timeoutMs
            running: expireTimer.running
            easing.type: Easing.Linear
        }
    }

    HoverHandler {
        onHoveredChanged: {
            if (hovered) {
                closeButtonCont.opacity = 1;
                root.hoverPauseStart = Date.now();
                root.timeoutMs = progressBar.width / (root.implicitWidth - 2) * root.timeoutMs;
                progressAnim.stop();
                expireTimer.stop();
            } else {
                closeButtonCont.opacity = 0;
                expireTimer.interval = root.timeoutMs;
                progressAnim.from = progressBar.width;
                progressAnim.duration = root.timeoutMs;
                expireTimer.restart();
                progressAnim.restart();
            }
        }
    }

    function dismiss() {
        expireTimer.stop();
        slideOutAnim.pendingDismiss = true;
        slideOutAnim.start();
    }

    function expire() {
        slideOutAnim.pendingDismiss = false;
        slideOutAnim.start();
    }
}
