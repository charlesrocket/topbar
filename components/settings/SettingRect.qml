import QtQuick

import qs
import qs.core

Rect {
    property bool first
    property bool last

    color: Qt.darker(Config.colors.extraDark, 1.1)
    topLeftRadius: first ? Config.general.cornerRadius : 0
    topRightRadius: first ? Config.general.cornerRadius : 0
    bottomLeftRadius: last ? Config.general.cornerRadius : 0
    bottomRightRadius: last ? Config.general.cornerRadius : 0
}
