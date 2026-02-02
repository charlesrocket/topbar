import QtQuick
import QtQuick.Layouts

import ".."
import "widgets"

RowLayout {
    Layout.preferredWidth: parent.width / 3

    Item {
        Layout.fillWidth: true
    }

    // active window title
    WindowTitle {
        emptyTitle: "" // idle
        colBg: Config.colBg
        colFg: Config.colFg
        colMuted: Config.colMuted
        fontFamily: Config.fontFamily
        fontSize: Config.fontSize
        animDuration: Config.animDuration
    }

    Item {
        Layout.fillWidth: true
    }
}
