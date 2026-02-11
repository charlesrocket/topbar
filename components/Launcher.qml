pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import ".."

Loader {
    active: States.launcherPresent

    property color backgroundColor: "transparent"

    sourceComponent: PanelWindow {
        id: root

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        contentItem {
            Keys.onPressed: event => {
                if (event.key == Qt.Key_Escape) {
                    States.launcherPresent = false;
                }
            }
        }

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        Rectangle {
            color: "transparent"
            anchors.fill: parent

            MouseArea {
                anchors.fill: parent
                onClicked: States.launcherPresent = false

                Item {
                    anchors.top: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(parent.width * 0.5, 600)
                    height: container.height

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {}
                    }

                    Rectangle {
                        id: container
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        height: contentColumn.implicitHeight + 32
                        radius: Config.general.cornerRadius * 2
                        color: Config.colors.bg

                        ColumnLayout {
                            id: contentColumn
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            // search field
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 44
                                radius: Config.general.cornerRadius
                                color: Config.colors.extraDark
                                border.color: Config.colors.accent
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 8

                                    Text {
                                        text: ""
                                        font.pixelSize: 16
                                        font.family: "Symbols Nerd Font"
                                        Layout.leftMargin: 6
                                        color: Config.colors.fg
                                    }

                                    TextField {
                                        id: searchField
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        placeholderText: "Search applications"
                                        font.family: Config.general.fontFamily
                                        font.pixelSize: Config.general.fontSize
                                        font.bold: false
                                        color: Config.colors.fg
                                        background: Item {}

                                        Component.onCompleted: {
                                            forceActiveFocus();
                                        }

                                        onActiveFocusChanged: {
                                            if (activeFocus) {
                                                // active focus sets this to true
                                                cursorVisible = false;
                                            }
                                        }

                                        Keys.onReturnPressed: {
                                            if (appList.count > 0) {
                                                root.launchApp(appList.currentIndex >= 0 ? appList.currentIndex : 0);
                                            }
                                        }

                                        Keys.onEscapePressed: States.launcherPresent = false

                                        Keys.onDownPressed: {
                                            if (appList.count > 0) {
                                                appList.currentIndex = 0;
                                                appList.forceActiveFocus();
                                            }
                                        }
                                    }

                                    // clear button
                                    Rectangle {
                                        visible: searchField.text.length > 0
                                        Layout.preferredWidth: 24
                                        Layout.preferredHeight: 24
                                        radius: 12
                                        color: clearButton.containsMouse ? Config.colors.accent : Config.colors.passive

                                        Text {
                                            anchors.centerIn: parent
                                            text: "󱎘"
                                            font.pixelSize: 14
                                            font.family: "Symbols Nerd Font"
                                            color: Config.colors.fg
                                        }

                                        MouseArea {
                                            id: clearButton
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                searchField.text = "";
                                                searchField.forceActiveFocus();
                                            }
                                        }
                                    }
                                }
                            }

                            // results count
                            Text {
                                Layout.fillWidth: true
                                visible: appList.count > 0
                                font.pixelSize: 12
                                font.family: Config.general.fontFamily
                                color: Config.colors.fg
                                text: {
                                    var count = appList.count;
                                    return count === 1 ? "1 application found" : count + " applications found";
                                }
                            }

                            // application list
                            Rectangle {
                                id: listContainer
                                visible: appList.count > 0
                                color: Config.colors.extraDark
                                radius: Config.general.cornerRadius
                                clip: true
                                Layout.fillWidth: true
                                Layout.preferredHeight: {
                                    if (appList.count === 0)
                                        return 0;

                                    var visibleItems = Math.min(appList.count, 5);
                                    return (visibleItems * 64) + (visibleItems - 1) * 4 + 12;
                                }

                                ListView {
                                    id: appList
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    spacing: 4
                                    clip: true
                                    reuseItems: true
                                    add: null
                                    remove: null
                                    displaced: null
                                    populate: null
                                    move: null

                                    model: ScriptModel {
                                        id: filteredModel
                                        values: {
                                            var apps = DesktopEntries.applications.values;
                                            var searchText = searchField.text.toLowerCase().trim();

                                            if (searchText.length === 0) {
                                                // idle state
                                                return [];
                                            }

                                            // filter based on search
                                            var filtered = apps.filter(function (app) {
                                                var name = (app.name || "").toLowerCase();
                                                var description = (app.description || "").toLowerCase();
                                                var comment = (app.comment || "").toLowerCase();
                                                var genericName = (app.genericName || "").toLowerCase();

                                                return name.indexOf(searchText) !== -1 || description.indexOf(searchText) !== -1 || comment.indexOf(searchText) !== -1 || genericName.indexOf(searchText) !== -1;
                                            });

                                            // sort filtered results
                                            return [...filtered].sort(function (a, b) {
                                                var nameA = (a.name || "").toLowerCase();
                                                var nameB = (b.name || "").toLowerCase();
                                                return nameA.localeCompare(nameB);
                                            });
                                        }
                                    }

                                    boundsBehavior: Flickable.StopAtBounds

                                    highlight: Rectangle {
                                        color: Config.colors.accent
                                        radius: 6
                                        opacity: 0.4
                                    }

                                    highlightMoveDuration: 0

                                    Keys.onUpPressed: {
                                        if (currentIndex <= 0) {
                                            searchField.forceActiveFocus();
                                        } else {
                                            decrementCurrentIndex();
                                        }
                                    }

                                    Keys.onDownPressed: incrementCurrentIndex()
                                    Keys.onReturnPressed: root.launchApp(currentIndex)
                                    Keys.onEscapePressed: States.launcherPresent = false

                                    ScrollBar.vertical: ScrollBar {
                                        policy: ScrollBar.AsNeeded
                                        width: 8
                                    }

                                    delegate: Rectangle {
                                        id: appDelegate
                                        width: appList.width
                                        height: 64
                                        color: "transparent"
                                        border.width: delegateMouseArea.containsMouse ? 2 : 0
                                        border.color: Config.colors.accent
                                        radius: Config.general.cornerRadius

                                        required property var modelData
                                        required property int index

                                        MouseArea {
                                            id: delegateMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor

                                            onEntered: appList.currentIndex = appDelegate.index
                                            onClicked: root.launchApp(appDelegate.index)
                                            onDoubleClicked: root.launchApp(appDelegate.index)
                                        }

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 12

                                            // app icon
                                            Item {
                                                Layout.preferredWidth: 44
                                                Layout.preferredHeight: 44

                                                Image {
                                                    id: appIcon
                                                    anchors.fill: parent
                                                    source: {
                                                        if (!appDelegate.modelData.icon)
                                                            return "";

                                                        var iconPath = Quickshell.iconPath(appDelegate.modelData.icon, false);
                                                        return iconPath || "";
                                                    }

                                                    sourceSize.width: 44
                                                    sourceSize.height: 44
                                                    fillMode: Image.PreserveAspectFit
                                                    cache: true
                                                }

                                                // fallback
                                                Rectangle {
                                                    anchors.fill: parent
                                                    visible: appIcon.status !== Image.Ready
                                                    color: Config.colors.accent
                                                    radius: Config.general.cornerRadius

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: appDelegate.modelData.name ? appDelegate.modelData.name.charAt(0).toUpperCase() : "?"
                                                        font.pixelSize: 22
                                                        font.bold: true
                                                        font.family: Config.general.fontFamily
                                                        color: Config.colors.fg
                                                    }
                                                }
                                            }

                                            // app info
                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                spacing: 2

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: appDelegate.modelData.name || "Unknown"
                                                    font.pixelSize: 15
                                                    font.bold: true
                                                    font.family: Config.general.fontFamily
                                                    color: Config.colors.fg
                                                    elide: Text.ElideRight
                                                    wrapMode: Text.NoWrap
                                                }

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: appDelegate.modelData.description || appDelegate.modelData.comment || appDelegate.modelData.genericName || ""
                                                    font.pixelSize: 12
                                                    font.bold: true
                                                    font.family: Config.general.fontFamily
                                                    color: Config.colors.fg
                                                    elide: Text.ElideRight
                                                    opacity: 0.7
                                                    wrapMode: Text.NoWrap
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        function launchApp(index) {
            if (index < 0 || index >= appList.count)
                return;

            var app = appList.model.values[index];
            if (app) {
                app.execute();
                States.launcherPresent = false;
            }
        }
    }
}
