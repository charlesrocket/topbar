import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import qs
import qs.core

RowLayout {
    id: settingRow

    required property string label
    required property var targetObject
    required property string targetProperty
    required property string valueType

    height: 32
    Layout.fillWidth: true
    spacing: 14

    // label
    Text {
        text: settingRow.label
        font.family: Config.general.fontFamily
        font.pixelSize: Config.general.fontSize
        color: Config.colors.fg
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        Layout.fillWidth: false
    }

    // fill
    Rectangle {
        color: Config.colors.dark
        visible: settingRow.valueType === "bool" || settingRow.valueType
                 === "color"
        implicitHeight: 2
        Layout.fillHeight: false
        Layout.fillWidth: true
    }

    // control element
    Item {
        Layout.fillWidth: settingRow.valueType === "string"
                          || settingRow.valueType === "int"
                          || settingRow.valueType === "path"
        Layout.minimumWidth: 48
        Layout.alignment: Qt.AlignLeft
        implicitHeight: 32

        Rectangle {
            id: colorSwatch

            visible: settingRow.valueType === "color"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 40
            implicitHeight: 24
            color: visible ? settingRow.targetObject[settingRow.targetProperty] :
                             "transparent"
            border.color: colorMouseArea.containsMouse ? Config.colors.action :
                                                         Config.colors.border
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

                title: qsTr("Select %1").arg(settingRow.label)
                selectedColor:
                    settingRow.targetObject[settingRow.targetProperty]
                options: ColorDialog.ShowAlphaChannel

                onAccepted: settingRow.targetObject[settingRow.targetProperty]
                            = colorDialog.selectedColor
            }
        }

        TextField {
            id: textField

            visible: settingRow.valueType === "string" || settingRow.valueType
                     === "int"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.left: parent.left
            font.family: Config.general.fontFamily
            font.pixelSize: Config.general.fontSize - 2
            color: Config.colors.fg
            implicitHeight: 24
            selectionColor: Config.colors.action
            horizontalAlignment: Qt.AlignRight
            selectedTextColor: Config.colors.bg

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
                text = settingRow.targetObject[settingRow.targetProperty].toString(
                            );
            }
            onEditingFinished: {
                if (settingRow.valueType === "int")
                    settingRow.targetObject[settingRow.targetProperty]
                            = parseInt(text);
                else
                    settingRow.targetObject[settingRow.targetProperty] = text;
            }
        }

        Loader {
            id: pathLoader

            active: settingRow.valueType === "path"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.left: parent.left

            //height: 32

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
                    text: settingRow.targetObject[settingRow.targetProperty]
                          || qsTr("Select a file")
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

                    title: qsTr("Select %1").arg(settingRow.label.toLowerCase())

                    // set on creation instead of live bindings
                    // TODO use StandardPaths
                    Component.onCompleted: {
                        var current
                                = settingRow.targetObject[settingRow.targetProperty];

                        if (typeof current === "string" && current.length > 0) {
                            var idx = current.lastIndexOf("/");
                            var dir = idx >= 0 ? current.substring(0, idx) : "";

                            if (dir.length > 0)
                                currentFolder = "file://" + dir;
                        }
                    }
                    onAccepted: {
                        // sanitize path
                        var path = selectedFile.toString().replace(
                                    /^file:\/{2,3}/, "/");

                        settingRow.targetObject[settingRow.targetProperty]
                                = decodeURIComponent(path);
                    }
                }
            }
        }

        Switch {
            id: boolSwitch

            visible: settingRow.valueType === "bool"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            implicitHeight: 24
            checked: settingRow.targetObject[settingRow.targetProperty]

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

            onToggled: settingRow.targetObject[settingRow.targetProperty]
                       = checked
        }
    }
}
