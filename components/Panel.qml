import QtQuick

import Quickshell
import Quickshell.Io

import qs.bar
import qs.core

PanelWindow {
    id: root

    color: "transparent"

    Variants {
        id: bars

        model: Quickshell.screens

        delegate: Bar {}
    }

    IpcHandler {
        function hide() {
            States.barEnabled = false;
            for (const b of bars.instances)
                b.hidden(true);
        }

        function reveal() {
            States.barEnabled = true;
            for (const b of bars.instances)
                b.hidden(false);
        }

        target: "bar"
    }

    Backend {}
}
