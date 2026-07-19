import QtQuick
import QtQuick.Effects

Item {
    id: root

    property bool shadow: true

    Loader {
        active: root.shadow
        visible: root.shadow
        anchors.fill: parent

        sourceComponent: RectangularShadow {
            offset.x: 0
            offset.y: 0
            radius: width / 2
            blur: 30
            spread: 10
            color: Qt.rgba(0, 0, 0, 0.3)
        }
    }

    Image {
        id: userFace
        source: Utils.expandPath("~/.face.icon")
        anchors.fill: parent
        visible: false

        onStatusChanged: {
            if (status === Image.Error) {
                source = Utils.expandPath("~/.face");
            }
        }
    }

    MultiEffect {
        id: maskedImage
        source: userFace
        anchors.fill: parent
        maskEnabled: true
        maskSource: mask
        // smooth image
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
    }

    Item {
        id: mask
        anchors.fill: parent
        layer.enabled: true
        //layer.smooth: true
        visible: false

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "black"
        }
    }
}
