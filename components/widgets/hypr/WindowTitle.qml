import Quickshell.Hyprland

import Quickshell
import QtQuick

import "../../.."

Item {
    property string fullTitle: {
        var win = Hyprland.activeToplevel;
        if (!win || !win.title || win.title.trim() === "") {
            return Config.bar.title.empty;
        }

        // check if the workspace has any windows
        var focusedWorkspace = Hyprland.focusedWorkspace;
        if (focusedWorkspace) {
            var currentWorkspace = Hyprland.workspaces.values.find(w => w.id === focusedWorkspace.id);
            if (currentWorkspace && currentWorkspace.toplevels && currentWorkspace.toplevels.values) {
                var windowCount = currentWorkspace.toplevels.values.length;
                if (windowCount === 0) {
                    return Config.bar.title.empty;
                }
            }
        }

        return win.title.trim();
    }
}
