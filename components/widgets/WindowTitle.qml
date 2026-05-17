import Quickshell.Wayland

import QtQuick
import QtQuick.Layouts

import "../bar"
import "../dashboard"
import "../.."
import ".."

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

    property string fullTitle: ToplevelManager.activeToplevel ? ToplevelManager.activeToplevel.title : emptyTitle
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
            family: activeWindowTitle.text === root.emptyTitle ? "Symbols Nerd Font" : root.fontFamily
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
            family: newTitle.text === root.emptyTitle ? "Symbols Nerd Font" : root.fontFamily
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
        hoverEnabled: !States.ecoMode

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
