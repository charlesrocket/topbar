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
    property bool first
    property bool last

    height: 32
    Layout.fillWidth: true
    spacing: 14

    SettingRect {
        id: rowRect

        property bool controlFillsWidth: root.valueType === "string"
                                         || root.valueType === "int"
                                         || root.valueType === "path"

        first: root.first
        last: root.last
        Layout.fillHeight: true
        Layout.fillWidth: true

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
            visible: root.valueType === "bool" || root.valueType === "color"
            implicitHeight: 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: labelText.right
            anchors.leftMargin: 14
            anchors.right: controlItem.left
            anchors.rightMargin: 14
        }

        // control element
        Item {
            id: controlItem

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.left: rowRect.controlFillsWidth ? labelText.right :
                                                      undefined
            anchors.leftMargin: rowRect.controlFillsWidth ? 14 : 0
            width: rowRect.controlFillsWidth ? undefined : Math.max(48,
                                                                    implicitWidth)
            implicitHeight: 32

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
                    cursorShape: Qt.PointingHandCursor

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

                visible: root.valueType === "string" || root.valueType === "int"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.left: parent.left
                font.family: Config.general.fontFamily
                font.pixelSize: Config.general.fontSize - 2
                color: Config.colors.fg
                implicitHeight: 24
                selectionColor: Config.colors.action
                horizontalAlignment: Qt.AlignRight
                selectedTextColor: States.ecoMode ? Config.colors.bge :
                                                    Config.colors.bg

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
                    if (root.valueType === "int")
                        root.targetObject[root.targetProperty] = parseInt(text);
                    else
                        root.targetObject[root.targetProperty] = text;
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
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        font.family: Config.general.fontFamily
                        font.pixelSize: Config.general.fontSize - 2
                        color: Config.colors.fg
                        elide: Text.ElideMiddle
                        horizontalAlignment: Qt.AlignRight
                        text: root.targetObject[root.targetProperty] || qsTr(
                                  "Select a file")
                    }

                    MouseArea {
                        id: pathMouseArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

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
