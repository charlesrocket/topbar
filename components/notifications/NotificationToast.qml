import QtQuick
import QtQuick.Layouts

import Quickshell.Services.Notifications
import Quickshell.Widgets

import TopBar.Clients

import qs
import qs.core

Rectangle {
    id: root

    property string fontFamily: Config.general.fontFamily
    property var notification: null
    property real hoverPauseStart: 0
    property real progressFraction: 1.0
    property int timeoutMs: ready && notification.expireTimeout > 0
                            ? notification.expireTimeout : 5000
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

    signal dismissed
    signal expired

    function markGithubReadIfNeeded() {
        if (!root.ready || root.notification.appName !== "GitHub")
            return;

        const threadId = root.notification.hints
              ? root.notification.hints["x-github-thread-id"] : undefined;

        if (threadId)
            GitHub.markAsRead(threadId);
    }

    function dismiss() {
        expireTimer.stop();
        markGithubReadIfNeeded();
        slideOutAnim.pendingDismiss = true;
        slideOutAnim.start();
    }

    function expire() {
        slideOutAnim.pendingDismiss = false;
        slideOutAnim.start();
    }

    implicitWidth: Config.notifications.width
    implicitHeight: bodyRow.implicitHeight + (bodyRow.anchors.margins * 2)
    radius: Config.general.cornerRadius
    color: States.ecoMode ? Config.colors.bge : Config.colors.bg
    border.width: Config.general.borderWidth
    border.color: Config.colors.border

    transform: Translate {
        id: slide

        x: Config.notifications.width
    }

    Component.onCompleted: slideInAnim.start()

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

        property bool pendingDismiss: false

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
    }

    NumberAnimation {
        id: progressAnim

        target: root
        property: "progressFraction"
        from: 1.0
        to: 0.0
        duration: root.timeoutMs
        running: expireTimer.running
        easing.type: Easing.Linear
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
        implicitWidth: closeButton.implicitWidth + 12
        implicitHeight: closeButton.implicitHeight + 6
        color: Config.colors.bge
        border.width: 1
        border.color: Config.colors.accent
        radius: Config.general.cornerRadius
        z: 1

        Behavior on opacity {
            NumberAnimation {
                duration: Config.general.animDuration
                easing.type: Easing.InOutQuad
            }
        }

        anchors {
            top: parent.top
            right: parent.right
            margins: 8
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
            bottom: parent.bottom
            margins: 12
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
                    text: root.ready ? (root.notification.appName
                                        === "notify-send" ? "" :
                                                            root.notification.appName) :
                                       ""
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
                        border.color: buttonArea.containsMouse
                                      ? Config.colors.action : Config.colors.fg
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

        // progress bar
        Item {
            id: progressBarContainer

            Layout.preferredWidth: 2
            Layout.fillHeight: true

            Rectangle {
                id: progressBar

                width: parent.width
                radius: 2
                color: root.urgencyColor
                opacity: 0.9
                anchors.bottom: parent.bottom
                height: parent.height * root.progressFraction

                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.general.animDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }

    HoverHandler {
        onHoveredChanged: {
            if (hovered) {
                closeButtonCont.opacity = 1;
                progressBar.opacity = 0;
                root.hoverPauseStart = Date.now();
                root.timeoutMs = root.progressFraction * root.timeoutMs;
                progressAnim.stop();
                expireTimer.stop();
            } else {
                closeButtonCont.opacity = 0;
                progressBar.opacity = 0.9;
                expireTimer.interval = root.timeoutMs;
                progressAnim.from = root.progressFraction;
                progressAnim.duration = root.timeoutMs;
                expireTimer.restart();
                progressAnim.restart();
            }
        }
    }
}
