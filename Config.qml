pragma Singleton

import QtQuick
import Quickshell

import qs

Singleton {
    readonly property color colBg: Settings.colors.bg ?? "#aa000000" // background
    readonly property color colBgE: Settings.colors.bgE ?? "#000000" // eco mode background
    readonly property color colFg: Settings.colors.fg ?? "#b0b4bc" // main color
    readonly property color colMuted: Settings.colors.muted ?? "#aa4e4e4e" // passive color
    readonly property color colDark: Settings.colors.dark ?? Qt.darker(colMuted, 1.5) // dark stuff
    readonly property color colCyan: Settings.colors.cyan ?? "#0db9d7" // action color
    readonly property color colRed: Settings.colors.red ?? "#cc0000" // evil color
    readonly property color colBlue: Settings.colors.blue ?? "#7aa2f7" // some stuff
    readonly property color colYellow: Settings.colors.yellow ?? "#ffd700" // danger zone
    readonly property color colGreen: Settings.colors.green ?? "#9ece6a" // zoot zone
    readonly property color colPurple: Settings.colors.purple ?? "#bf00ff" // more stuff

    readonly property string ws01: Settings.workspaces.one ?? "" // 01
    readonly property string ws02: Settings.workspaces.two ?? "" // 02
    readonly property string ws03: Settings.workspaces.three ?? "" // 03
    readonly property string ws04: Settings.workspaces.four ?? "" // 04
    readonly property string ws05: Settings.workspaces.five ?? "" // 05
    readonly property string ws06: Settings.workspaces.six ?? "󰉕" // 06
    readonly property string ws07: Settings.workspaces.seven ?? "" // 07
    readonly property string ws08: Settings.workspaces.eight ?? "" // 08
    readonly property string ws09: Settings.workspaces.tine ?? "" // 09
    readonly property string ws10: Settings.workspaces.ten ?? "" // 10

    readonly property string fontFamily: Settings.font ?? "Hack Nerd Font" // main font
    readonly property int fontSize: Settings.fontSize ?? 14 // base size

    readonly property int cornerRadius: Settings.radius ?? 8 // base radius
    readonly property int animDuration: Settings.duration ?? 250 // base animations
    readonly property int barHeight: Settings.barHeight ?? 30
    readonly property int extraPadding: Settings.barExtraPadding ?? 8

    readonly property string wallpaper: Settings.wallpaper ?? States.defaultWallpaper

    // widgets
    readonly property bool systemTray: Settings.systemTray ?? false
    readonly property bool systemStats: Settings.systemStats ?? false
}
