import Quickshell
import Quickshell.Wayland

import QtQuick

import "components"

Variants {
    id: root
    model: Quickshell.screens

    readonly property bool defaultWallpaper: Config.wallpaper === States.defaultWallpaper

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
            source: Utils.expandPath(Config.wallpaper)
            fillMode: root.defaultWallpaper ? Image.Pad : Image.PreserveAspectCrop
            opacity: 0

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
