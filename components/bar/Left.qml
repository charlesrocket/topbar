import QtQuick
import QtQuick.Layouts

import qs
import qs.widgets.dwl as DWL
import qs.widgets.hypr as Hypr

RowLayout {
    Layout.preferredWidth: parent.width / 3
    spacing: 6

    Loader {
        id: wrkspc

        active: Config.widgets.workspaces
        visible: wrkspc.active
        asynchronous: true
        Layout.alignment: Qt.AlignVCenter
        sourceComponent: active ? workspacesComponent : null
    }

    Component {
        id: workspacesComponent

        RowLayout {
            Loader {
                asynchronous: true
                sourceComponent: switch (System.desktop) {
                                 case "mango":
                                     return dwl;
                                 case "hyprland":
                                     return hypr;
                                 }
            }

            Component {
                id: dwl

                DWL.Workspaces {
                    names: [Config.workspaces.one, Config.workspaces.two,
                        Config.workspaces.three, Config.workspaces.four,
                        Config.workspaces.five, Config.workspaces.six,
                        Config.workspaces.seven, Config.workspaces.eight,
                        Config.workspaces.nine, Config.workspaces.ten]
                }
            }

            Component {
                id: hypr

                Hypr.Workspaces {
                    names: [Config.workspaces.one, Config.workspaces.two,
                        Config.workspaces.three, Config.workspaces.four,
                        Config.workspaces.five, Config.workspaces.six,
                        Config.workspaces.seven, Config.workspaces.eight,
                        Config.workspaces.nine, Config.workspaces.ten]
                }
            }
        }
    }

    Item {
        Layout.fillWidth: true
    }
}
