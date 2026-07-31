import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets

import TopBar.Networking

Scope {
    Component {
        id: editorComponent

        FloatingWindow {
            id: editorWindow

            required property var nmSettings

            color: contentItem.palette.window

            Component.onCompleted: editorArea.text = JSON.stringify(nmSettings.read(), null, 2)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10

                Label {
                    text: "Editing " + nmSettings?.id + " (" + nmSettings?.uuid + ")"
                    font.bold: true
                    font.pointSize: 12
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    TextArea {
                        id: editorArea

                        wrapMode: TextEdit.Wrap
                        selectByMouse: true
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        id: statusLabel

                        Layout.fillWidth: true
                        color: palette.placeholderText
                    }

                    Button {
                        text: "Reload"

                        onClicked: {
                            editorArea.text = JSON.stringify(editorWindow.nmSettings.read(), null, 2);
                            statusLabel.text = "Reloaded";
                        }
                    }

                    Button {
                        text: "Save"

                        onClicked: {
                            try {
                                const parsed = JSON.parse(editorArea.text);
                                nmSettings.write(parsed);
                                statusLabel.text = "Saved";
                            } catch (e) {
                                statusLabel.text = "Parse error: " + e.message;
                            }
                        }
                    }

                    Button {
                        text: "Close"

                        onClicked: {
                            editorArea.focus = false;
                            editorWindow.destroy();
                        }
                    }
                }
            }
        }
    }

    FloatingWindow {
        color: contentItem.palette.window

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 5

            ColumnLayout {
                Label {
                    text: `Networking (${NetworkBackendType.toString(Networking.backend)} backend)`
                    font.bold: true
                    font.pointSize: 12
                }

                RowLayout {
                    Label {
                        text: `Connectivity`
                        font.bold: true
                    }

                    Label {
                        text: `${NetworkConnectivity.toString(Networking.connectivity)}`
                        visible: Networking.canCheckConnectivity
                    }

                    Button {
                        text: "Re-check"
                        visible: Networking.canCheckConnectivity && Networking.connectivityCheckEnabled

                        onClicked: Networking.checkConnectivity()
                    }

                    CheckBox {
                        text: "Checking enabled"
                        checked: Networking.connectivityCheckEnabled
                        visible: Networking.canCheckConnectivity

                        onClicked: Networking.connectivityCheckEnabled = !Networking.connectivityCheckEnabled
                    }

                    CheckBox {
                        enabled: false
                        text: "Supported"
                        checked: Networking.canCheckConnectivity
                    }
                }
            }

            Column {
                Layout.fillWidth: true

                RowLayout {
                    Label {
                        text: "WiFi"
                        font.bold: true
                    }

                    CheckBox {
                        text: "Software"
                        checked: Networking.wifiEnabled

                        onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                    }

                    CheckBox {
                        enabled: false
                        text: "Hardware"
                        checked: Networking.wifiHardwareEnabled
                    }
                }
            }

            ListView {
                clip: true
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: Networking.devices

                delegate: WrapperRectangle {
                    width: parent.width
                    color: "transparent"
                    border.color: palette.button
                    border.width: 1
                    margin: 5

                    ColumnLayout {
                        RowLayout {
                            Label {
                                text: modelData.name
                                font.bold: true
                            }

                            Label {
                                text: modelData.address
                            }

                            Label {
                                text: `(Type: ${DeviceType.toString(modelData.type)})`
                            }

                            CheckBox {
                                text: `Managed`
                                checked: modelData.nmManaged

                                onClicked: modelData.nmManaged = !modelData.nmManaged
                            }
                        }

                        RowLayout {
                            Label {
                                text: ConnectionState.toString(modelData.state)
                                color: modelData.connected ? palette.link : palette.placeholderText
                            }

                            Button {
                                visible: modelData.state == ConnectionState.Connected
                                text: "Disconnect"

                                onClicked: modelData.disconnect()
                            }

                            CheckBox {
                                text: "Autoconnect"
                                checked: modelData.autoconnect

                                onClicked: modelData.autoconnect = !modelData.autoconnect
                            }

                            Label {
                                text: `Mode: ${WifiDeviceMode.toString(modelData.mode)}`
                                visible: modelData.type == DeviceType.Wifi
                            }

                            CheckBox {
                                text: "Scanner"
                                checked: modelData.scannerEnabled
                                visible: modelData.type === DeviceType.Wifi

                                onClicked: modelData.scannerEnabled = !modelData.scannerEnabled
                            }
                        }

                        Repeater {
                            Layout.fillWidth: true

                            model: ScriptModel {
                                values: [...modelData.networks.values].sort((a, b) => {
                                    if (a.connected !== b.connected) {
                                        return b.connected - a.connected;
                                    }
                                    return b.signalStrength - a.signalStrength;
                                })
                            }

                            WrapperRectangle {
                                property var chosenSettings: {
                                    const settings = modelData.nmSettings;
                                    if (!settings || settings.length === 0) {
                                        return null;
                                    }
                                    if (settings.length === 1) {
                                        return settings[0];
                                    }
                                    return settings[settingsComboBox.currentIndex];
                                }

                                Layout.fillWidth: true
                                color: modelData.connected ? palette.highlight : palette.button
                                border.color: palette.mid
                                border.width: 1
                                margin: 5

                                Connections {
                                    function onConnectionFailed(reason) {
                                        failLoader.sourceComponent = failComponent;
                                        failLoader.item.failReason = reason;
                                    }

                                    function onStateChanged() {
                                        if (modelData.state == ConnectionState.Connecting) {
                                            failLoader.sourceComponent = null;
                                        }
                                    }

                                    target: modelData
                                }

                                Component {
                                    id: failComponent

                                    RowLayout {
                                        property var failReason

                                        Label {
                                            text: ConnectionFailReason.toString(failReason)
                                        }

                                        RowLayout {
                                            visible: modelData.security === WifiSecurityType.WpaPsk || modelData.security === WifiSecurityType.Wpa2Psk || modelData.security === WifiSecurityType.Sae

                                            TextField {
                                                id: pskField

                                                placeholderText: "PSK"
                                            }

                                            Button {
                                                text: "Set"
                                                visible: pskField.visible

                                                onClicked: {
                                                    modelData.connectWithPsk(pskField.text);
                                                    failLoader.sourceComponent = null;
                                                }
                                            }
                                        }

                                        Button {
                                            text: "Close"

                                            onClicked: failLoader.sourceComponent = null
                                        }
                                    }
                                }

                                RowLayout {
                                    ColumnLayout {
                                        Layout.fillWidth: true

                                        RowLayout {
                                            Label {
                                                text: modelData.name
                                                font.bold: true
                                            }

                                            Label {
                                                text: modelData.known ? "Known" : ""
                                                color: palette.placeholderText
                                            }
                                        }

                                        RowLayout {
                                            Label {
                                                text: `Security: ${WifiSecurityType.toString(modelData.security)}`
                                                color: palette.placeholderText
                                            }

                                            Label {
                                                text: `| Signal strength: ${Math.round(modelData.signalStrength * 100)}%`
                                                color: palette.placeholderText
                                            }
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.alignment: Qt.AlignRight

                                        RowLayout {
                                            Layout.alignment: Qt.AlignRight

                                            BusyIndicator {
                                                implicitHeight: 30
                                                implicitWidth: 30
                                                running: modelData.stateChanging
                                                visible: modelData.stateChanging
                                            }

                                            Label {
                                                text: ConnectionState.toString(modelData.state)
                                                color: modelData.connected ? palette.link : palette.placeholderText
                                            }

                                            RowLayout {
                                                visible: modelData.nmSettings.length > 1

                                                Label {
                                                    text: "Choose settings:"
                                                }

                                                ComboBox {
                                                    id: settingsComboBox

                                                    model: modelData.nmSettings.map(s => s?.read()?.connection?.id)
                                                    currentIndex: 0
                                                }
                                            }

                                            Button {
                                                text: "Connect"
                                                visible: !modelData.connected

                                                onClicked: {
                                                    if (chosenSettings)
                                                        modelData.connectWithSettings(chosenSettings);
                                                    else
                                                        modelData.connect();
                                                }
                                            }

                                            Button {
                                                text: "Disconnect"
                                                visible: modelData.connected

                                                onClicked: modelData.disconnect()
                                            }

                                            Button {
                                                text: "Forget"
                                                visible: modelData.known

                                                onClicked: modelData.forget()
                                            }

                                            Button {
                                                text: "Edit"
                                                visible: modelData.known

                                                onClicked: {
                                                    if (chosenSettings)
                                                        editorComponent.createObject(null, {
                                                            nmSettings: chosenSettings
                                                        });
                                                }
                                            }
                                        }

                                        Loader {
                                            id: failLoader

                                            Layout.alignment: Qt.AlignRight
                                            visible: sourceComponent !== null
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
