import QtQuick
import QtQuick.Effects

import Quickshell
import Quickshell.Wayland

import qs.core

Variants {
    id: root

    readonly property bool defaultWallpaper: Config.general.wallpaper
                                             === States.defaultWallpaper
    property bool blurred: States.blurredBackground && Config.appearance.blur

    model: Quickshell.screens

    PanelWindow {
        required property ShellScreen modelData

        screen: modelData
        color: root.defaultWallpaper ? "black" : "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        Image {
            id: wallpaperImage

            anchors.fill: parent
            cache: false
            source: Utils.expandPath(Config.general.wallpaper)
            fillMode: root.defaultWallpaper ? Image.Pad :
                                              Image.PreserveAspectCrop
            opacity: 0
            layer.enabled: root.blurred

            layer.effect: MultiEffect {
                blurEnabled: root.blurred
                blur: 0.95
                blurMax: 42
                blurMultiplier: 0.3
                shadowEnabled: Config.appearance.shadows
                shadowColor: Config.colors.bge
                autoPaddingEnabled: Config.appearance.shadows
            }

            SequentialAnimation {
                running: wallpaperImage.status === Image.Ready

                NumberAnimation {
                    target: wallpaperImage
                    property: "opacity"
                    from: 0
                    to: 1.0
                    duration: 65
                    easing.type: Easing.InExpo
                }
            }
        }
    }
}
