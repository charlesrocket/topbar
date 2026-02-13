pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.OSS

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

import "../.."

Item {
    id: root

    property alias timer: hideTimer
    property bool show: false

    required property var boxParent

    default property alias content: contentArea.data

    Timer {
        id: hideTimer
        interval: 120
        repeat: false

        onTriggered: {
            if (!dropdownHover.hovered) {
                root.show = false;
                States.dropdownRevealed = false;
            }
        }
    }

    Item {
        id: dropdown
        parent: root.parent

        visible: false
        width: contentArea.implicitWidth
        height: contentArea.implicitHeight

        x: {
            const mapped = root.boxParent.mapToItem(root.boxParent, 0, 0);
            return mapped.x + (root.boxParent.width / 2) - (dropdown.width / 2);
        }

        y: {
            const mapped = root.boxParent.mapToItem(root.parent, 0, 0);
            return mapped.y + root.boxParent.height + 14;
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

                    PropertyAction {
                        target: States
                        property: "dropdownRevealed"
                        value: false
                    }
                }
            }
        ]

        Shape {
            id: ramp
            preferredRendererType: Shape.CurveRenderer
            anchors.fill: parent

            ShapePath {
                strokeColor: Config.colors.border
                strokeWidth: Config.general.borderWidth > 0 ? Config.general.borderWidth : -1
                fillColor: States.ecoMode ? Config.colors.bge : Config.colors.bg

                startX: -(Config.general.cornerRadius * 2)
                startY: 1

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
                    y: 1
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

            onHoveredChanged: {
                if (hovered) {
                    hideTimer.stop();
                } else {
                    hideTimer.start();
                }
            }
        }
    }
}
