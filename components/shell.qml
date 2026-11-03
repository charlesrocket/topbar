//@ pragma UseQApplication
//@ pragma NativeTextRendering

import QtQuick

import Quickshell

import qs.core

ShellRoot {
    Component.onCompleted: {
        Quickshell.watchFiles = false;
    }

    Panel {}

    Backend {}

    Connections {
        function onLastWindowClosed() {
            Qt.quit();
        }

        target: Quickshell
    }
}
