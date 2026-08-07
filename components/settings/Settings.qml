import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import Quickshell

import TopBar

import qs
import qs.core

FloatingWindow {
    id: root

    property int gap: 6
    property int fontSize: Config.general.fontSize

    function validateSection(obj, section, key, offset) {
        var configCount = Utils.getPropertyCount(obj);

        if (offset != null)
            configCount -= offset;

        if (configCount != section.children.length)
            console.warn("Validation failed for " + key + " " + configCount
                         + " != " + section.children.length);
    }

    minimumSize: "900x700"
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

    FileDialog {
        id: fileDialog

        title: "Select profile image"
        nameFilters: ["Image files (*.png *.jpg *.jpeg *.bmp *.gif *.svg)"]

        onAccepted: {
            var path = fileDialog.selectedFile;
            if (path)
                System.changeUserIcon(path);
        }
    }

    Rectangle {
        anchors.fill: parent
        color: States.ecoMode ? Config.colors.bge : Config.colors.bg
        radius: Config.general.cornerRadius

        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 0

            // vertical tab bar + content
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                // tab bar
                Rectangle {
                    color: "transparent"
                    radius: Config.general.cornerRadius
                    Layout.preferredWidth: 186
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.fill: parent

                        Rectangle {
                            color: Qt.darker(Config.colors.extraDark, 1.1)
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            radius: Config.general.cornerRadius

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 4

                                Row {
                                    spacing: 6
                                    Layout.bottomMargin: 12
                                    Layout.alignment: Qt.AlignLeft

                                    Text {
                                        id: header

                                        color: Config.colors.fg
                                        font.family: Config.general.fontFamily
                                        font.pixelSize: 20
                                        font.bold: true
                                        text: "TopBar"
                                    }

                                    Text {
                                        color: Qt.rgba(header.color.r,
                                                       header.color.g,
                                                       header.color.b, 0.5)
                                        font.family: header.font.family
                                        font.pixelSize: 16
                                        anchors.baseline: header.baseline
                                        text: Version.major + "."
                                              + Version.minor
                                    }
                                }

                                Repeater {
                                    model: ["General", "Colors", "Bar",
                                        "Notifications", "Desktop", "Spaces",
                                        "Dashboard", "Lockscreen", "Session",
                                        "About"]

                                    delegate: Button {
                                        id: tabButton

                                        required property var modelData
                                        required property int index

                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 36
                                        checked: tabBar.currentIndex === index

                                        background: Rectangle {
                                            radius: Config.general.cornerRadius
                                            color: tabButton.checked
                                                   ? Config.colors.accent : (
                                                         tabButton.hovered
                                                         ? Qt.rgba(1, 1, 1,
                                                                   0.05) : "transparent")

                                            Behavior on color {
                                                ColAnim {}
                                            }
                                        }
                                        contentItem: Text {
                                            text: tabButton.modelData
                                            font.family:
                                                Config.general.fontFamily
                                            font.pixelSize:
                                                Config.general.fontSize
                                            font.bold: tabButton.checked
                                            color: tabButton.checked
                                                   ? Config.colors.bge :
                                                     Config.colors.fg
                                            leftPadding: 12
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignLeft
                                        }

                                        onClicked: tabBar.currentIndex = index
                                    }
                                }

                                Item {
                                    Layout.fillHeight: true
                                }
                            }
                        }
                    }
                }

                // drives SwipeView currentIndex
                TabBar {
                    id: tabBar

                    visible: false

                    Repeater {
                        model: 10

                        TabButton {}
                    }
                }

                // content
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 8

                    SettingLabel {
                        label: "User"
                    }

                    ColumnLayout {
                        Rectangle {
                            color: Qt.darker(Config.colors.extraDark, 1.1)
                            Layout.fillWidth: true
                            implicitHeight: 100
                            radius: Config.general.cornerRadius
                            clip: true

                            Canvas {
                                id: stripes

                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: 92

                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.clearRect(0, 0, width, height);

                                    var stripeWidth = 20;
                                    var gap = 20;
                                    var starts = [8, stripeWidth + gap,
                                                  stripeWidth + gap];
                                    var h = height;

                                    ctx.fillStyle = Config.colors.accent;

                                    for (var i = 0; i < starts.length; i++) {
                                        var x0 = starts[i];
                                        ctx.beginPath();
                                        // top-left
                                        ctx.moveTo(x0, 0);
                                        // top-right
                                        ctx.lineTo(x0 + stripeWidth, 0);
                                        // bottom-right
                                        ctx.lineTo(x0 + stripeWidth + h, h);
                                        // bottom-left
                                        ctx.lineTo(x0 + h, h);
                                        ctx.closePath();
                                        ctx.fill();
                                    }
                                }

                                Connections {
                                    function onAccentChanged() {
                                        stripes.requestPaint();
                                    }

                                    target: Config.colors
                                }
                            }

                            RowLayout {
                                id: userBox

                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.leftMargin: 12
                                spacing: 12

                                Item {
                                    Layout.preferredWidth: 80
                                    Layout.preferredHeight: 80

                                    UserImage {
                                        anchors.fill: parent
                                        shadow: false
                                    }

                                    Canvas {
                                        anchors.fill: parent

                                        onPaint: {
                                            var ctx = getContext("2d");
                                            var topY = height - 22;
                                            var cx = width / 2;
                                            var cy = height / 2;
                                            var r = Math.min(width, height) / 2;

                                            var dx = Math.sqrt(r * r - Math.pow(
                                                                   topY - cy,
                                                                   2));
                                            var xLeft = cx - dx;
                                            var xRight = cx + dx;

                                            ctx.beginPath();
                                            ctx.moveTo(xLeft, topY);
                                            ctx.lineTo(xRight, topY);
                                            ctx.arc(cx, cy, r, Math.atan2(topY
                                                                          - cy, xRight
                                                                          - cx), Math.atan2(
                                                        topY - cy, xLeft - cx),
                                                    false);
                                            ctx.closePath();

                                            ctx.fillStyle = Qt.rgba(0, 0, 0,
                                                                    0.6);
                                            ctx.fill();
                                        }
                                    }

                                    Text {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: 4
                                        text: "EDIT"
                                        horizontalAlignment: Text.AlignHCenter
                                        color: Config.colors.fg
                                        font.family: "Hack Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor

                                        onClicked: fileDialog.open()
                                    }
                                }

                                ColumnLayout {
                                    spacing: 6

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        Text {
                                            color: Config.colors.fg
                                            font.pixelSize: root.fontSize * 1.8
                                            font.bold: true
                                            font.family:
                                                Config.general.fontFamily
                                            horizontalAlignment: Text.AlignLeft
                                            verticalAlignment: Text.AlignVCenter
                                            text: System.userName
                                        }
                                    }

                                    RowLayout {
                                        Text {
                                            color: Config.colors.fg
                                            font.family:
                                                Config.general.fontFamily
                                            font.pixelSize: root.fontSize * 1.1
                                            horizontalAlignment: Text.AlignLeft
                                            verticalAlignment: Text.AlignVCenter
                                            text: System.user
                                        }
                                    }
                                }
                            }
                        }
                    }

                    SwipeView {
                        currentIndex: tabBar.currentIndex
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        orientation: Qt.Vertical
                        interactive: false
                        clip: true

                        // general
                        Loader {
                            active: SwipeView.isCurrentItem
                                    || SwipeView.isNextItem
                                    || SwipeView.isPreviousItem

                            sourceComponent: FadingScrollView {
                                id: generalScroll

                                ColumnLayout {
                                    width: generalScroll.scrollView.width
                                    spacing: root.gap
                                }

                                ColumnLayout {
                                    id: generalSection

                                    implicitWidth: parent.width
                                    spacing: root.gap

                                    Component.onCompleted: {
                                        root.validateSection(Config.general,
                                                             generalSection,
                                                             "Config.general",
                                                             -1);
                                    }

                                    SettingLabel {
                                        label: "System"
                                    }

                                    SettingRow {
                                        label: "Locale"
                                        targetObject: Config.general
                                        targetProperty: "locale"
                                        valueType: "string"
                                        first: true
                                        description:
                                            "Language, country, and character encoding."
                                    }

                                    SettingRow {
                                        label: "Font family"
                                        targetObject: Config.general
                                        targetProperty: "fontFamily"
                                        valueType: "font"
                                    }

                                    SettingRow {
                                        label: "Font Size"
                                        targetObject: Config.general
                                        targetProperty: "fontSize"
                                        valueType: "int"
                                        sliderFrom: 2
                                        sliderTo: 65
                                        sliderStepSize: 1
                                    }

                                    SettingRow {
                                        label: "Border width"
                                        targetObject: Config.general
                                        targetProperty: "borderWidth"
                                        valueType: "int"
                                        sliderFrom: 0
                                        sliderTo: 50
                                        sliderStepSize: 1
                                    }

                                    SettingRow {
                                        label: "Corner radius"
                                        targetObject: Config.general
                                        targetProperty: "cornerRadius"
                                        valueType: "int"
                                        sliderFrom: 0
                                        sliderTo: 20
                                        sliderStepSize: 1
                                    }

                                    SettingRow {
                                        label: "Animation duration"
                                        targetObject: Config.general
                                        targetProperty: "animDuration"
                                        valueType: "int"
                                        sliderFrom: 0
                                        sliderTo: 1000
                                        sliderStepSize: 1
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

                                    SettingRow {
                                        label: "Config watch"
                                        targetObject: Config.general
                                        targetProperty: "configWatch"
                                        valueType: "bool"
                                        last: true
                                        description:
                                            "Reload on configuration file changes."
                                    }
                                }
                            }
                        }

                        // colors
                        Loader {
                            active: SwipeView.isCurrentItem
                                    || SwipeView.isNextItem
                                    || SwipeView.isPreviousItem

                            sourceComponent: FadingScrollView {
                                id: colorsScroll

                                ColumnLayout {
                                    id: colorsSection

                                    width: colorsScroll.scrollView.width
                                    spacing: root.gap

                                    Component.onCompleted: {
                                        root.validateSection(Config.colors,
                                                             colorsSection,
                                                             "Config.colors",
                                                             null);
                                    }

                                    SettingRow {
                                        label: "Background"
                                        targetObject: Config.colors
                                        targetProperty: "bg"
                                        valueType: "color"
                                        first: true
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
                                        last: true
                                    }
                                }
                            }
                        }

                        // bar
                        Loader {
                            active: SwipeView.isCurrentItem
                                    || SwipeView.isNextItem
                                    || SwipeView.isPreviousItem

                            sourceComponent: FadingScrollView {
                                id: barScroll

                                ColumnLayout {
                                    width: barScroll.scrollView.width
                                    spacing: root.gap

                                    ColumnLayout {
                                        width: parent.width
                                        spacing: root.gap

                                        SettingLabel {
                                            label: "Layout"
                                        }

                                        ColumnLayout {
                                            id: barSection

                                            implicitWidth: parent.width
                                            spacing: root.gap

                                            Component.onCompleted: {
                                                root.validateSection(Config.bar,
                                                                     barSection,
                                                                     "Config.bar",
                                                                     2);
                                            }

                                            SettingRow {
                                                label: "Height"
                                                targetObject: Config.bar
                                                targetProperty: "height"
                                                valueType: "int"
                                                sliderFrom: 8
                                                sliderTo: 100
                                                sliderStepSize: 1
                                                first: true
                                            }

                                            SettingRow {
                                                label: "Padding"
                                                targetObject: Config.bar
                                                targetProperty: "padding"
                                                valueType: "int"
                                                sliderFrom: 0
                                                sliderTo: 32
                                                sliderStepSize: 1
                                                last: true
                                            }
                                        }

                                        ColumnLayout {
                                            id: barTitleSection

                                            implicitWidth: parent.width
                                            spacing: root.gap

                                            Component.onCompleted: {
                                                root.validateSection(
                                                            Config.bar.title,
                                                            barTitleSection,
                                                            "Config.bar.title",
                                                            null);
                                            }

                                            SettingRow {
                                                label: "Width"
                                                targetObject: Config.bar.title
                                                targetProperty: "width"
                                                valueType: "int"
                                                sliderFrom: 120
                                                sliderTo: 2000
                                                sliderStepSize: 1
                                                first: true
                                            }

                                            SettingRow {
                                                label: "Placeholder"
                                                targetObject: Config.bar.title
                                                targetProperty: "empty"
                                                valueType: "string"
                                                last: true
                                                description:
                                                    "Empty window title text."
                                            }
                                        }
                                    }

                                    SettingLabel {
                                        label: "Widgets"
                                    }

                                    ColumnLayout {
                                        id: widgetsSection

                                        width: parent.width
                                        spacing: root.gap

                                        Component.onCompleted: {
                                            root.validateSection(
                                                        Config.bar.widgets,
                                                        widgetsSection,
                                                        "Config.bar.widgets",
                                                        null);
                                        }

                                        SettingRow {
                                            label: "Workspaces"
                                            targetObject: Config.bar.widgets
                                            targetProperty: "workspaces"
                                            valueType: "bool"
                                            first: true
                                        }

                                        SettingRow {
                                            label: "Title"
                                            targetObject: Config.bar.widgets
                                            targetProperty: "title"
                                            valueType: "bool"
                                        }

                                        SettingRow {
                                            label: "Stats"
                                            targetObject: Config.bar.widgets
                                            targetProperty: "stats"
                                            valueType: "bool"
                                        }

                                        SettingRow {
                                            label: "Audio"
                                            targetObject: Config.bar.widgets
                                            targetProperty: "audio"
                                            valueType: "bool"
                                        }

                                        SettingRow {
                                            label: "Bluetooth"
                                            targetObject: Config.bar.widgets
                                            targetProperty: "bluetooth"
                                            valueType: "bool"
                                        }

                                        SettingRow {
                                            label: "Network"
                                            targetObject: Config.bar.widgets
                                            targetProperty: "network"
                                            valueType: "bool"
                                        }

                                        SettingRow {
                                            label: "Tray"
                                            targetObject: Config.bar.widgets
                                            targetProperty: "tray"
                                            valueType: "bool"
                                        }

                                        SettingRow {
                                            label: "Jails"
                                            targetObject: Config.bar.widgets
                                            targetProperty: "jails"
                                            valueType: "bool"
                                        }

                                        SettingRow {
                                            label: "Weather"
                                            targetObject: Config.bar.widgets
                                            targetProperty: "weather"
                                            valueType: "bool"
                                        }

                                        SettingRow {
                                            label: "Language"
                                            targetObject: Config.bar.widgets
                                            targetProperty: "language"
                                            valueType: "bool"
                                        }

                                        SettingRow {
                                            label: "Clock"
                                            targetObject: Config.bar.widgets
                                            targetProperty: "clock"
                                            valueType: "bool"
                                        }

                                        SettingRow {
                                            label: "Battery"
                                            targetObject: Config.bar.widgets
                                            targetProperty: "battery"
                                            valueType: "bool"
                                            last: true
                                        }
                                    }
                                }
                            }
                        }

                        // notifications
                        Loader {
                            active: SwipeView.isCurrentItem
                                    || SwipeView.isNextItem
                                    || SwipeView.isPreviousItem

                            sourceComponent: FadingScrollView {
                                id: notificationsScroll

                                ColumnLayout {
                                    width: notificationsScroll.scrollView.width
                                    spacing: root.gap

                                    ColumnLayout {
                                        id: notificationsSection

                                        implicitWidth: notificationsScroll.width
                                        spacing: root.gap

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
                                            first: true
                                        }

                                        SettingRow {
                                            label: "Width"
                                            targetObject: Config.notifications
                                            targetProperty: "width"
                                            valueType: "int"
                                            sliderFrom: 10
                                            sliderTo: 1000
                                            sliderStepSize: 1
                                            last: true
                                        }
                                    }
                                }
                            }
                        }

                        // desktop
                        Loader {
                            active: SwipeView.isCurrentItem
                                    || SwipeView.isNextItem
                                    || SwipeView.isPreviousItem

                            sourceComponent: FadingScrollView {
                                id: desktopScroll

                                ColumnLayout {
                                    width: desktopScroll.scrollView.width
                                    spacing: root.gap

                                    ColumnLayout {
                                        id: desktopSection

                                        implicitWidth: desktopScroll.width
                                        spacing: root.gap

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
                                            first: true
                                            description: "Application launcher."
                                        }

                                        SettingRow {
                                            label: "OSD"
                                            targetObject: Config.desktop
                                            targetProperty: "osd"
                                            valueType: "bool"
                                            last: true
                                            description: "On-screen display."
                                        }
                                    }
                                }
                            }
                        }

                        // workspaces
                        Loader {
                            active: SwipeView.isCurrentItem
                                    || SwipeView.isNextItem
                                    || SwipeView.isPreviousItem

                            sourceComponent: FadingScrollView {
                                id: workspaceScroll

                                ColumnLayout {
                                    id: workspaceSection

                                    width: workspaceScroll.scrollView.width
                                    spacing: root.gap

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
                                        first: true
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
                                        last: true
                                    }
                                }
                            }
                        }

                        // dashboard
                        Loader {
                            active: SwipeView.isCurrentItem
                                    || SwipeView.isNextItem
                                    || SwipeView.isPreviousItem

                            sourceComponent: FadingScrollView {
                                id: dashboardScroll

                                ColumnLayout {
                                    id: dashboardSection

                                    width: dashboardScroll.scrollView.width
                                    spacing: root.gap

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
                                        first: true
                                        last: true
                                        description:
                                            "Mounting point of the probe."
                                    }

                                    ColumnLayout {
                                        id: dashboardPlayerSection

                                        implicitWidth: parent.width
                                        spacing: root.gap

                                        Component.onCompleted: {
                                            root.validateSection(
                                                        Config.dashboard.player,
                                                        dashboardPlayerSection,
                                                        "Config.dashboard.player",
                                                        null);
                                        }

                                        SettingRow {
                                            label: "Queue buttons"
                                            targetObject:
                                                Config.dashboard.player
                                            targetProperty: "queueButtons"
                                            valueType: "bool"
                                            first: true
                                            description:
                                                "Shuffle and repeat controls."
                                        }

                                        SettingRow {
                                            label: "Track notifications"
                                            targetObject:
                                                Config.dashboard.player
                                            targetProperty: "notifications"
                                            valueType: "bool"
                                            last: true
                                            description:
                                                "Send a desktop notification on track changes."
                                        }
                                    }
                                }
                            }
                        }

                        // lockscreen
                        Loader {
                            active: SwipeView.isCurrentItem
                                    || SwipeView.isNextItem
                                    || SwipeView.isPreviousItem

                            sourceComponent: FadingScrollView {
                                id: lockscreenScroll

                                ColumnLayout {
                                    id: lockscreenSection

                                    width: lockscreenScroll.scrollView.width
                                    spacing: root.gap

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
                                        first: true
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
                                        last: true
                                    }
                                }
                            }
                        }

                        // session
                        Loader {
                            active: SwipeView.isCurrentItem
                                    || SwipeView.isNextItem
                                    || SwipeView.isPreviousItem

                            sourceComponent: FadingScrollView {
                                id: sessionScroll

                                ColumnLayout {
                                    width: sessionScroll.scrollView.width
                                    spacing: root.gap

                                    ColumnLayout {
                                        spacing: root.gap

                                        SettingRow {
                                            label: "Background color"
                                            targetObject: Config.session
                                            targetProperty: "background"
                                            valueType: "color"
                                            first: true
                                            last: true
                                        }
                                    }

                                    SettingLabel {
                                        label: "Timeouts"
                                    }

                                    ColumnLayout {
                                        id: sessionTimeoutsSection

                                        spacing: root.gap

                                        Component.onCompleted: {
                                            root.validateSection(
                                                        Config.session.commands,
                                                        sessionCommandsSection,
                                                        "Config.session.timeouts",
                                                        null);
                                        }

                                        SettingRow {
                                            label: "Lock"
                                            targetObject:
                                                Config.session.timeouts
                                            targetProperty: "lock"
                                            valueType: "int"
                                            sliderFrom: 1
                                            sliderTo: 10000
                                            sliderStepSize: 1
                                            first: true
                                        }

                                        SettingRow {
                                            label: "Display"
                                            targetObject:
                                                Config.session.timeouts
                                            targetProperty: "display"
                                            sliderFrom: 3
                                            sliderTo: 10000
                                            sliderStepSize: 1
                                            valueType: "int"
                                        }

                                        SettingRow {
                                            label: "Suspend"
                                            targetObject:
                                                Config.session.timeouts
                                            targetProperty: "suspend"
                                            valueType: "int"
                                            sliderFrom: 5
                                            sliderTo: 10000
                                            sliderStepSize: 1
                                            last: true
                                        }
                                    }

                                    SettingLabel {
                                        label: "Commands"
                                    }

                                    ColumnLayout {
                                        id: sessionCommandsSection

                                        spacing: root.gap

                                        Component.onCompleted: {
                                            root.validateSection(
                                                        Config.session.commands,
                                                        sessionCommandsSection,
                                                        "Config.session.commands",
                                                        null);
                                        }

                                        SettingRow {
                                            label: "Lock"
                                            targetObject:
                                                Config.session.commands
                                            targetProperty: "lock"
                                            valueType: "string"
                                            first: true
                                        }

                                        SettingRow {
                                            label: "Logout"
                                            targetObject:
                                                Config.session.commands
                                            targetProperty: "logout"
                                            valueType: "string"
                                        }

                                        SettingRow {
                                            label: "Suspend"
                                            targetObject:
                                                Config.session.commands
                                            targetProperty: "suspend"
                                            valueType: "string"
                                        }

                                        SettingRow {
                                            label: "Hibernate"
                                            targetObject:
                                                Config.session.commands
                                            targetProperty: "hibernate"
                                            valueType: "string"
                                        }

                                        SettingRow {
                                            label: "Shutdown"
                                            targetObject:
                                                Config.session.commands
                                            targetProperty: "shutdown"
                                            valueType: "string"
                                        }

                                        SettingRow {
                                            label: "Reboot"
                                            targetObject:
                                                Config.session.commands
                                            targetProperty: "reboot"
                                            valueType: "string"
                                            last: true
                                        }
                                    }
                                }
                            }
                        }

                        // about page
                        Loader {
                            active: SwipeView.isCurrentItem
                                    || SwipeView.isNextItem
                                    || SwipeView.isPreviousItem

                            sourceComponent: FadingScrollView {
                                id: aboutScroll

                                About {
                                    width: aboutScroll.scrollView.width
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component SettingLabel: Text {
        required property string label

        text: label
        font.family: Config.general.fontFamily
        Layout.topMargin: 6
        Layout.bottomMargin: 6
        font.pixelSize: Config.general.fontSize + 4
        font.bold: true
        color: Config.colors.fg
    }
}
