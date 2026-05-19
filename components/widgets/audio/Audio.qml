import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Layouts

import TopBar.OSS

import "../../.."
import "../.."

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
                duration: Config.general.animDuration
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
                duration: Config.general.animDuration
                easing.type: Easing.OutCubic
            }
        }

        Connections {
            target: speaker.control

            function onMutedChanged() {
                sound.refresh();

                if (!speaker.menuAlias.show && Config.desktop.osd)
                    audioOSD.item.trigger();
            }

            // should be enough for now
            function onLeftChanged() {
                sound.refresh();

                if (!speaker.menuAlias.show && Config.desktop.osd)
                    audioOSD.item.trigger();
            }
        }

        Loader {
            id: audioOSD
            active: Config.desktop.osd
            visible: audioOSD.active
            asynchronous: true

            sourceComponent: OSD {
                icon: speaker.iconAlias.text
                value: speaker.volume
                muted: speaker.muted
            }
        }

        IpcHandler {
            target: "audio"

            function toggleMute(): void {
                if (speaker.control) {
                    speaker.control.muted = !speaker.control.muted;
                }
            }

            function volumeUp(): void {
                if (speaker.control) {
                    speaker.control.left = speaker.control.left + 5;
                    speaker.control.right = speaker.control.right + 5;

                    if (Config.desktop.osd)
                        audioOSD.item.trigger();
                }
            }

            function volumeDown(): void {
                if (speaker.control) {
                    speaker.control.left = speaker.control.left - 5;
                    speaker.control.right = speaker.control.right - 5;

                    if (Config.desktop.osd)
                        audioOSD.item.trigger();
                }
            }
        }
    }
}
