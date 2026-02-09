import QtQuick
import QtQuick.Layouts

import ".."
import "widgets"

RowLayout {
    Item {
        Layout.fillWidth: true
        Layout.minimumWidth: 0
    }

    // active window title
    Loader {
        id: title
        active: Config.widgets.title
        visible: title.active
        asynchronous: true
        Layout.fillWidth: false
        Layout.preferredWidth: 400
        Layout.preferredHeight: item ? item.implicitHeight : 0
        sourceComponent: HyprWindowTitle {}
    }

    Item {
        Layout.fillWidth: true
        Layout.minimumWidth: 0
    }
}
