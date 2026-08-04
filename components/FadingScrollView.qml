import QtQuick
import QtQuick.Controls

import qs.core

Item {
    id: root

    default property alias content: scroll.contentData
    property alias scrollView: scroll
    property color fadeColor: "black"
    property int fadeHeight: 24

    ScrollView {
        id: scroll

        anchors.fill: parent
        clip: true
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: root.fadeHeight

        gradient: Gradient {
            orientation: Gradient.Vertical

            GradientStop {
                position: 0.0
                color: "transparent"
            }

            GradientStop {
                position: 1.0
                color: root.fadeColor
            }
        }
    }
}
