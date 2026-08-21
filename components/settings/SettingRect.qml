import QtQuick

import qs
import qs.core

Rect {
    property bool first
    property bool last

    color: Qt.darker(Config.colors.extraDark, 1.1)
    topLeftRadius: first ? Config.appearance.cornerRadius : 2
    topRightRadius: first ? Config.appearance.cornerRadius : 2
    bottomLeftRadius: last ? Config.appearance.cornerRadius : 2
    bottomRightRadius: last ? Config.appearance.cornerRadius : 2
}
