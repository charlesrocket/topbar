import QtQuick
import QtQuick.Layouts

import qs.core
import qs.widgets
import qs.widgets.hypr as Hypr
import qs.widgets.mango as Mango
import qs.widgets.nullspace as Nullspace

RowLayout {
    Layout.preferredWidth: parent.width / 3
    spacing: 6

    Loader {
        id: wrkspc

        active: Config.bar.widgets.workspaces
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
                sourceComponent: switch (States.desktop) {
                                 case "nullspace":
                                     return nullspace;
                                 case "mango":
                                     return mango;
                                 case "hyprland":
                                     return hypr;
                                 default:
                                     return menu;
                                 }
            }

            Component {
                id: nullspace

                Nullspace.Workspaces {
                    names: [Config.workspaces.one, Config.workspaces.two,
                        Config.workspaces.three, Config.workspaces.four,
                        Config.workspaces.five, Config.workspaces.six,
                        Config.workspaces.seven, Config.workspaces.eight,
                        Config.workspaces.nine, Config.workspaces.zero]
                }
            }

            Component {
                id: mango

                Mango.Workspaces {
                    names: [Config.workspaces.one, Config.workspaces.two,
                        Config.workspaces.three, Config.workspaces.four,
                        Config.workspaces.five, Config.workspaces.six,
                        Config.workspaces.seven, Config.workspaces.eight,
                        Config.workspaces.nine, Config.workspaces.zero]
                }
            }

            Component {
                id: hypr

                Hypr.Workspaces {
                    names: [Config.workspaces.one, Config.workspaces.two,
                        Config.workspaces.three, Config.workspaces.four,
                        Config.workspaces.five, Config.workspaces.six,
                        Config.workspaces.seven, Config.workspaces.eight,
                        Config.workspaces.nine, Config.workspaces.zero]
                }
            }

            Component {
                id: menu

                StartMenu {}
            }
        }
    }

    Item {
        Layout.fillWidth: true
    }
}
