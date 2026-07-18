//@ pragma UseQApplication
//@ pragma NativeTextRendering

import Quickshell
import QtQuick

ShellRoot {
    TopBar {}
    Wallpaper {}

    Connections {
        target: Quickshell

        function onLastWindowClosed() {
            Qt.quit();
        }
    }

    Component.onCompleted: {
        Quickshell.watchFiles = false;
    }
}
