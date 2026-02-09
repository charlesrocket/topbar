import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts

import "../.."
import ".."

Item {
    id: root
    implicitHeight: activeWindowTitle.implicitHeight

    property int fontSize: 14
    property int length: 80
    property string fontFamily: "JetBrainsMono Nerd Font"
    property color colFg: Config.colors.fg
    property color colPassive: Qt.darker(Config.colors.passive, 1.5)
    property int animDuration: Config.general.animDuration
    property string emptyTitle: Config.bar.emptyWindowTitle
    property string fullTitle: {
        var win = Hyprland.activeToplevel;

        if (!win || !win.title || win.title.trim() === "") {
            return root.emptyTitle;
        }

        // check if the workspace has any windows
        var focusedWorkspace = Hyprland.focusedWorkspace;

        if (focusedWorkspace) {
            var currentWorkspace = Hyprland.workspaces.values.find(w => w.id === focusedWorkspace.id);

            if (currentWorkspace && currentWorkspace.toplevels && currentWorkspace.toplevels.values) {
                var windowCount = currentWorkspace.toplevels.values.length;

                if (windowCount === 0) {
                    return root.emptyTitle;
                }
            }
        }

        return win.title.trim();
    }

    property string displayText: fullTitle === root.emptyTitle ? fullTitle : (fullTitle.length > root.length ? fullTitle.substring(0, root.length - 3) + "..." : fullTitle)

    onDisplayTextChanged: {
        newTitle.text = displayText;
        newTitle.y = height;
        slideAnimation.restart();
    }

    SequentialAnimation {
        id: slideAnimation

        ParallelAnimation {
            NumberAnimation {
                target: activeWindowTitle
                property: "y"
                to: -activeWindowTitle.height
                duration: 50
                easing.type: Easing.InOutCubic
            }

            NumberAnimation {
                target: newTitle
                property: "y"
                to: 0
                duration: 50
                easing.type: Easing.InOutCubic
            }
        }

        ScriptAction {
            script: {
                activeWindowTitle.text = newTitle.text;
                activeWindowTitle.y = 0;
            }
        }
    }

    HoverFrame {
        id: hoverActiveWindow
        anchors.fill: parent
        frameColor: root.colPassive
        animDuration: root.animDuration
    }

    Text {
        id: activeWindowTitle
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height
        width: parent.width
        y: 0

        text: parent.displayText
        color: root.colFg
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        font {
            family: root.fontFamily
            pixelSize: root.fontSize
            bold: true
        }
    }

    Text {
        id: newTitle
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height
        width: parent.width
        y: parent.height

        color: root.colFg
        elide: Text.ElideRight

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        font {
            family: root.fontFamily
            pixelSize: root.fontSize
            bold: true
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onEntered: hoverActiveWindow.opacity = 1
        onExited: hoverActiveWindow.opacity = 0
    }
}
