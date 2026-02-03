pragma Singleton

import QtQuick
import Quickshell

import qs

Singleton {
    property color colBg: Settings.colors.bg ?? "#aa000000" // background
    property color colBgE: Settings.colors.bgE ?? "#000000" // eco mode background
    property color colFg: Settings.colors.fg ?? "#b0b4bc" // main color
    property color colMuted: Settings.colors.muted ?? "#aa4e4e4e" // passive color
    property color colDark: Settings.colors.dark ?? Qt.darker(colMuted, 1.5) // dark stuff
    property color colCyan: Settings.colors.cyan ?? "#0db9d7" // action color
    property color colRed: Settings.colors.red ?? "#cc0000" // evil color
    property color colBlue: Settings.colors.blue ?? "#7aa2f7" // some stuff
    property color colYellow: Settings.colors.yellow ?? "#ffd700" // danger zone
    property color colGreen: Settings.colors.green ?? "#9ece6a" // zoot zone
    property color colPurple: Settings.colors.purple ?? "#bf00ff" // more stuff

    property string ws01: Settings.workspaces.one ?? "" // 01
    property string ws02: Settings.workspaces.two ?? "" // 02
    property string ws03: Settings.workspaces.three ?? "" // 03
    property string ws04: Settings.workspaces.four ?? "" // 04
    property string ws05: Settings.workspaces.five ?? "" // 05
    property string ws06: Settings.workspaces.six ?? "󰉕" // 06
    property string ws07: Settings.workspaces.seven ?? "" // 07
    property string ws08: Settings.workspaces.eight ?? "" // 08
    property string ws09: Settings.workspaces.tine ?? "" // 09
    property string ws10: Settings.workspaces.ten ?? "" // 10

    property string fontFamily: Settings.font ?? "Hack Nerd Font" // main font
    property int fontSize: Settings.fontSize ?? 14 // base size

    property int cornerRadius: Settings.radius ?? 8 // base radius
    property int animDuration: Settings.duration ?? 250 // base animations
    property int barHeight: Settings.barHeight ?? 30
    property int extraPadding: Settings.barExtraPadding ?? 8

    property bool systemTray: Settings.systemTray ?? false
    property bool systemStats: Settings.systemStats ?? false
}
