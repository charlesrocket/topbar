pragma Singleton

import Quickshell
import QtQuick
import QtCore

import qs

Singleton {
    function getPropertyCount(obj) {
        var keys = Object.keys(obj);
        var count = 0;

        for (var i = 0; i < keys.length; i++) {
            var key = keys[i];
            // skip functions and signal handlers
            if (obj.hasOwnProperty(key) && typeof obj[key] !== "function" && !key.startsWith("on") && key !== "objectName") {
                count++;
            }
        }

        return count;
    }

    function expandPath(path) {
        if (path.startsWith("~/")) {
            return StandardPaths.writableLocation(StandardPaths.HomeLocation) + path.substring(1);
        }

        return path;
    }
}
