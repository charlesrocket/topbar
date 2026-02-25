import Quickshell
import Quickshell.Wayland

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ".."

PanelWindow {
    id: root

    implicitWidth: 800
    implicitHeight: 600
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    contentItem {
        focus: true
        Keys.onPressed: event => {
            if (event.key == Qt.Key_Escape) {
                States.preferencesWindowPresent = false;
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Config.colors.bg
        radius: Config.general.cornerRadius
        border.color: Config.colors.border
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 0

            // header
            Text {
                text: "Configuration"
                font.family: Config.general.fontFamily
                font.pixelSize: Config.general.fontSize + 6
                font.bold: true
                color: Config.colors.fg
                Layout.fillWidth: true
                Layout.bottomMargin: 16
            }

            // vertical tab bar + content
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 16

                // tab bar
                Rectangle {
                    color: "transparent"
                    radius: Config.general.cornerRadius
                    Layout.preferredWidth: 130
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8

                        Repeater {
                            model: ["General", "Colors", "Widgets", "Bar", "Workspaces", "Lockscreen", "Session"]

                            delegate: Button {
                                required property var modelData
                                required property int index

                                Layout.fillWidth: true
                                checkable: true
                                checked: tabBar.currentIndex === index
                                text: modelData
                                font.family: Config.general.fontFamily
                                font.pixelSize: Config.general.fontSize

                                onClicked: tabBar.currentIndex = index

                                background: Rectangle {
                                    color: parent.checked ? Config.colors.passive : "transparent"
                                    radius: Config.general.cornerRadius

                                    Behavior on color {
                                        ColAnim {}
                                    }
                                }

                                contentItem: Text {
                                    text: parent.text
                                    font: parent.font
                                    color: parent.checked ? Config.colors.fg : Config.colors.fg
                                    horizontalAlignment: Text.AlignLeft
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 8
                                }
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }
                    }
                }

                // drives StackLayout currentIndex
                TabBar {
                    id: tabBar
                    visible: false

                    Repeater {
                        model: 7
                        TabButton {}
                    }
                }

                Rectangle {
                    Layout.fillWidth: false
                    Layout.fillHeight: true
                    width: 1
                    color: Config.colors.passive
                }

                // content
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 8

                    StackLayout {
                        id: stackLayout
                        currentIndex: tabBar.currentIndex
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // general
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            ColumnLayout {
                                id: generalSection
                                width: parent.width
                                spacing: 12

                                SettingRow {
                                    label: "Locale"
                                    targetObject: Config.general
                                    targetProperty: "locale"
                                    valueType: "string"
                                }

                                SettingRow {
                                    label: "Font family"
                                    targetObject: Config.general
                                    targetProperty: "fontFamily"
                                    valueType: "string"
                                }

                                SettingRow {
                                    label: "Font Size"
                                    targetObject: Config.general
                                    targetProperty: "fontSize"
                                    valueType: "int"
                                }

                                SettingRow {
                                    label: "Border width"
                                    targetObject: Config.general
                                    targetProperty: "cornerRadius"
                                    valueType: "int"
                                }

                                SettingRow {
                                    label: "Corner radius"
                                    targetObject: Config.general
                                    targetProperty: "cornerRadius"
                                    valueType: "int"
                                }

                                SettingRow {
                                    label: "Animation duration"
                                    targetObject: Config.general
                                    targetProperty: "animDuration"
                                    valueType: "int"
                                }

                                SettingRow {
                                    label: "Wallpaper"
                                    targetObject: Config.general
                                    targetProperty: "wallpaper"
                                    valueType: "string"
                                }

                                Component.onCompleted: {
                                    root.validateSection(Config.general, generalSection, "Config.general", null);
                                }
                            }
                        }

                        // colors
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            GridLayout {
                                id: colorsSection
                                width: parent.width
                                columns: 2
                                columnSpacing: 16
                                rowSpacing: 12

                                SettingRow {
                                    label: "Background"
                                    targetObject: Config.colors
                                    targetProperty: "bg"
                                    valueType: "color"
                                }

                                SettingRow {
                                    label: "Background eco"
                                    targetObject: Config.colors
                                    targetProperty: "bge"
                                    valueType: "color"
                                }

                                SettingRow {
                                    label: "Background light"
                                    targetObject: Config.colors
                                    targetProperty: "bgl"
                                    valueType: "color"
                                }

                                SettingRow {
                                    label: "Foreground"
                                    targetObject: Config.colors
                                    targetProperty: "fg"
                                    valueType: "color"
                                }

                                SettingRow {
                                    label: "Border"
                                    targetObject: Config.colors
                                    targetProperty: "border"
                                    valueType: "color"
                                }

                                SettingRow {
                                    label: "Passive"
                                    targetObject: Config.colors
                                    targetProperty: "passive"
                                    valueType: "color"
                                }

                                SettingRow {
                                    label: "Dark"
                                    targetObject: Config.colors
                                    targetProperty: "dark"
                                    valueType: "color"
                                }

                                SettingRow {
                                    label: "Extra Dark"
                                    targetObject: Config.colors
                                    targetProperty: "extraDark"
                                    valueType: "color"
                                }

                                SettingRow {
                                    label: "Action"
                                    targetObject: Config.colors
                                    targetProperty: "action"
                                    valueType: "color"
                                }

                                SettingRow {
                                    label: "Accent"
                                    targetObject: Config.colors
                                    targetProperty: "accent"
                                    valueType: "color"
                                }

                                SettingRow {
                                    label: "Red"
                                    targetObject: Config.colors
                                    targetProperty: "red"
                                    valueType: "color"
                                }

                                SettingRow {
                                    label: "Yellow"
                                    targetObject: Config.colors
                                    targetProperty: "yellow"
                                    valueType: "color"
                                }

                                SettingRow {
                                    label: "Purple"
                                    targetObject: Config.colors
                                    targetProperty: "purple"
                                    valueType: "color"
                                }

                                SettingRow {
                                    label: "Green"
                                    targetObject: Config.colors
                                    targetProperty: "green"
                                    valueType: "color"
                                }

                                Component.onCompleted: {
                                    root.validateSection(Config.colors, colorsSection, "Config.colors", null);
                                }
                            }
                        }

                        // widgets
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            GridLayout {
                                id: widgetsSection
                                width: parent.width
                                columns: 2
                                columnSpacing: 16
                                rowSpacing: 12

                                SettingRow {
                                    label: "Workspaces"
                                    targetObject: Config.widgets
                                    targetProperty: "workspaces"
                                    valueType: "bool"
                                }

                                SettingRow {
                                    label: "Title"
                                    targetObject: Config.widgets
                                    targetProperty: "title"
                                    valueType: "bool"
                                }

                                SettingRow {
                                    label: "Stats"
                                    targetObject: Config.widgets
                                    targetProperty: "stats"
                                    valueType: "bool"
                                }

                                SettingRow {
                                    label: "Audio"
                                    targetObject: Config.widgets
                                    targetProperty: "audio"
                                    valueType: "bool"
                                }

                                SettingRow {
                                    label: "Bluetooth"
                                    targetObject: Config.widgets
                                    targetProperty: "bluetooth"
                                    valueType: "bool"
                                }

                                SettingRow {
                                    label: "Network"
                                    targetObject: Config.widgets
                                    targetProperty: "network"
                                    valueType: "bool"
                                }

                                SettingRow {
                                    label: "Tray"
                                    targetObject: Config.widgets
                                    targetProperty: "tray"
                                    valueType: "bool"
                                }

                                SettingRow {
                                    label: "Weather"
                                    targetObject: Config.widgets
                                    targetProperty: "weather"
                                    valueType: "bool"
                                }

                                SettingRow {
                                    label: "Language"
                                    targetObject: Config.widgets
                                    targetProperty: "language"
                                    valueType: "bool"
                                }

                                SettingRow {
                                    label: "Clock"
                                    targetObject: Config.widgets
                                    targetProperty: "clock"
                                    valueType: "bool"
                                }

                                SettingRow {
                                    label: "Battery"
                                    targetObject: Config.widgets
                                    targetProperty: "battery"
                                    valueType: "bool"
                                }

                                Component.onCompleted: {
                                    root.validateSection(Config.widgets, widgetsSection, "Config.widgets", null);
                                }
                            }
                        }

                        // bar
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            ColumnLayout {
                                width: parent.width
                                spacing: 12

                                ColumnLayout {
                                    id: barSection
                                    width: parent.width
                                    spacing: 12

                                    SettingRow {
                                        label: "Height"
                                        targetObject: Config.bar
                                        targetProperty: "height"
                                        valueType: "int"
                                    }

                                    SettingRow {
                                        label: "Padding"
                                        targetObject: Config.bar
                                        targetProperty: "padding"
                                        valueType: "int"
                                    }

                                    Component.onCompleted: {
                                        root.validateSection(Config.bar, barSection, "Config.bar", 1);
                                    }
                                }

                                ColumnLayout {
                                    id: barTitleSection
                                    width: parent.width
                                    spacing: 12

                                    SettingRow {
                                        label: "Width"
                                        targetObject: Config.bar.title
                                        targetProperty: "width"
                                        valueType: "int"
                                    }

                                    SettingRow {
                                        label: "Empty text"
                                        targetObject: Config.bar.title
                                        targetProperty: "empty"
                                        valueType: "string"
                                    }

                                    Component.onCompleted: {
                                        root.validateSection(Config.bar.title, barTitleSection, "Config.bar.title", null);
                                    }
                                }
                            }
                        }

                        // workspaces
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            ColumnLayout {
                                id: workspaceSection
                                width: parent.width
                                spacing: 12

                                SettingRow {
                                    label: "Workspace 1"
                                    targetObject: Config.workspaces
                                    targetProperty: "one"
                                    valueType: "string"
                                }

                                SettingRow {
                                    label: "Workspace 2"
                                    targetObject: Config.workspaces
                                    targetProperty: "two"
                                    valueType: "string"
                                }

                                SettingRow {
                                    label: "Workspace 3"
                                    targetObject: Config.workspaces
                                    targetProperty: "three"
                                    valueType: "string"
                                }

                                SettingRow {
                                    label: "Workspace 4"
                                    targetObject: Config.workspaces
                                    targetProperty: "four"
                                    valueType: "string"
                                }

                                SettingRow {
                                    label: "Workspace 5"
                                    targetObject: Config.workspaces
                                    targetProperty: "five"
                                    valueType: "string"
                                }

                                SettingRow {
                                    label: "Workspace 6"
                                    targetObject: Config.workspaces
                                    targetProperty: "six"
                                    valueType: "string"
                                }

                                SettingRow {
                                    label: "Workspace 7"
                                    targetObject: Config.workspaces
                                    targetProperty: "seven"
                                    valueType: "string"
                                }

                                SettingRow {
                                    label: "Workspace 8"
                                    targetObject: Config.workspaces
                                    targetProperty: "eight"
                                    valueType: "string"
                                }

                                SettingRow {
                                    label: "Workspace 9"
                                    targetObject: Config.workspaces
                                    targetProperty: "nine"
                                    valueType: "string"
                                }

                                SettingRow {
                                    label: "Workspace 10"
                                    targetObject: Config.workspaces
                                    targetProperty: "ten"
                                    valueType: "string"
                                }

                                Component.onCompleted: {
                                    root.validateSection(Config.workspaces, workspaceSection, "Config.workspaces", null);
                                }
                            }
                        }

                        // lockscreen
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            ColumnLayout {
                                id: lockscreenSection
                                width: parent.width
                                spacing: 12

                                SettingRow {
                                    label: "Wallpaper"
                                    targetObject: Config.lockscreen
                                    targetProperty: "wallpaper"
                                    valueType: "string"
                                }

                                SettingRow {
                                    label: "Buttons"
                                    targetObject: Config.lockscreen
                                    targetProperty: "buttons"
                                    valueType: "bool"
                                }

                                SettingRow {
                                    label: "Clock"
                                    targetObject: Config.lockscreen
                                    targetProperty: "clock"
                                    valueType: "bool"
                                }

                                SettingRow {
                                    label: "Battery"
                                    targetObject: Config.lockscreen
                                    targetProperty: "battery"
                                    valueType: "bool"
                                }

                                SettingRow {
                                    label: "Shadows"
                                    targetObject: Config.lockscreen
                                    targetProperty: "shadows"
                                    valueType: "bool"
                                }

                                SettingRow {
                                    label: "Show username"
                                    targetObject: Config.lockscreen
                                    targetProperty: "username"
                                    valueType: "bool"
                                }

                                SettingRow {
                                    label: "Show icon"
                                    targetObject: Config.lockscreen
                                    targetProperty: "icon"
                                    valueType: "bool"
                                }

                                Component.onCompleted: {
                                    root.validateSection(Config.lockscreen, lockscreenSection, "Config.lockscreen", null);
                                }
                            }
                        }

                        // session
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            ColumnLayout {
                                width: parent.width
                                spacing: 12

                                ColumnLayout {
                                    width: parent.width
                                    spacing: 12

                                    SettingRow {
                                        label: "Background color"
                                        targetObject: Config.session
                                        targetProperty: "background"
                                        valueType: "color"
                                    }
                                }

                                Text {
                                    text: "Commands"
                                    font.family: Config.general.fontFamily
                                    font.pixelSize: Config.general.fontSize + 2
                                    font.bold: true
                                    color: Config.colors.accent
                                    Layout.topMargin: 16
                                }

                                ColumnLayout {
                                    id: sessionCommandsSection
                                    width: parent.width
                                    spacing: 12

                                    SettingRow {
                                        label: "Lock"
                                        targetObject: Config.session.commands
                                        targetProperty: "lock"
                                        valueType: "string"
                                    }

                                    SettingRow {
                                        label: "Logout"
                                        targetObject: Config.session.commands
                                        targetProperty: "logout"
                                        valueType: "string"
                                    }

                                    SettingRow {
                                        label: "Suspend"
                                        targetObject: Config.session.commands
                                        targetProperty: "suspend"
                                        valueType: "string"
                                    }

                                    SettingRow {
                                        label: "Hibernate"
                                        targetObject: Config.session.commands
                                        targetProperty: "hibernate"
                                        valueType: "string"
                                    }

                                    SettingRow {
                                        label: "Shutdown"
                                        targetObject: Config.session.commands
                                        targetProperty: "shutdown"
                                        valueType: "string"
                                    }

                                    SettingRow {
                                        label: "Reboot"
                                        targetObject: Config.session.commands
                                        targetProperty: "reboot"
                                        valueType: "string"
                                    }

                                    Component.onCompleted: {
                                        root.validateSection(Config.session.commands, sessionCommandsSection, "Config.session.commands", null);
                                    }
                                }
                            }
                        }
                    }

                    // button
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Item {
                            Layout.fillWidth: true
                        }

                        Button {
                            text: "Accept"
                            font.family: Config.general.fontFamily
                            font.pixelSize: Config.general.fontSize

                            onClicked: States.preferencesWindowPresent = false

                            background: Rectangle {
                                color: Config.colors.passive
                                radius: Config.general.cornerRadius

                                Behavior on color {
                                    ColAnim {}
                                }
                            }

                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: Config.colors.fg
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
        }
    }

    component SettingRow: RowLayout {
        id: settingRow

        required property string label
        required property var targetObject
        required property string targetProperty
        required property string valueType

        Layout.fillWidth: true
        spacing: 8

        Text {
            text: settingRow.label
            font.family: Config.general.fontFamily
            font.pixelSize: Config.general.fontSize
            color: Config.colors.fg
            Layout.preferredWidth: valueType === "bool" ? -1 : 150
            Layout.fillWidth: valueType === "bool"
        }

        // color preview rectangle
        Rectangle {
            visible: valueType === "color"
            width: 40
            height: 24
            color: visible ? targetObject[targetProperty] : "transparent"
            border.color: Config.colors.border
            border.width: 1
            radius: 4
        }

        // string box
        TextField {
            id: textField
            visible: valueType === "string" || valueType === "int" || valueType === "color"
            Layout.fillWidth: true
            font.family: Config.general.fontFamily
            font.pixelSize: Config.general.fontSize - 2
            color: Config.colors.fg
            selectionColor: Config.colors.action
            selectedTextColor: Config.colors.bg

            Component.onCompleted: {
                text = targetObject[targetProperty].toString();
            }

            onEditingFinished: {
                if (valueType === "int") {
                    targetObject[targetProperty] = parseInt(text);
                } else {
                    targetObject[targetProperty] = text;
                }
            }

            background: Rectangle {
                color: Config.colors.dark
                border.color: parent.activeFocus ? Config.colors.action : Config.colors.border
                border.width: 1
                radius: 4

                Behavior on border.color {
                    ColAnim {}
                }
            }

            Binding {
                target: settingRow.targetObject
                property: settingRow.targetProperty
                value: valueType === "int" ? parseInt(textField.text) : textField.text
                when: textField.activeFocus
                delayed: true
            }
        }

        // boolean switch
        Switch {
            id: boolSwitch
            visible: valueType === "bool"

            Component.onCompleted: {
                checked = targetObject[targetProperty];
            }

            onToggled: {
                targetObject[targetProperty] = checked;
            }

            indicator: Rectangle {
                implicitWidth: 48
                implicitHeight: 24
                radius: 12
                color: parent.checked ? Config.colors.action : Config.colors.passive
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

            Binding {
                target: settingRow.targetObject
                property: settingRow.targetProperty
                value: boolSwitch.checked
                when: boolSwitch.visible
                delayed: true
            }
        }
    }

    function validateSection(obj, section, key, offset) {
        var configCount = Utils.getPropertyCount(obj);

        if (offset != null)
            configCount -= offset;

        if (configCount != section.children.length)
            console.warn("Validation failed for " + key + " " + configCount + " != " + section.children.length);
    }
}
