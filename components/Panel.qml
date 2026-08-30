import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import qs.bar as Bar
import qs.core

PanelWindow {
    id: root

    function getAllVisibleItems() {
        const items = [];

        function collect(item) {
            if (!item)
                return;

            items.push(item);

            for (const child of item.children) {
                if (child.visible) {
                    collect(child);
                }
            }
        }

        collect(root.contentItem);
        return items;
    }

    mask: itemsRegions
    color: "transparent"
    implicitHeight: screen.height
    exclusiveZone: bar.visible ? bar.height + Config.bar.padding : 0
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "topbar"

    anchors {
        top: true
        left: true
        right: true
    }

    ColAnim {}

    Rectangle {
        id: bar

        function hidden(val) {
            if (val) {
                bar.y = -(Config.bar.height);
                hideTimer.start();
            } else {
                States.barEnabled = true;
                bar.y = Config.bar.padding;
                bar.visible = true;
            }
        }

        y: Config.bar.padding
        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: root.screen.width - Config.bar.padding * 2
        implicitHeight: Config.bar.height
        height: Config.bar.height
        color: States.ecoMode ? Config.colors.bge : Config.colors.bg
        radius: Config.appearance.cornerRadius

        //Bar.DynamicFrame {
        //    barWidth: bar.width
        //    barHeight: bar.height
        //}

        Behavior on y {
            NumberAnimation {
                duration: Config.appearance.animDuration * 2
                easing.type: Easing.OutQuint
            }
        }

        // startup animation
        transform: Translate {
            id: launchSequence

            y: -(root.implicitHeight)

            Behavior on y {
                NumberAnimation {
                    duration: Config.appearance.animDuration * 5
                    easing.type: Easing.OutQuint
                }
            }
        }

        Component.onCompleted: {
            launchSequence.y = 0;
            States.barPanel = root;
        }

        // sections
        Loader {
            active: States.barEnabled
            visible: States.barEnabled
            Layout.alignment: Qt.AlignCenter
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12

            sourceComponent: RowLayout {
                Bar.Left {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Layout.alignment: Qt.AlignLeft
                }

                Bar.Center {
                    Layout.fillWidth: false
                    Layout.preferredWidth: 400
                    Layout.alignment: Qt.AlignHCenter
                }

                Bar.Right {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Layout.alignment: Qt.AlignRight
                }
            }
        }

        Timer {
            id: hideTimer

            interval: Config.appearance.animDuration * 2

            onTriggered: {
                bar.visible = false;
                States.barEnabled = false;
            }
        }
    }

    Region {
        id: itemsRegions

        regions: regions.instances
    }

    Variants {
        id: regions

        model: States.dropdownRevealed ? getAllVisibleItems() :
                                         root.contentItem.children

        delegate: Region {
            required property Item modelData

            item: modelData
        }
    }

    Connections {
        function onDropdownRevealedChanged() {
            regions.model = States.dropdownRevealed ? getAllVisibleItems() :
                                                      root.contentItem.children;
            itemsRegions.changed();
        }

        target: States
    }

    Connections {
        // post-start region refresh
        function onYChanged() {
            itemsRegions.changed();
        }

        target: launchSequence
    }

    IpcHandler {
        function hide() {
            bar.hidden(true);
        }

        function reveal() {
            bar.hidden(false);
        }

        target: "bar"
    }

    Backend {}
}
