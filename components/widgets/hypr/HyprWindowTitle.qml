import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts

import "../../bar"
import "../../dashboard"
import "../../.."

Item {
    id: root
    Layout.alignment: Qt.AlignVCenter
    implicitHeight: Config.general.fontSize + 2

    property int fontSize: Config.general.fontSize
    property int length: 80
    property string fontFamily: "JetBrainsMono Nerd Font"
    property color colFg: Config.colors.fg
    property color colPassive: Qt.darker(Config.colors.passive, 1.5)
    property int animDuration: Config.general.animDuration
    property string emptyTitle: Config.bar.title.empty

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
        fadeAnimation.restart();
    }

    SequentialAnimation {
        id: fadeAnimation

        ParallelAnimation {
            NumberAnimation {
                target: activeWindowTitle
                property: "opacity"
                to: 0
                duration: 180
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: newTitle
                property: "opacity"
                from: 0
                to: 1
                duration: 180
                easing.type: Easing.InOutQuad
            }
        }
        ScriptAction {
            script: {
                activeWindowTitle.text = newTitle.text;
                activeWindowTitle.opacity = 1;
                newTitle.opacity = 0;
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
        anchors.centerIn: parent
        width: parent.width
        text: parent.displayText
        renderType: Text.NativeRendering
        color: root.colFg
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        font {
            family: root.displayText === root.emptyTitle ? "Symbols Nerd Font" : root.fontFamily
            pixelSize: root.fontSize
            bold: true
        }

        opacity: 1
    }

    Text {
        id: newTitle
        anchors.centerIn: parent
        width: parent.width
        renderType: Text.NativeRendering
        color: root.colFg
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        font {
            family: root.displayText === root.emptyTitle ? "Symbols Nerd Font" : root.fontFamily
            pixelSize: root.fontSize
            bold: true
        }

        opacity: 0
    }

    Dropdown {
        id: dashboard
        boxParent: root

        Rectangle {
            color: "transparent"
            radius: Config.general.cornerRadius
            implicitWidth: layout.implicitWidth + 651
            implicitHeight: layout.implicitHeight + (Config.general.borderWidth > 0 ? 424 : 420)

            ColumnLayout {
                id: layout

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    Dashboard {}
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            hoverActiveWindow.opacity = 1;
            dashboard.show = true;
            States.dashboardPresent = true;
        }

        onExited: {
            dashboard.timer.start();
            hoverActiveWindow.opacity = 0;
        }
    }
}
