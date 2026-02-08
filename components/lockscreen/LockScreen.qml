pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls.Fusion

import "../.."

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
            duration: Config.animDuration * 2
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
                        color: Qt.rgba(0, 0, 0, 0.5)
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
                    anchors.fill: usernameRect
                    anchors.margins: -10

                    sourceComponent: RectangularShadow {
                        offset.x: 0
                        offset.y: 0
                        radius: 8
                        blur: 30
                        spread: 10
                        color: Qt.rgba(0, 0, 0, 0.5)
                    }
                }

                Rectangle {
                    id: usernameRect
                    implicitWidth: usernameText.implicitWidth + 20
                    implicitHeight: usernameText.implicitHeight + 12
                    color: Config.colBg
                    radius: 8
                    //border.width: 1
                    //border.color: Config.colPassive

                    Text {
                        id: usernameText
                        anchors.centerIn: parent
                        text: root.fullName || root.userName
                        color: Config.colFg
                        font.family: Config.fontFamily
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
                    anchors.fill: passwordBox
                    anchors.margins: -10

                    sourceComponent: RectangularShadow {
                        offset.x: 0
                        offset.y: 0
                        radius: 8
                        blur: 30
                        spread: 10
                        color: Qt.rgba(0, 0, 0, 0.5)
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
                        color: Config.colBg
                        radius: 8
                        border.width: 2
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
                        color: root.context.showFailure ? Config.colRed : Config.colFg
                        opacity: root.context.showFailure ? 1 : 0.5
                        font.family: Config.fontFamily
                        font.bold: false
                        font.pixelSize: passwordBox.font.pixelSize
                        visible: passwordBox.text.length === 0
                    }
                }
            }
        }
    }
}
