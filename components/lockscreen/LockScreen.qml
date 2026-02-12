pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls.Fusion

import "../widgets"
import "../.."
import ".."

Item {
    id: root

    property string fullName: ""

    readonly property string userName: Quickshell.env("USER")
    readonly property bool defaultWallpaper: Config.lockscreen.wallpaper === States.defaultWallpaper

    required property LockContext context

    opacity: 0

    Component.onCompleted: {
        opacity = 1;
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Config.general.animDuration * 2
            easing.type: Easing.OutQuint
        }
    }

    Process {
        running: true
        command: ["sh", "-c", "getent passwd " + root.userName]
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = this.text.split(":");

                if (parts.length >= 5) {
                    root.fullName = parts[4].trim();
                }
            }
        }
    }

    Process {
        id: reboot
        command: ["sh", "-c", Config.logout.commands.reboot]
    }

    Process {
        id: suspend
        command: ["sh", "-c", Config.logout.commands.suspend]
    }

    Process {
        id: shutdown
        command: ["sh", "-c", Config.logout.commands.shutdown]
    }

    Image {
        source: Utils.expandPath(Config.lockscreen.wallpaper)
        cache: false
        anchors.fill: parent
        fillMode: root.defaultWallpaper ? Image.Pad : Image.PreserveAspectCrop
        layer.enabled: true

        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 0.65
            blurMax: 64
            autoPaddingEnabled: false
        }
    }

    Loader {
        id: clock
        active: Config.lockscreen.clock
        visible: clock.active
        asynchronous: true

        anchors {
            top: parent.top
            left: parent.left
            topMargin: 40
            leftMargin: 40
        }

        sourceComponent: Item {
            RowLayout {
                spacing: 12

                Rectangle {
                    width: clockRow.implicitWidth + 22
                    height: clockRow.implicitHeight + 12
                    color: Config.colors.bg
                    radius: Config.general.cornerRadius

                    RowLayout {
                        id: clockRow
                        anchors.centerIn: parent
                        spacing: 0

                        Item {
                            implicitWidth: 70
                            implicitHeight: 30

                            Rectangle {
                                id: clockRect
                                anchors.fill: parent
                                radius: Config.general.cornerRadius
                                color: "transparent"
                                anchors.topMargin: 4

                                property var currentTime: new Date()

                                Text {
                                    text: Qt.formatDateTime(clockRect.currentTime, "HH:mm")
                                    font.pixelSize: 22
                                    color: Config.colors.fg
                                    font.family: "FiraCode Nerd Font"
                                    font.bold: true
                                    anchors.centerIn: parent
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: battRow.implicitWidth + 22
                    height: battRow.implicitHeight + 12
                    color: Config.colors.bg
                    radius: Config.general.cornerRadius

                    RowLayout {
                        id: battRow
                        anchors.centerIn: parent
                        spacing: 0

                        Item {
                            implicitWidth: battIcon.implicitWidth
                            implicitHeight: 30

                            Rectangle {
                                id: battRect
                                anchors.fill: parent
                                radius: Config.general.cornerRadius
                                color: "transparent"

                                Text {
                                    id: battIcon
                                    text: States.battery.getIcon()
                                    font.pixelSize: 22
                                    color: Config.colors.fg
                                    font.family: "FiraCode Nerd Font"
                                    font.bold: true
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Loader {
        id: buttons
        active: Config.lockscreen.buttons
        visible: buttons.active
        asynchronous: true

        anchors {
            top: parent.top
            right: parent.right
            topMargin: 40
            rightMargin: 40
        }

        sourceComponent: Rectangle {
            width: buttonsRow.implicitWidth + 18
            height: buttonsRow.implicitHeight + 12
            color: Config.colors.bg
            radius: Config.general.cornerRadius

            RowLayout {
                id: buttonsRow
                anchors.centerIn: parent
                spacing: 12

                Item {
                    implicitWidth: 30
                    implicitHeight: 30

                    Rectangle {
                        anchors.fill: parent
                        radius: Config.general.cornerRadius
                        color: powerMouseArea.containsMouse ? Config.colors.fg : "transparent"

                        Text {
                            text: "󰤆"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 22
                            font.bold: true
                            anchors.centerIn: parent
                            color: powerMouseArea.containsMouse ? Config.colors.accent : Config.colors.fg

                            Behavior on color {
                                ColAnim {}
                            }
                        }

                        Behavior on color {
                            ColAnim {}
                        }
                    }

                    MouseArea {
                        id: powerMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: shutdown.running = true
                    }
                }

                // sleep
                Item {
                    implicitWidth: 30
                    implicitHeight: 30

                    Rectangle {
                        anchors.fill: parent
                        radius: Config.general.cornerRadius
                        color: sleepMouseArea.containsMouse ? Config.colors.fg : "transparent"

                        Text {
                            text: ""
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 22
                            font.bold: true
                            anchors.centerIn: parent
                            color: sleepMouseArea.containsMouse ? Config.colors.accent : Config.colors.fg

                            Behavior on color {
                                ColAnim {}
                            }
                        }

                        Behavior on color {
                            ColAnim {}
                        }
                    }

                    MouseArea {
                        id: sleepMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: suspend.running = true
                    }
                }

                // reboot
                Item {
                    implicitWidth: 30
                    implicitHeight: 30

                    Rectangle {
                        anchors.fill: parent
                        radius: Config.general.cornerRadius
                        color: rebootMouseArea.containsMouse ? Config.colors.fg : "transparent"

                        Text {
                            text: "󰑐"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 22
                            font.bold: true
                            anchors.centerIn: parent
                            color: rebootMouseArea.containsMouse ? Config.colors.accent : Config.colors.fg

                            Behavior on color {
                                ColAnim {}
                            }
                        }

                        Behavior on color {
                            ColAnim {}
                        }
                    }

                    MouseArea {
                        id: rebootMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: reboot.running = true
                    }
                }
            }
        }
    }

    ColumnLayout {
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
            bottomMargin: 200
        }

        Loader {
            active: Config.lockscreen.icon
            visible: Config.lockscreen.icon
            asynchronous: true
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 160
            Layout.preferredHeight: 160

            sourceComponent: Item {
                Loader {
                    active: Config.lockscreen.shadows
                    visible: Config.lockscreen.shadows
                    anchors.fill: parent

                    sourceComponent: RectangularShadow {
                        offset.x: 0
                        offset.y: 0
                        radius: width / 2
                        blur: 30
                        spread: 10
                        color: Qt.rgba(0, 0, 0, 0.3)
                    }
                }

                Image {
                    id: userImage
                    source: Utils.expandPath("~/.face.icon")
                    anchors.fill: parent
                    visible: false
                }

                MultiEffect {
                    id: maskedImage
                    source: userImage
                    anchors.fill: parent
                    maskEnabled: true
                    maskSource: mask
                    // smooth image
                    maskThresholdMin: 0.5
                    maskSpreadAtMin: 1.0
                }

                Item {
                    id: mask
                    anchors.fill: parent
                    layer.enabled: true
                    //layer.smooth: true
                    visible: false

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: "black"
                    }
                }
            }
        }

        Loader {
            active: Config.lockscreen.username
            visible: Config.lockscreen.username
            asynchronous: true
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 18

            sourceComponent: Item {
                implicitWidth: usernameRect.implicitWidth
                implicitHeight: usernameRect.implicitHeight

                Loader {
                    active: Config.lockscreen.shadows
                    visible: Config.lockscreen.shadows
                    asynchronous: true
                    anchors.fill: usernameRect
                    anchors.margins: -10

                    sourceComponent: RectangularShadow {
                        offset.x: 0
                        offset.y: 0
                        radius: 8
                        blur: 30
                        spread: 10
                        color: Qt.rgba(0, 0, 0, 0.3)
                    }
                }

                Rectangle {
                    id: usernameRect
                    implicitWidth: usernameText.implicitWidth + 20
                    implicitHeight: usernameText.implicitHeight + 12
                    color: Config.colors.bg
                    radius: 8
                    //border.width: 1
                    //border.color: Config.colors.passive

                    Text {
                        id: usernameText
                        anchors.centerIn: parent
                        text: root.fullName || root.userName
                        color: Config.colors.fg
                        font.family: Config.general.fontFamily
                        font.pixelSize: 18
                        font.bold: false
                    }
                }
            }
        }

        RowLayout {
            Item {
                implicitWidth: 400
                implicitHeight: passwordBox.implicitHeight
                Layout.topMargin: 18

                Loader {
                    active: Config.lockscreen.shadows
                    visible: Config.lockscreen.shadows
                    asynchronous: true
                    anchors.fill: passwordBox
                    anchors.margins: -10

                    sourceComponent: RectangularShadow {
                        offset.x: 0
                        offset.y: 0
                        radius: 8
                        blur: 30
                        spread: 10
                        color: Qt.rgba(0, 0, 0, 0.3)
                    }
                }

                TextField {
                    id: passwordBox
                    anchors.fill: parent
                    padding: 10
                    focus: true
                    enabled: !root.context.unlockInProgress
                    echoMode: TextInput.NoEcho
                    inputMethodHints: Qt.ImhSensitiveData
                    color: "transparent"
                    onAccepted: root.context.tryUnlock()

                    background: Rectangle {
                        id: blinkBorder
                        color: Config.colors.bg
                        radius: 8
                        border.width: 2
                        border.color: Qt.rgba(Config.colors.accent.r, Config.colors.accent.g, Config.colors.accent.b, blinkBorder.borderOpacity)

                        property real borderOpacity: 0

                        SequentialAnimation {
                            id: blinkAnimation

                            NumberAnimation {
                                target: blinkBorder
                                property: "borderOpacity"
                                to: 1
                                duration: 120
                            }

                            NumberAnimation {
                                target: blinkBorder
                                property: "borderOpacity"
                                to: 0
                                duration: 120
                            }
                        }
                    }

                    onTextChanged: {
                        root.context.currentText = this.text;

                        if (this.text.length > 0) {
                            blinkAnimation.restart();
                        }
                    }

                    Connections {
                        target: root.context

                        function onCurrentTextChanged() {
                            passwordBox.text = root.context.currentText;
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: root.context.showFailure ? "INCORRECT PASSWORD" : "PASSWORD"
                        color: root.context.showFailure ? Config.colors.red : Config.colors.fg
                        opacity: root.context.showFailure ? 1 : 0.5
                        font.family: Config.general.fontFamily
                        font.bold: false
                        font.pixelSize: passwordBox.font.pixelSize
                        visible: passwordBox.text.length === 0
                    }
                }
            }
        }
    }
}
