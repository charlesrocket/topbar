import QtQuick
import QtQuick.Layouts

import qs.core
import qs.widgets

RowLayout {
    id: rowLayout

    Layout.alignment: Qt.AlignCenter

    // active window title
    Loader {
        id: title

        active: Config.widgets.title
        visible: title.active
        asynchronous: true
        Layout.alignment: Qt.AlignVCenter
        Layout.fillWidth: false
        Layout.preferredWidth: 400
        Layout.preferredHeight: item ? item.implicitHeight : 0

        sourceComponent: WindowTitle {}
    }
}
