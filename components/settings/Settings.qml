import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell

import qs
import qs.core

FloatingWindow {
    id: root

    property string version: System.version

    function validateSection(obj, section, key, offset) {
        var configCount = Utils.getPropertyCount(obj);

        if (offset != null)
            configCount -= offset;

        if (configCount != section.children.length)
            console.warn("Validation failed for " + key + " " + configCount
                         + " != " + section.children.length);
    }

    title: "Settings"
    color: "transparent"

    onClosed: {
        States.settingsPresent = false;
    }

    contentItem {
        focus: true

        Keys.onPressed: event => {
            if (event.key == Qt.Key_Escape) {
                States.settingsPresent = false;
            }
        }
    }

    MouseArea {
        anchors.fill: parent

        onClicked: States.settingsPresent = false
    }

    Rectangle {
        anchors.fill: parent
        color: Config.colors.bg
        radius: Config.general.cornerRadius

        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 0

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
                            model: ["General", "Colors", "Widgets", "Bar",
                                "Notifications", "Desktop", "Spaces",
                                "Dashboard", "Lockscreen", "Session", "About"]

                            delegate: Button {
                                required property var modelData
                                required property int index

                                Layout.fillWidth: true
                                checkable: true
                                checked: tabBar.currentIndex === index
                                text: modelData
                                font.family: Config.general.fontFamily
                                font.pixelSize: Config.general.fontSize

                                background: Rectangle {
                                    color: parent.checked
                                           ? Config.colors.passive :
                                             "transparent"
                                    radius: Config.general.cornerRadius

                                    Behavior on color {
                                        ColAnim {}
                                    }
                                }
                                contentItem: Text {
                                    text: parent.text
                                    font: parent.font
                                    color: parent.checked ? Config.colors.fg :
                                                            Config.colors.fg
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignRight
                                    leftPadding: 8
                                }

                                onClicked: tabBar.currentIndex = index
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
                        model: 10

                        TabButton {}
                    }
                }

                // separator
                Rectangle {
                    Layout.fillWidth: false
                    Layout.fillHeight: true
                    radius: 1
                    implicitWidth: 1
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
                            id: generalScroll

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            GridLayout {
                                id: generalSection

                                width: generalScroll.width
                                columns: 2
                                columnSpacing: 14
                                rowSpacing: 14

                                Component.onCompleted: {
                                    root.validateSection(Config.general,
                                                         generalSection,
                                                         "Config.general",
                                                         null);
                                }

                                SettingRow {
                                    label: "Locale"
                                    targetObject: Config.general
                                    targetProperty: "locale"
                                    valueType: "string"
                                }

                                SettingRow {
                                    label: "Config watch"
                                    targetObject: Config.general
                                    targetProperty: "configWatch"
                                    valueType: "bool"
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
                                    targetProperty: "borderWidth"
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
                                    valueType: "path"
                                }

                                SettingRow {
                                    label: "Blur"
                                    targetObject: Config.general
                                    targetProperty: "blur"
                                    valueType: "bool"
                                }

                                SettingRow {
                                    label: "Shadows"
                                    targetObject: Config.general
                                    targetProperty: "shadows"
                                    valueType: "bool"
                                }
                            }
                        }

                        // colors
                        ScrollView {
                            id: colorsScroll

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            GridLayout {
                                id: colorsSection

                                width: colorsScroll.width
                                columns: 3
                                columnSpacing: 14
                                rowSpacing: 14

                                Component.onCompleted: {
                                    root.validateSection(Config.colors,
                                                         colorsSection,
                                                         "Config.colors", null);
                                }

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
                            }
                        }

                        // widgets
                        ScrollView {
                            id: widgetsScroll

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            GridLayout {
                                id: widgetsSection

                                width: widgetsScroll.width
                                columns: 3
                                columnSpacing: 14
                                rowSpacing: 14

                                Component.onCompleted: {
                                    root.validateSection(Config.widgets,
                                                         widgetsSection,
                                                         "Config.widgets",
                                                         null);
                                }

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
                                    label: "Jails"
                                    targetObject: Config.widgets
                                    targetProperty: "jails"
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
                            }
                        }

                        // bar
                        ScrollView {
                            id: barScroll

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            GridLayout {
                                width: barScroll.width
                                columns: 3
                                columnSpacing: 14
                                rowSpacing: 14

                                GridLayout {
                                    id: barSection

                                    implicitWidth: parent.width
                                    columns: 1
                                    columnSpacing: 14
                                    rowSpacing: 14

                                    Component.onCompleted: {
                                        root.validateSection(Config.bar,
                                                             barSection,
                                                             "Config.bar", 1);
                                    }

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
                                }

                                GridLayout {
                                    id: barTitleSection

                                    implicitWidth: parent.width
                                    columns: 1
                                    columnSpacing: 14
                                    rowSpacing: 14

                                    Component.onCompleted: {
                                        root.validateSection(Config.bar.title,
                                                             barTitleSection,
                                                             "Config.bar.title",
                                                             null);
                                    }

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
                                }
                            }
                        }

                        // notifications
                        ScrollView {
                            id: notificationsScroll

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            ColumnLayout {
                                width: parent.width
                                spacing: 14

                                ColumnLayout {
                                    id: notificationsSection

                                    implicitWidth: notificationsScroll.width
                                    spacing: 14

                                    Component.onCompleted: {
                                        root.validateSection(
                                                    Config.notifications,
                                                    notificationsSection,
                                                    "Config.notifications",
                                                    null);
                                    }

                                    SettingRow {
                                        label: "Enabled"
                                        targetObject: Config.notifications
                                        targetProperty: "enabled"
                                        valueType: "bool"
                                    }

                                    SettingRow {
                                        label: "Width"
                                        targetObject: Config.notifications
                                        targetProperty: "width"
                                        valueType: "int"
                                    }
                                }
                            }
                        }

                        // desktop
                        ScrollView {
                            id: desktopScroll

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            ColumnLayout {
                                width: parent.width
                                spacing: 14

                                ColumnLayout {
                                    id: desktopSection

                                    implicitWidth: desktopScroll.width
                                    spacing: 14

                                    Component.onCompleted: {
                                        root.validateSection(Config.desktop,
                                                             desktopSection,
                                                             "Config.desktop",
                                                             null);
                                    }

                                    SettingRow {
                                        label: "Launcher"
                                        targetObject: Config.desktop
                                        targetProperty: "launcher"
                                        valueType: "bool"
                                    }

                                    SettingRow {
                                        label: "OSD"
                                        targetObject: Config.desktop
                                        targetProperty: "osd"
                                        valueType: "bool"
                                    }
                                }
                            }
                        }

                        // workspaces
                        ScrollView {
                            id: workspaceScroll

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            GridLayout {
                                id: workspaceSection

                                width: workspaceScroll.width
                                columns: 3
                                columnSpacing: 14
                                rowSpacing: 14

                                Component.onCompleted: {
                                    root.validateSection(Config.workspaces,
                                                         workspaceSection,
                                                         "Config.workspaces",
                                                         null);
                                }

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
                            }
                        }

                        // dashboard
                        ScrollView {
                            id: dashboardScroll

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            ColumnLayout {
                                id: dashboardSection

                                width: dashboardScroll.width
                                spacing: 14

                                Component.onCompleted: {
                                    root.validateSection(Config.dashboard,
                                                         dashboardSection,
                                                         "Config.dashboard",
                                                         null);
                                }

                                SettingRow {
                                    label: "Disk"
                                    targetObject: Config.dashboard
                                    targetProperty: "disk"
                                    valueType: "string"
                                }

                                ColumnLayout {
                                    id: dashboardPlayerSection

                                    implicitWidth: parent.width
                                    spacing: 14

                                    Component.onCompleted: {
                                        root.validateSection(
                                                    Config.dashboard.player,
                                                    dashboardPlayerSection,
                                                    "Config.dashboard.player",
                                                    null);
                                    }

                                    SettingRow {
                                        label: "Queue buttons"
                                        targetObject: Config.dashboard.player
                                        targetProperty: "queueButtons"
                                        valueType: "bool"
                                    }

                                    SettingRow {
                                        label: "Track notifications"
                                        targetObject: Config.dashboard.player
                                        targetProperty: "notifications"
                                        valueType: "bool"
                                    }
                                }
                            }
                        }

                        // lockscreen
                        ScrollView {
                            id: lockscreenScroll

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            GridLayout {
                                id: lockscreenSection

                                width: lockscreenScroll.width
                                columns: 2
                                columnSpacing: 14
                                rowSpacing: 14

                                Component.onCompleted: {
                                    root.validateSection(Config.lockscreen,
                                                         lockscreenSection,
                                                         "Config.lockscreen",
                                                         null);
                                }

                                SettingRow {
                                    label: "Wallpaper"
                                    targetObject: Config.lockscreen
                                    targetProperty: "wallpaper"
                                    valueType: "path"
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
                            }
                        }

                        // session
                        ScrollView {
                            id: sessionScroll

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            ColumnLayout {
                                width: sessionScroll.width
                                spacing: 14

                                ColumnLayout {
                                    spacing: 14

                                    SettingRow {
                                        label: "Background color"
                                        targetObject: Config.session
                                        targetProperty: "background"
                                        valueType: "color"
                                    }
                                }

                                Text {
                                    text: "Timeouts"
                                    font.family: Config.general.fontFamily
                                    font.pixelSize: Config.general.fontSize + 2
                                    font.bold: true
                                    color: Config.colors.fg
                                    Layout.topMargin: 16
                                }

                                GridLayout {
                                    id: sessionTimeoutsSection

                                    columns: 3
                                    rows: 1
                                    columnSpacing: 14
                                    rowSpacing: 14

                                    Component.onCompleted: {
                                        root.validateSection(
                                                    Config.session.commands,
                                                    sessionCommandsSection,
                                                    "Config.session.timeouts",
                                                    null);
                                    }

                                    SettingRow {
                                        label: "Lock"
                                        targetObject: Config.session.timeouts
                                        targetProperty: "lock"
                                        valueType: "int"
                                    }

                                    SettingRow {
                                        label: "Display"
                                        targetObject: Config.session.timeouts
                                        targetProperty: "display"
                                        valueType: "int"
                                    }

                                    SettingRow {
                                        label: "Suspend"
                                        targetObject: Config.session.timeouts
                                        targetProperty: "suspend"
                                        valueType: "int"
                                    }
                                }

                                Text {
                                    text: "Commands"
                                    font.family: Config.general.fontFamily
                                    font.pixelSize: Config.general.fontSize + 2
                                    font.bold: true
                                    color: Config.colors.fg
                                    Layout.topMargin: 16
                                }

                                GridLayout {
                                    id: sessionCommandsSection

                                    columns: 2
                                    columnSpacing: 14
                                    rowSpacing: 14

                                    Component.onCompleted: {
                                        root.validateSection(
                                                    Config.session.commands,
                                                    sessionCommandsSection,
                                                    "Config.session.commands",
                                                    null);
                                    }

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
                                }
                            }
                        }

                        // about page
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            About {}
                        }
                    }

                    // buttons
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            border.width: 1
                            border.color: Config.colors.passive
                            color: "transparent"
                            implicitWidth: versionString.width + 12
                            implicitHeight: versionString.height + 6
                            radius: Config.general.cornerRadius

                            TextEdit {
                                id: versionString

                                anchors.centerIn: parent
                                text: root.version
                                font.family: Config.general.fontFamily
                                font.pixelSize: Config.general.fontSize
                                font.bold: false
                                color: Config.colors.fg
                                Layout.topMargin: 16
                                readOnly: true
                                selectByMouse: true
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        // OK button
                        Rectangle {
                            id: button

                            color: Config.colors.passive
                            implicitWidth: 60
                            implicitHeight: 32
                            radius: Config.general.cornerRadius

                            Behavior on color {
                                ColAnim {}
                            }

                            Text {
                                anchors.centerIn: parent
                                color: Config.colors.fg
                                font.family: Config.general.fontFamily
                                font.pixelSize: Config.general.fontSize
                                text: "OK"
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true

                                onClicked: States.settingsPresent = false
                                onEntered: button.color = Config.colors.accent
                                onExited: button.color = Config.colors.passive
                            }
                        }
                    }
                }
            }
        }
    }
}
