import QtQuick
import QtQuick.Layouts

import "../widgets"
import "../.."

RowLayout {
    Layout.preferredWidth: parent.width / 3
    spacing: 6

    // workspaces
    Loader {
        id: wrkspc
        active: Config.widgets.workspaces
        visible: wrkspc.active
        asynchronous: true
        Layout.alignment: Qt.AlignVCenter

        sourceComponent: Item {
            implicitWidth: workspaceRow.implicitWidth
            implicitHeight: workspaceRow.implicitHeight

            RowLayout {
                id: workspaceRow
                spacing: 6

                HyprWorkspaces {
                    names: [Config.workspaces.one, Config.workspaces.two, Config.workspaces.three, Config.workspaces.four, Config.workspaces.five, Config.workspaces.six, Config.workspaces.seven, Config.workspaces.eight, Config.workspaces.nine, Config.workspaces.ten]
                }
            }
        }
    }

    Item {
        Layout.fillWidth: true
    }
}
