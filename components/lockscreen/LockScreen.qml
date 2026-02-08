import Quickshell.Wayland

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls.Fusion

import "../.."

Item {
    id: root
    required property LockContext context
    readonly property bool defaultWallpaper: Config.wallpaper === States.defaultWallpaper

    opacity: 0

    Component.onCompleted: {
        opacity = 1;
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Config.animDuration * 2
            easing.type: Easing.OutQuint
        }
    }

    Image {
        source: Utils.expandPath(Config.lockWallpaper)
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

    Label {
        id: clock
        property var date: new Date()

        renderType: Text.NativeRendering
        font.pointSize: 80
        font.family: "FiraCode Nerd Font"
        font.bold: true
        color: Config.colFg

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 180
        }

        text: {
            const hours = this.date.getHours().toString().padStart(2, '0');
            const minutes = this.date.getMinutes().toString().padStart(2, '0');
            return `${hours}:${minutes}`;
        }

        Timer {
            running: true
            repeat: true
            interval: 1000
            onTriggered: clock.date = new Date()
        }
    }

    ColumnLayout {
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.verticalCenter
        }

        RowLayout {
            Item {
                implicitWidth: 400
                implicitHeight: passwordBox.implicitHeight

                TextField {
                    id: passwordBox
                    anchors.fill: parent
                    padding: 10
                    focus: true
                    enabled: !root.context.unlockInProgress
                    echoMode: TextInput.NoEcho
                    inputMethodHints: Qt.ImhSensitiveData
                    placeholderText: "PASSWORD"
                    cursorVisible: false
                    color: "transparent"
                    onAccepted: root.context.tryUnlock()

                    background: Rectangle {
                        id: blinkBorder
                        color: Config.colBg
                        radius: 8
                        border.width: 3
                        border.color: Qt.rgba(Config.colAccent.r, Config.colAccent.g, Config.colAccent.b, blinkBorder.borderOpacity)

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
                        // trigger blink on each character change
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
                }
            }

            Button {
                id: unlockBtn
                text: "UNLOCK"
                font.family: Config.fontFamily
                padding: 10
                focusPolicy: Qt.NoFocus
                enabled: !root.context.unlockInProgress && root.context.currentText !== ""
                onReleased: root.context.tryUnlock()

                contentItem: Text {
                    text: unlockBtn.text
                    font: unlockBtn.font
                    opacity: enabled ? 1.0 : 0.3
                    color: unlockBtn.down ? Config.colPurple : Config.colFg
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    implicitWidth: 100
                    implicitHeight: 40
                    color: Config.colBg
                    opacity: enabled ? 1 : 0.3
                    radius: 8
                }
            }
        }

        Label {
            visible: root.context.showFailure
            text: "Incorrect password!"
            color: Config.colYellow
            font.family: Config.fontFamily
        }
    }
}
