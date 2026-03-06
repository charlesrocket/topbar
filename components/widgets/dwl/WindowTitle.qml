import Quickshell.DWL

import QtQuick

import "../../.."

Item {
    property DwlIpcOutput dwlOutput: DwlIpc.outputs.length > 0 ? DwlIpc.outputs[0] : null

    property string fullTitle: dwlOutput?.title || Config.bar.title.empty
}
