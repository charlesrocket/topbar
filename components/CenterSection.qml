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
    WindowTitle {}

    Item {
        Layout.fillWidth: true
    }
}
