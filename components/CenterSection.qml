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
    Loader {
        id: title
        active: Config.widgets.title
        visible: title.active
        asynchronous: true
        Layout.fillWidth: true
        Layout.minimumWidth: 400
        Layout.preferredHeight: item ? item.implicitHeight : 0
        sourceComponent: HyprWindowTitle {}
    }

    Item {
        Layout.fillWidth: true
    }
}
