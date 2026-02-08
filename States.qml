pragma Singleton

import QtQuick
import Quickshell

Singleton {
    property bool ecoMode: false
    property bool dropdownRevealed: false
    property bool logoutPresent: false
    property bool keepAwake: false
    property string defaultWallpaper: "https://raw.githubusercontent.com/charlesrocket/misc-files/trunk/puffy-red.png"
}
