pragma Singleton

import Quickshell
import QtQuick
import QtCore

import qs

Singleton {
    function expandPath(path) {
        if (path.startsWith("~/")) {
            return StandardPaths.writableLocation(StandardPaths.HomeLocation) + path.substring(1);
        }

        return path;
    }
}
