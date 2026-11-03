import QtQuick
import QtQuick.Layouts

import Quickshell.Io

import TopBar.OSS

import qs
import qs.core

RowLayout {
    Layout.alignment: Qt.AlignVCenter
    anchors.right: parent.right
    spacing: 6

    OSS {
        id: sound
    }

    // devices
    Devices {
        snd: sound
    }

    // mic
    Unit {
        id: mic

        mic: true
        opacity: mic.control ? 1 : 0
        visible: opacity > 0
        snd: sound

        Behavior on opacity {
            NumberAnimation {
                duration: Config.appearance.animDuration
                easing.type: Easing.OutCubic
            }
        }
    }

    // speaker
    Unit {
        id: speaker

        opacity: speaker.control ? 1 : 0
        visible: opacity > 0
        snd: sound

        Behavior on opacity {
            NumberAnimation {
                duration: Config.appearance.animDuration
                easing.type: Easing.OutCubic
            }
        }

        Connections {
            function onMutedChanged() {
                if (States.dropdownOwner !== null)
                    return;
                if (speaker.isInteracting)
                    return;

                States.requestOsd(speaker.iconAlias.text, speaker.volume,
                                  speaker.muted);
            }

            function onLeftChanged() {
                if (States.dropdownOwner !== null)
                    return;
                if (speaker.isInteracting)
                    return;

                States.requestOsd(speaker.iconAlias.text, speaker.volume,
                                  speaker.muted);
            }

            target: speaker.control
        }

        IpcHandler {
            function toggleMute(): void {
            if (speaker.control) {
                speaker.control.muted = !speaker.control.muted;
            }
            }

                function volumeUp(): void {
                                         if (speaker.control) {
                                             speaker.control.left
                                             = speaker.control.left + 5;
                                             speaker.control.right
                                             = speaker.control.right + 5;
                                         }
                                     }

                function volumeDown(): void {
                if (speaker.control) {
                    speaker.control.left = speaker.control.left - 5;
                    speaker.control.right = speaker.control.right - 5;
                }
                }

                    target: "audio"
                }
            }
        }
