import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import qs
import qs.core

RowLayout {
    id: root

    required property string label
    required property var targetObject
    required property string targetProperty
    required property string valueType
    property int rowWidth: 100
    property bool first
    property bool last
    property real sliderFrom: 0
    property real sliderTo: 100
    property real sliderStepSize: 1

    height: 32
    Layout.fillWidth: true
    spacing: 14

    SettingRect {
        id: rowRect

        first: root.first
        last: root.last
        Layout.fillHeight: true
        Layout.fillWidth: true

        HoverHandler {
            id: mouse

            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        }

        // label
        Text {
            id: labelText

            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            font.family: Config.general.fontFamily
            font.pixelSize: Config.general.fontSize
            color: Config.colors.fg
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
        }

        // fill
        Rectangle {
            id: fillLine

            color: Config.colors.fg
            opacity: 0.6
            implicitHeight: 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: labelText.right
            anchors.leftMargin: 12
            anchors.right: controlItem.left
            anchors.rightMargin: 12
        }

        // control element
        Item {
            id: controlItem

            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 12
            anchors.right: parent.right
            anchors.rightMargin: 12
            width: (mouse.hovered && (root.valueType === "string"
                                      || root.valueType === "int"))
                   ? rowRect.width / 2 : (root.valueType === "color"
                                          || root.valueType === "bool") ? 40 :
                                                                          root.rowWidth
            implicitHeight: 32

            Behavior on width {
                NumberAnimation {
                    duration: Config.general.animDuration * 2
                    easing.type: Easing.OutQuint
                }
            }
            states: State {
                name: "expanded"
                when: mouse.hovered && (root.valueType === "string"
                                        || root.valueType === "int")

                PropertyChanges {
                    target: controlItem
                    width: 400
                }
            }

            Rectangle {
                id: colorSwatch

                visible: root.valueType === "color"
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 40
                implicitHeight: 24
                color: visible ? root.targetObject[root.targetProperty] :
                                 "transparent"
                border.color: colorMouseArea.containsMouse
                              ? Config.colors.action : Config.colors.border
                border.width: Config.general.borderWidth
                radius: Config.general.cornerRadius

                Behavior on border.color {
                    ColAnim {}
                }

                MouseArea {
                    id: colorMouseArea

                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: colorDialog.open()
                }

                ColorDialog {
                    id: colorDialog

                    title: qsTr("Select %1").arg(root.label)
                    selectedColor: root.targetObject[root.targetProperty]
                    options: ColorDialog.ShowAlphaChannel

                    onAccepted: root.targetObject[root.targetProperty]
                                = colorDialog.selectedColor
                }
            }

            TextField {
                id: textField

                visible: root.valueType === "string"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.left: parent.left
                font.family: Config.general.fontFamily
                font.pixelSize: Config.general.fontSize - 2
                implicitHeight: 24
                selectionColor: Config.colors.action
                horizontalAlignment: Text.AlignHCenter
                selectedTextColor: States.ecoMode ? Config.colors.bge :
                                                    Config.colors.bg
                color: activeFocus ? Config.colors.fg : "transparent"

                background: Rectangle {
                    color: Config.colors.dark
                    border.color: parent.activeFocus ? Config.colors.action :
                                                       Config.colors.border
                    border.width: Config.general.borderWidth
                    radius: Config.general.cornerRadius

                    Behavior on border.color {
                        ColAnim {}
                    }
                }

                Component.onCompleted: {
                    text = root.targetObject[root.targetProperty].toString();
                }
                onEditingFinished: {
                    root.targetObject[root.targetProperty] = text;
                }

                Text {
                    id: elidedText

                    z: 1
                    anchors.fill: parent
                    anchors.margins: 6
                    text: textField.text
                    elide: Text.ElideLeft
                    font: textField.font
                    color: Config.colors.fg
                    horizontalAlignment: textField.horizontalAlignment
                    verticalAlignment: Text.AlignVCenter
                    visible: !textField.activeFocus
                    enabled: false
                }
            }

            RowLayout {
                id: intSliderRow

                visible: root.valueType === "int"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.left: parent.left
                spacing: 10

                Slider {
                    id: intSlider

                    Layout.fillWidth: true
                    from: root.sliderFrom
                    to: root.sliderTo
                    stepSize: root.sliderStepSize
                    live: true

                    background: Rectangle {
                        x: intSlider.leftPadding
                        y: intSlider.topPadding + intSlider.availableHeight / 2
                           - height / 2
                        width: intSlider.availableWidth
                        implicitHeight: 4
                        height: implicitHeight
                        radius: 2
                        color: Config.colors.passive

                        Rectangle {
                            width: intSlider.visualPosition * parent.width
                            height: parent.height
                            radius: 2
                            color: Config.colors.accent
                        }
                    }
                    handle: Rectangle {
                        x: intSlider.leftPadding + intSlider.visualPosition * (
                               intSlider.availableWidth - width)
                        y: intSlider.topPadding + intSlider.availableHeight / 2
                           - height / 2
                        implicitWidth: 20
                        implicitHeight: 20
                        radius: 10
                        color: Config.colors.fg
                        border.color: intSlider.pressed ? Config.colors.action :
                                                          Config.colors.border
                        border.width: Config.general.borderWidth

                        Behavior on border.color {
                            ColAnim {}
                        }
                    }

                    Component.onCompleted: {
                        value = root.targetObject[root.targetProperty];
                    }
                    onMoved: {
                        root.targetObject[root.targetProperty] = Math.round(
                                    value);
                    }
                }

                Text {
                    id: intValueText

                    Layout.preferredWidth: 30
                    text: Math.round(intSlider.value)
                    font.family: Config.general.fontFamily
                    font.pixelSize: Config.general.fontSize - 2
                    font.bold: true
                    color: Config.colors.fg
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Loader {
                id: pathLoader

                active: root.valueType === "path"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.left: parent.left

                sourceComponent: Rectangle {
                    id: pathField

                    implicitHeight: 24
                    color: Config.colors.dark
                    border.color: pathMouseArea.containsMouse
                                  ? Config.colors.action : Config.colors.border
                    border.width: Config.general.borderWidth
                    radius: Config.general.cornerRadius

                    Behavior on border.color {
                        ColAnim {}
                    }

                    Text {
                        id: pathText

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        font.family: Config.general.fontFamily
                        font.pixelSize: Config.general.fontSize - 2
                        color: Config.colors.fg
                        elide: Text.ElideLeft
                        horizontalAlignment: Qt.AlignRight
                        text: root.targetObject[root.targetProperty] || qsTr(
                                  "Select a file")
                    }

                    MouseArea {
                        id: pathMouseArea

                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: pathDialog.open()
                    }

                    FileDialog {
                        id: pathDialog

                        title: qsTr("Select %1").arg(root.label.toLowerCase())

                        Component.onCompleted: {
                            var current
                                    = root.targetObject[root.targetProperty];

                            if (typeof current === "string" && current.length
                                    > 0) {
                                var idx = current.lastIndexOf("/");
                                var dir = idx >= 0 ? current.substring(0, idx) :
                                                     "";

                                if (dir.length > 0)
                                    currentFolder = "file://" + dir;
                            }
                        }
                        onAccepted: {
                            var path = selectedFile.toString().replace(
                                        /^file:\/{2,3}/, "/");

                            root.targetObject[root.targetProperty]
                                    = decodeURIComponent(path);
                        }
                    }
                }
            }

            Loader {
                id: fontLoader

                active: root.valueType === "font"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.left: parent.left

                sourceComponent: Rectangle {
                    id: fontField

                    implicitHeight: 24
                    color: Config.colors.dark
                    border.color: fontMouseArea.containsMouse
                                  ? Config.colors.action : Config.colors.border
                    border.width: Config.general.borderWidth
                    radius: Config.general.cornerRadius

                    Behavior on border.color {
                        ColAnim {}
                    }

                    Text {
                        id: fontText

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        font.family: Config.general.fontFamily
                        font.pixelSize: Config.general.fontSize - 2
                        color: Config.colors.fg
                        elide: Text.ElideLeft
                        horizontalAlignment: Qt.AlignRight
                        text: root.targetObject[root.targetProperty] || qsTr(
                                  "Select a font")
                    }

                    MouseArea {
                        id: fontMouseArea

                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: fontDialog.open()
                    }

                    FontDialog {
                        id: fontDialog

                        title: qsTr("Select %1").arg(root.label.toLowerCase())

                        Component.onCompleted: {
                            var current
                                    = root.targetObject[root.targetProperty];
                            if (typeof current === "string" && current.length
                                    > 0)
                                currentFont.family = current;
                        }
                        onAccepted: {
                            root.targetObject[root.targetProperty]
                                    = fontDialog.selectedFont.family;
                        }
                    }
                }
            }

            Switch {
                id: boolSwitch

                visible: root.valueType === "bool"
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                implicitHeight: 24
                checked: root.targetObject[root.targetProperty]

                indicator: Rectangle {
                    implicitWidth: 48
                    implicitHeight: 24
                    radius: 12
                    color: parent.checked ? Config.colors.accent :
                                            Config.colors.passive
                    border.color: Config.colors.border
                    border.width: 1

                    Behavior on color {
                        ColAnim {}
                    }

                    Rectangle {
                        x: parent.parent.checked ? parent.width - width - 2 : 2
                        y: 2
                        width: 20
                        height: 20
                        radius: 10
                        color: Config.colors.fg

                        Behavior on x {
                            NumberAnimation {
                                duration: Config.general.animDuration
                            }
                        }
                    }
                }

                onToggled: root.targetObject[root.targetProperty] = checked
            }
        }
    }
}
