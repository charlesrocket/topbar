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

        sourceComponent: Item {
            implicitWidth: workspaceRow.implicitWidth
            implicitHeight: workspaceRow.implicitHeight

            RowLayout {
                id: workspaceRow
                spacing: 6

                HyprWorkspaces {
                    names: [Config.ws01, Config.ws02, Config.ws03, Config.ws04, Config.ws05, Config.ws06, Config.ws07, Config.ws08, Config.ws09, Config.ws10]
                }
            }
        }
    }

    Item {
        Layout.fillWidth: true
    }
}
