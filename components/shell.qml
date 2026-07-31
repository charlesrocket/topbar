//@ pragma UseQApplication
//@ pragma NativeTextRendering

import QtQuick

import Quickshell

ShellRoot {
    Component.onCompleted: {
        Quickshell.watchFiles = false;
    }

    Panel {}

    Wallpaper {}

    Connections {
        function onLastWindowClosed() {
            Qt.quit();
        }

        target: Quickshell
    }
}
