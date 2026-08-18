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
    property real descriptionMaxWidth: width * 0.45
    property int rowWidth: 100
    property bool first
    property bool last
    property real sliderFrom: 0
    property real sliderTo: 100
    property real sliderStepSize: 1
    property string description: ""
    property bool status: false
    property bool integrationConnected: valueType === "integration" ? status :
                                                                      false

    signal logoutRequested

    function colorToHex(c) {
        return "#%1%2%3%4".arg(Math.round(c.a * 255).toString(16).padStart(2,
                                                                           '0')).arg(
                    Math.round(c.r * 255).toString(16).padStart(2, '0')).arg(Math.round(
                                                                                 c.g * 255).toString(
                                                                                 16).padStart(
                                                                                 2, '0')).arg(
                    Math.round(c.b * 255).toString(16).padStart(2, '0'));
    }

    height: description === "" ? 32 : labelColumn.height + 16
    Layout.fillWidth: true
    spacing: 14

    SettingRect {
        id: rowRect

        property bool expanded: mouse.hovered && (root.valueType === "string"
                                                  || root.valueType === "font"
                                                  || root.valueType === "path"
                                                  || root.valueType === "int")

        first: root.first
        last: root.last
        Layout.fillHeight: true
        Layout.fillWidth: true

        HoverHandler {
            id: mouse

            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        }

        RowLayout {
            id: contentRow

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 12

            // label + description
            Item {
                id: labelColumn

                Layout.alignment: Qt.AlignVCenter
                Layout.fillHeight: false
                Layout.preferredWidth: Math.max(labelText.implicitWidth + (
                                                    root.valueType
                                                    === "integration"
                                                    ? statusDot.width + 8 : 0),
                                                descriptionText.visible
                                                ? descriptionText.implicitWidth :
                                                  0)
                Layout.minimumWidth: 10
                Layout.maximumWidth: root.descriptionMaxWidth
                implicitHeight: labelRow.height + (descriptionText.visible
                                                   ? descriptionText.implicitHeight
                                                     + 2 : 0)
                Layout.preferredHeight: implicitHeight

                Behavior on Layout.preferredWidth {
                    NumberAnimation {
                        duration: Config.general.animDuration * 2
                        easing.type: Easing.OutQuint
                    }
                }

                Item {
                    id: labelRow

                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: parent.width
                    height: Math.max(labelText.implicitHeight, statusDot.height)

                    Text {
                        id: labelText

                        anchors.left: parent.left
                        width: parent.width
                        elide: Text.ElideRight
                        text: root.label
                        font.family: Config.general.fontFamily
                        font.pixelSize: Config.general.fontSize
                        color: Config.colors.fg
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        id: statusDot

                        visible: root.valueType === "integration"
                        x: labelText.x + labelText.contentWidth + 8
                        width: 8
                        height: 14
                        radius: 4
                        color: root.integrationConnected ? Config.colors.green :
                                                           Config.colors.red
                        border.color: Qt.darker(color, 1.3)
                        border.width: 1

                        Behavior on color {
                            ColAnim {}
                        }
                    }
                }

                Text {
                    id: descriptionText

                    anchors.left: parent.left
                    anchors.top: labelRow.bottom
                    anchors.topMargin: 2
                    width: parent.width
                    wrapMode: Text.WordWrap
                    visible: root.description !== ""
                    text: root.description
                    font.family: Config.general.fontFamily
                    font.pixelSize: Config.general.fontSize - 2
                    color: Config.colors.fg
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // separator
            Rectangle {
                id: fillLine

                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.alignment: Qt.AlignVCenter
                implicitHeight: 2
                color: Config.colors.passive

                Rectangle {
                    visible: root.description.length > 0
                    width: 2
                    height: labelColumn.height / 2
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    color: Config.colors.passive
                }
            }

            // control element
            Item {
                id: controlItem

                Layout.preferredWidth: rowRect.expanded ? rowRect.width / 2 : (
                                                              root.valueType
                                                              === "color"
                                                              || root.valueType
                                                              === "bool") ? 40 :
                                                                            root.valueType
                                                                            === "integration"
                                                                            ? 110 : root.rowWidth
                Layout.preferredHeight: 32

                Behavior on Layout.preferredWidth {
                    NumberAnimation {
                        duration: Config.general.animDuration * 2
                        easing.type: Easing.OutQuint
                    }
                }

                // color
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
                                    = root.colorToHex(colorDialog.selectedColor)
                    }
                }

                // string
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
                        text = root.targetObject[root.targetProperty].toString(
                                    );
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

                // integer
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
                            y: intSlider.topPadding + intSlider.availableHeight
                               / 2 - height / 2
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
                            x: intSlider.leftPadding + intSlider.visualPosition
                               * (intSlider.availableWidth - width)
                            y: intSlider.topPadding + intSlider.availableHeight
                               / 2 - height / 2
                            implicitWidth: 20
                            implicitHeight: 20
                            radius: 10
                            color: Config.colors.fg
                            border.color: intSlider.pressed
                                          ? Config.colors.action :
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

                // path
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
                                      ? Config.colors.action :
                                        Config.colors.border
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

                            title: qsTr("Select %1").arg(root.label.toLowerCase(
                                                             ))

                            Component.onCompleted: {
                                var current
                                        = root.targetObject[root.targetProperty];

                                if (typeof current === "string"
                                        && current.length > 0) {
                                    var idx = current.lastIndexOf("/");
                                    var dir = idx >= 0 ? current.substring(0,
                                                                           idx) : "";

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

                // font
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
                                      ? Config.colors.action :
                                        Config.colors.border
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

                            title: qsTr("Select %1").arg(root.label.toLowerCase(
                                                             ))

                            Component.onCompleted: {
                                var current
                                        = root.targetObject[root.targetProperty];
                                if (typeof current === "string"
                                        && current.length > 0)
                                    currentFont.family = current;
                            }
                            onAccepted: {
                                root.targetObject[root.targetProperty]
                                        = fontDialog.selectedFont.family;
                            }
                        }
                    }
                }

                // bool
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
                            x: parent.parent.checked ? parent.width - width - 2 :
                                                       2
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

                RowLayout {
                    id: integrationRow

                    visible: root.valueType === "integration"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    spacing: 10

                    Button {
                        id: logoutButton

                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredHeight: 24
                        Layout.preferredWidth: logoutContent.implicitWidth + 20
                        text: ""
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: Config.general.fontSize - 3

                        background: Rectangle {
                            color: Config.colors.dark
                            border.color: logoutButton.hovered
                                          ? Config.colors.action :
                                            Config.colors.border
                            border.width: Config.general.borderWidth
                            radius: Config.general.cornerRadius

                            Behavior on border.color {
                                ColAnim {}
                            }
                        }
                        contentItem: Text {
                            id: logoutContent

                            text: logoutButton.text
                            font: logoutButton.font
                            color: Config.colors.fg
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: root.logoutRequested()
                    }

                    Switch {
                        id: integrationSwitch

                        Layout.alignment: Qt.AlignVCenter
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
                                x: parent.parent.checked ? parent.width - width
                                                           - 2 : 2
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

                        onToggled: root.targetObject[root.targetProperty]
                                   = checked
                    }
                }
            }
        }
    }
}
