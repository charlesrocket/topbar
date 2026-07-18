import QtQuick
import QtQuick.Layouts
import Quickshell.Io

import Quickshell.Services.Mpris

import "../.."

Item {
    id: root
    anchors.fill: parent

    property real displayPosition: 0
    property bool playing: root.player?.playbackState == MprisPlaybackState.Playing
    property int playerIndex: 0
    property var player: {
        var playerList = Mpris.players.values;

        if (playerList.length === 0)
            return null;
        if (playerIndex >= playerList.length)
            playerIndex = 0;

        return playerList[playerIndex] ?? null;
    }

    readonly property string album: player?.trackAlbum || "No album"
    readonly property string artist: player?.trackArtist || "Unknown artist"
    readonly property string title: player?.trackTitle || "No track"
    readonly property string artUrl: player?.trackArtUrl || ""

    Connections {
        target: root.player

        function onPositionChanged() {
            var p = root.player.position;
            if (p > 0 || root.player.playbackState === MprisPlaybackState.Stopped) {
                root.displayPosition = p;
            }
        }

        function onPostTrackChanged() {
            if (Config.dashboard.player.notifications)
                root.showTrackInfo();
        }
    }

    Process {
        id: notify
        Component.onCompleted: notify.running = false
    }

    function showTrackInfo() {
        notify.command = ["notify-send", "-u", "low", "-a", "Player", "-i", root.artUrl, root.artist,  root.title];
        notify.running = true;
    }

    onPlayerChanged: {
        if (player)
            root.displayPosition = player.position;
    }

    Timer {
        running: root.playing
        interval: 1000
        repeat: true
        onTriggered: root.player?.positionChanged()
    }

    // placeholder
    Item {
        anchors.fill: parent
        opacity: root.player === null ? 1.0 : 0.0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: Config.general.animDuration
                easing.type: Easing.OutSine
            }
        }

        Text {
            anchors.centerIn: parent
            text: "󰥠"
            color: Config.colors.fg
            font.pixelSize: Config.general.fontSize * 6
            font.family: "Symbols Nerd Font"
        }
    }

    Column {
        anchors.fill: parent
        spacing: 12
        opacity: root.player !== null ? 1.0 : 0.0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: Config.general.animDuration
                easing.type: Easing.OutSine
            }
        }

        // player switcher
        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Rectangle {
                width: 25
                height: 25
                color: "transparent"

                Text {
                    anchors.centerIn: parent
                    text: ""
                    font.pixelSize: Config.general.fontSize * 1.4
                    font.family: "Symbols Nerd Font"
                    horizontalAlignment: Text.AlignHCenter
                    color: Config.colors.fg
                    opacity: Mpris.players.values.length > 1 ? 1.0 : 0.3
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: Mpris.players.values.length > 1
                    onClicked: root.previousPlayer()
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }

            Text {
                visible: root.player !== null
                Layout.maximumWidth: 168
                text: root.player?.identity || ""
                elide: Text.ElideRight
                font.pixelSize: 13
                font.family: Config.general.fontFamily
                color: Config.colors.fg
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                visible: root.player === null
                text: "󰥠"
                elide: Text.ElideRight
                font.pixelSize: Config.general.fontSize * 1.4
                font.bold: true
                font.family: "Symbols Nerd Font"
                color: Config.colors.passive
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                width: 25
                height: 25
                color: "transparent"
                Layout.alignment: Qt.AlignVCenter

                Text {
                    anchors.centerIn: parent
                    text: ""
                    font.pixelSize: Config.general.fontSize * 1.4
                    font.family: "Symbols Nerd Font"
                    horizontalAlignment: Text.AlignHCenter
                    color: Config.colors.fg
                    opacity: Mpris.players.values.length > 1 ? 1.0 : 0.3
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: Mpris.players.values.length > 1
                    onClicked: root.nextPlayer()
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }
        }

        // album cover, shuffle and repeat buttons
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            // shuffle button
            Loader {
                id: shuffle
                active: Config.dashboard.player.queueButtons
                visible: shuffle.active
                anchors.verticalCenter: parent.verticalCenter

                sourceComponent: Rectangle {
                    width: 30
                    height: 30
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "󰒟"
                        font.pixelSize: Config.general.fontSize / 0.6
                        font.family: "Symbols Nerd Font"
                        horizontalAlignment: Text.AlignHCenter
                        color: player?.shuffle ? Config.colors.fg : Config.colors.fg
                        opacity: player?.shuffle ? 1.0 : 0.4
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: player?.canControl || false
                        onClicked: player.shuffle = !player.shuffle
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }
                }
            }

            // album cover
            Loader {
                id: coverWrapper
                active: opacity > 0
                visible: coverWrapper.active
                anchors.verticalCenter: parent.verticalCenter

                sourceComponent: Image {
                    id: cover
                    width: 120
                    height: 120
                    retainWhileLoading: false
                    source: root.artUrl
                    fillMode: Image.PreserveAspectCrop
                    mipmap: true
                    smooth: false

                    Rectangle {
                        anchors.fill: parent
                        color: Config.colors.extraDark
                        visible: cover.status !== Image.Ready

                        Text {
                            anchors.centerIn: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: ""
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 80
                            color: Config.colors.fg
                        }
                    }
                }
            }

            // repeat button
            Loader {
                id: repeat
                active: Config.dashboard.player.queueButtons
                visible: repeat.active
                anchors.verticalCenter: parent.verticalCenter

                sourceComponent: Rectangle {
                    width: 30
                    height: 30
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent

                        text: {
                            if (player?.loopState == MprisLoopState.Track) {
                                return "󰑘";
                            } else if (player?.loopState == MprisLoopState.Playlist) {
                                return "󰑖";
                            } else {
                                return "󰑗";
                            }
                        }

                        font.pixelSize: Config.general.fontSize / 0.6
                        font.family: "Symbols Nerd Font"
                        horizontalAlignment: Text.AlignHCenter
                        color: Config.colors.fg
                        opacity: player?.canControl ? 1.0 : 0.4
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: player?.canControl || false
                        onClicked: {
                            if (player?.loopState == MprisLoopState.None) {
                                player.loopState = MprisLoopState.Playlist;
                            } else if (player?.loopState == MprisLoopState.Playlist) {
                                player.loopState = MprisLoopState.Track;
                            } else {
                                player.loopState = MprisLoopState.None;
                            }
                        }

                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }
                }
            }
        }

        // track info
        Column {
            width: parent.width
            spacing: 5

            Text {
                text: root.title
                font.bold: true
                font.family: Config.general.fontFamily
                font.pixelSize: 15
                color: Config.colors.fg
                elide: Text.ElideRight
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: root.artist
                font.pixelSize: 14
                font.family: Config.general.fontFamily
                color: Config.colors.fg
                elide: Text.ElideRight
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: root.album
                font.pixelSize: 13
                font.family: Config.general.fontFamily
                color: Config.colors.fg
                elide: Text.ElideRight
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // position tracker
        Column {
            anchors.left: parent.left
            anchors.right: parent.right

            onVisibleChanged: {
                if (root.player)
                    displayPosition = root.player.position;
            }

            Rectangle {
                width: parent.width / 1.1
                height: 6
                border.width: 1
                border.color: (root.player !== null && root.player.positionSupported) ? Config.colors.fg : "transparent"
                color: Config.colors.extraDark
                radius: 3
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: root.player?.lengthSupported ? (root.displayPosition / root.player.length) * parent.width : 0
                    height: parent.height
                    color: Config.colors.fg
                    radius: 3
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: (root.player?.canSeek && root.player?.lengthSupported) || false

                    onClicked: function (mouse) {
                        if (root.player?.lengthSupported) {
                            var newPos = (mouse.x / width) * root.player.length;
                            root.player.position = newPos;
                        }
                    }
                }
            }
        }

        // control buttons
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 15

            Rectangle {
                width: 35
                height: 35
                color: Config.colors.fg
                radius: 17.5

                Text {
                    anchors.centerIn: parent
                    text: ""
                    font.pixelSize: 18
                    font.family: "Symbols Nerd Font"
                    horizontalAlignment: Text.AlignHCenter
                    color: Config.colors.extraDark
                    opacity: player?.canGoPrevious ? 1.0 : 0.5
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: player?.canGoPrevious || false
                    onClicked: player?.previous()
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }

            Rectangle {
                width: 35
                height: 35
                color: Config.colors.fg
                radius: 17.5

                Text {
                    anchors.centerIn: parent
                    text: player?.isPlaying ? "" : ""
                    font.pixelSize: 18
                    font.family: "Symbols Nerd Font"
                    horizontalAlignment: Text.AlignHCenter
                    color: Config.colors.extraDark
                    opacity: player?.canTogglePlaying ? 1.0 : 0.5
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: player?.canTogglePlaying || false
                    onClicked: player?.togglePlaying()
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }

            Rectangle {
                width: 35
                height: 35
                color: Config.colors.fg
                radius: 17.5

                Text {
                    anchors.centerIn: parent
                    text: ""
                    font.pixelSize: 18
                    font.family: "Symbols Nerd Font"
                    horizontalAlignment: Text.AlignHCenter
                    color: Config.colors.extraDark
                    opacity: player?.canGoNext ? 1.0 : 0.5
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: player?.canGoNext || false
                    onClicked: player?.next()
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }
        }
    }

    function nextPlayer() {
        var playerList = Mpris.players.values;
        if (playerList.length > 0) {
            playerIndex = (playerIndex + 1) % playerList.length;
        }
    }

    function previousPlayer() {
        var playerList = Mpris.players.values;
        if (playerList.length > 0) {
            playerIndex = (playerIndex - 1 + playerList.length) % playerList.length;
        }
    }
}
