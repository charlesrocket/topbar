import QtQuick
import QtQuick.Layouts

import ".."
import "widgets"

RowLayout {
    Layout.preferredWidth: parent.width / 3
    spacing: 6

    // workspaces
    HyprWorkspaces {
        names: [Config.ws01, Config.ws02, Config.ws03, Config.ws04, Config.ws05, Config.ws06, Config.ws07, Config.ws08, Config.ws09, Config.ws10]
    }

    Item {
        Layout.fillWidth: true
    }
}
