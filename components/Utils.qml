pragma Singleton

import Quickshell
import QtQuick
import QtCore

Singleton {
    function getPropertyCount(obj) {
        if (!obj || typeof obj !== "object")
            return 0;

        var count = 0;

        for (var key in obj) {
            var isEventHandler = key.startsWith("on") && key.length > 2 && key[2] === key[2].toUpperCase();

            if (obj.hasOwnProperty(key) && typeof obj[key] !== "function" && !isEventHandler && key !== "objectName" && key !== "objectNameChanged") {
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
