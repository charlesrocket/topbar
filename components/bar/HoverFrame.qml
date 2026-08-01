import QtQuick

import qs

Rectangle {
    id: root

    property int animDuration: Config.general.animDuration
    property int frameRadius: 6
    property color frameColor: "white"

    color: "transparent"
    border.width: 1
    radius: root.frameRadius
    opacity: 0
    z: -1
    border.color: frameColor

    Behavior on opacity {
        NumberAnimation {
            duration: root.animDuration
            easing.type: Easing.InOutQuad
        }
    }
}
