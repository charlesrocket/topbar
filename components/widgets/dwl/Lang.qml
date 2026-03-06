import QtQuick
import Quickshell
import Quickshell.DWL
import "../../.."

Rectangle {
    id: root

    property string fontFamily: "SpaceMono Nerd Font"
    property color colMain: Config.colors.fg
    property color colBorder: Qt.darker(Config.colors.accent, 1.5)
    property color colBackground: "transparent"

    property DwlIpcOutput dwlOutput: DwlIpc.outputs.length > 0 ? DwlIpc.outputs[0] : null
    property string currentLayout: dwlOutput ? dwlOutput.kbLayout : ""

    width: layoutText.width + 8
    height: layoutText.height
    color: colBackground
    border.color: colBorder
    radius: 4

    Text {
        id: layoutText
        anchors.centerIn: parent

        text: {
            if (!root.currentLayout)
                return "XX";

            if (root.currentLayout.includes('(') && root.currentLayout.includes(')')) {
                const match = root.currentLayout.match(/\(([^)]+)\)/);
                return match ? match[1].toUpperCase() : root.currentLayout.substring(0, 2).toUpperCase();
            }

            const firstWord = root.currentLayout.split(' ')[0];
            return firstWord.length <= 3 ? firstWord.toUpperCase() : firstWord.substring(0, 2).toUpperCase();
        }

        font.pixelSize: 12
        font.bold: true
        font.family: root.fontFamily
        color: root.colMain
    }
}
