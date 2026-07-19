import QtQuick
import QtQuick.Shapes

import ".."

Item {
    id: root

    property alias timer: hideTimer
    property bool show: false
    property int offset: 0

    required property var boxParent

    default property alias content: contentArea.data

    Item {
        id: dropdown

        visible: false
        width: contentArea.implicitWidth
        height: contentArea.implicitHeight

        x: {
            const mapped = root.boxParent.mapToItem(root.boxParent, 0, 0);
            return mapped.x + (root.boxParent.width / 2) - (dropdown.width / 2);
        }
        y: {
            if (root.offset > 0) {
                return root.offset;
            }

            let topItem = root.parent;
            while (topItem && topItem.parent) {
                topItem = topItem.parent;
            }

            if (topItem) {
                const boxToTop = root.boxParent.mapToItem(topItem, 0, 0);
                const parentToTop = root.parent.mapToItem(topItem, 0, 0);
                const result = boxToTop.y - parentToTop.y + root.boxParent.height + (Config.bar.padding) - 1;
                return result;
            }

            const mapped = root.boxParent.mapToItem(root.parent, 0, 0);
            const result = mapped.y + root.boxParent.height + (Config.bar.padding) - 1;
            return result;
        }

        opacity: 0
        scale: 0
        transformOrigin: Item.Top

        states: [
            State {
                name: "visible"
                when: root.show

                PropertyChanges {
                    target: dropdown
                    opacity: 1
                    scale: 1
                }
            },
            State {
                name: "hidden"
                when: !root.show

                PropertyChanges {
                    target: dropdown
                    opacity: 0
                    scale: 0.65
                }
            }
        ]

        transitions: [
            Transition {
                from: "hidden"
                to: "visible"
                SequentialAnimation {
                    PropertyAction {
                        target: dropdown
                        property: "visible"
                        value: true
                    }

                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            duration: Config.general.animDuration / 2
                            easing.type: Easing.OutCubic
                        }

                        NumberAnimation {
                            property: "scale"
                            duration: Config.general.animDuration / 2
                            easing.type: Easing.OutCubic
                        }
                    }

                    PropertyAction {
                        target: States
                        property: "dropdownRevealed"
                        value: true
                    }
                }
            },
            Transition {
                from: "visible"
                to: "hidden"

                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            duration: Config.general.animDuration / 2
                            easing.type: Easing.InCubic
                        }

                        NumberAnimation {
                            property: "scale"
                            duration: Config.general.animDuration / 2
                            easing.type: Easing.InCubic
                        }
                    }

                    PropertyAction {
                        target: dropdown
                        property: "visible"
                        value: false
                    }

                    ScriptAction {
                        script: {
                            if (States.dropdownOwner === root) {
                                States.dropdownX = 0;
                                States.dropdownWidth = 0;
                                States.dropdownHeight = 0;
                                States.dropdownY = 0;
                                States.dropdownOwner = null;
                            }
                        }
                    }
                }
            }
        ]

        Shape {
            id: ramp
            preferredRendererType: Shape.CurveRenderer
            anchors.fill: parent

            ShapePath {
                strokeColor: "transparent"
                strokeWidth: Config.general.borderWidth > 0 ? Config.general.borderWidth : -1
                fillColor: States.ecoMode ? Config.colors.bge : Config.colors.bg

                startX: -(Config.general.cornerRadius * 2)
                startY: 0

                PathArc {
                    x: 0
                    y: Config.general.cornerRadius * 2
                    radiusX: Config.general.cornerRadius * 2
                    radiusY: Config.general.cornerRadius * 2
                }

                PathLine {
                    x: 0
                    y: dropdown.height - Config.general.cornerRadius
                }

                PathArc {
                    x: Config.general.cornerRadius
                    y: dropdown.height
                    direction: PathArc.Counterclockwise
                    radiusX: Config.general.cornerRadius
                    radiusY: Config.general.cornerRadius
                }

                PathLine {
                    x: dropdown.width - Config.general.cornerRadius
                    y: dropdown.height
                }

                PathArc {
                    x: dropdown.width
                    y: dropdown.height - Config.general.cornerRadius
                    direction: PathArc.Counterclockwise
                    radiusX: Config.general.cornerRadius
                    radiusY: Config.general.cornerRadius
                }

                PathLine {
                    x: dropdown.width
                    y: Config.general.cornerRadius * 2
                }

                PathArc {
                    x: dropdown.width + Config.general.cornerRadius * 2
                    y: 0
                    radiusX: Config.general.cornerRadius * 2
                    radiusY: Config.general.cornerRadius * 2
                }
            }
        }

        Item {
            id: contentArea
            z: 0

            implicitWidth: children.length > 0 ? children[0].implicitWidth : 0
            implicitHeight: children.length > 0 ? children[0].implicitHeight : 0
        }

        HoverHandler {
            id: dropdownHover
            grabPermissions: PointerHandler.TakeOverForbidden

            onHoveredChanged: {
                if (hovered) {
                    hideTimer.stop();
                } else {
                    hideTimer.start();
                }
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 120
        repeat: false

        onTriggered: {
            if (!dropdownHover.hovered) {
                root.show = false;
                States.dropdownRevealed = false;
            }

            if (States.dashboardPresent)
                States.dashboardPresent = false;
        }
    }

    onShowChanged: {
        if (show) {
            States.dropdownOwner = root;

            let barItem = root.parent;

            while (barItem && barItem.parent && barItem.parent.parent) {
                barItem = barItem.parent;
            }

            const mapped = root.boxParent.mapToItem(barItem, 0, 0);
            const centerX = mapped.x - (dropdown.width / 2) + (root.boxParent.width / 2) - Config.bar.padding;

            States.dropdownX = centerX;
            States.dropdownWidth = dropdown.width + (Config.general.borderWidth * 2);
            States.dropdownHeight = dropdown.height + (Config.general.borderWidth * 2);
            States.dropdownY = dropdown.y;
        }
    }
}
