import Quickshell.Services.OSS

import QtQuick
import QtQuick.Layouts

import "../bar"
import "../.."
import ".."

Item {
    id: root

    property bool mic: false
    property bool osd: false
    property int deviceId: -1
    property int barLen: 80
    property int iconSize: 16
    property color colNormal: Config.colors.fg
    property color colPassive: Config.colors.passive
    property color colMuted: Config.colors.red

    Layout.alignment: Qt.AlignVCenter
    implicitWidth: iconText.width
    implicitHeight: iconText.height

    readonly property var device: {
        if (!OSS.devices)
            return null;

        if (root.deviceId >= 0) {
            for (var i = 0; i < OSS.devices.length; i++) {
                if (OSS.devices[i].deviceId === root.deviceId) {
                    return OSS.devices[i];
                }
            }

            return null;
        }

        return OSS.defaultDevice;
    }

    property var control: {
        if (!device || !device.controls)
            return null;

        if (root.mic) {
            for (var i = 0; i < device.controls.length; i++) {
                var devCtl = device.controls[i];
                var trimmedName = devCtl.name.trim().toLowerCase();

                if (trimmedName === "rec")
                    return devCtl;
            }

            for (var i = 0; i < device.controls.length; i++) {
                var devCtl = device.controls[i];
                var trimmedName = devCtl.name.trim().toLowerCase();

                if (trimmedName === "mic")
                    return devCtl;
            }

            return null;
        }

        return device.master;
    }

    readonly property int volume: control ? control.left : 0
    readonly property bool muted: control ? control.muted : false

    function getVolumeIcon(vol, isMuted) {
        if (!mic) {
            if (isMuted || vol === 0)
                return "󰝟";

            return "󰕾";
        } else {
            if (isMuted || vol === 0)
                return "󰍭";

            return "󰍬";
        }
    }

    Text {
        id: iconText
        anchors.centerIn: parent
        text: root.getVolumeIcon(root.volume, root.muted)
        color: root.muted ? root.colMuted : root.colNormal
        font.family: "Symbols Nerd Font"
        font.pixelSize: root.iconSize
        font.bold: true

        Behavior on color {
            ColorAnimation {
                duration: Config.general.animDuration
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Config.general.animDuration
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Config.general.animDuration
                easing.type: Easing.InOutQuad
            }
        }

        onTextChanged: {
            scaleAnimation.restart();
        }

        SequentialAnimation {
            id: scaleAnimation

            NumberAnimation {
                target: iconText
                property: "scale"
                to: 0.8
                duration: 75
                easing.type: Easing.InQuad
            }

            NumberAnimation {
                target: iconText
                property: "scale"
                to: 1.0
                duration: 75
                easing.type: Easing.OutQuad
            }
        }
    }

    MouseArea {
        id: hoverDetector
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            OSS.refresh();
            volumeMenu.show = true;
        }

        onExited: {
            volumeMenu.timer.start();
        }

        onClicked: {
            if (root.control) {
                root.control.muted = !root.control.muted;
            }
        }
    }

    Dropdown {
        id: volumeMenu
        boxParent: iconText

        Rectangle {
            color: States.ecoMode ? Config.colors.bge : Config.colors.bg
            radius: Config.general.cornerRadius
            border.color: Config.colors.border
            border.width: 1
            topLeftRadius: 0
            topRightRadius: 0
            implicitWidth: layout.implicitWidth + 24
            implicitHeight: layout.implicitHeight + 24

            ColumnLayout {
                id: layout
                anchors.centerIn: parent
                anchors.margins: 12
                spacing: 8

                Text {
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredWidth: 26
                    horizontalAlignment: Text.AlignHCenter
                    text: root.volume
                    color: root.muted ? root.colPassive : root.colNormal
                    font.pixelSize: Config.general.fontSize
                    font.family: Config.general.fontFamily
                    font.bold: true

                    Behavior on color {
                        ColorAnimation {
                            duration: Config.general.animDuration
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                Item {
                    Layout.fillHeight: false
                    Layout.preferredHeight: root.barLen
                    Layout.preferredWidth: 20
                    Layout.alignment: Qt.AlignHCenter

                    Rectangle {
                        id: sliderTrack
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        height: root.barLen
                        width: 4
                        radius: 6
                        color: Config.colors.passive

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            height: parent.height * (root.volume / 100)
                            width: parent.width
                            radius: parent.radius
                            color: root.muted ? root.colPassive : root.colNormal

                            Behavior on height {
                                NumberAnimation {
                                    duration: 50
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: sliderHandle
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 12
                        height: 12
                        radius: 6
                        color: root.muted ? root.colMuted : root.colNormal
                        border.width: 2
                        border.color: root.colNormal
                        y: (sliderTrack.height - height) * (1 - root.volume / 100)

                        Behavior on y {
                            NumberAnimation {
                                duration: 50
                                easing.type: Easing.OutQuad
                            }
                        }
                    }

                    MouseArea {
                        id: sliderMouseArea
                        anchors.fill: parent
                        hoverEnabled: true

                        function updateVolume(mouseY) {
                            if (root.control) {
                                var newVolume = Math.max(0, Math.min(100, Math.round((1 - mouseY / height) * 100)));

                                root.control.left = newVolume;
                                root.control.right = newVolume;
                            }
                        }

                        onPressed: function (mouse) {
                            updateVolume(mouse.y);
                        }

                        onPositionChanged: function (mouse) {
                            if (pressed)
                                updateVolume(mouse.y);
                        }
                    }
                }
            }
        }
    }

    Timer {
        interval: 200
        repeat: true
        onTriggered: OSS.refresh()

        running: OSS.devices ? (hoverDetector.containsMouse || volumeMenu.show) : false
    }

    Connections {
        target: root.control

        function onMutedChanged() {
            OSS.refresh();

            if (!volumeMenu.show && root.osd && Config.desktop.osd)
                audioOSD.item.trigger();
        }

        // should be enough for now
        function onLeftChanged() {
            OSS.refresh();

            if (!volumeMenu.show && root.osd && Config.desktop.osd)
                audioOSD.item.trigger();
        }
    }

    Loader {
        id: audioOSD
        active: Config.desktop.osd && root.osd
        visible: audioOSD.active
        asynchronous: true

        sourceComponent: Osd {
            icon: iconText.text
            value: root.volume
        }
    }
}
