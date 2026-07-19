//@ pragma UseQApplication
//@ pragma NativeTextRendering

import Quickshell
import QtQuick

ShellRoot {
    Panel {}
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
