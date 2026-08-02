import QtQml
import QtQuick

import qs.core

Item {
    id: root

    property color colMain: Config.colors.fg
    property color colBg: "transparent"
    property color colBorder: Config.colors.purple
    property int slideDuration: Config.general.animDuration
    property int fontSize: Config.general.fontSize
    property string fontFamily: "FiraCode Nerd Font"
    property string icon: "󱣶"
    property real temperature: 0
    property string ip: "n/a"

    function getWeatherIcon(code, isDay) {
        switch (code) {
        case 0:
            return isDay ? "󰖙" : "󰖔";
        case 1:
        case 2:
        case 3:
            return isDay ? "󰖕" : "󰼱";
        case 45:
        case 48:
            return "󰱋";
        case 51:
        case 53:
        case 55:
        case 56:
        case 57:
            return "";
        case 61:
        case 63:
        case 65:
        case 66:
        case 67:
            return "";
        case 71:
        case 73:
        case 75:
        case 77:
            return "󰜗";
        case 80:
        case 81:
        case 82:
            return "";
        case 85:
        case 86:
            return "";
        case 95:
            return "";
        case 96:
        case 99:
            return "󰖒";
        default:
            return "󱣶";
        }
    }

    function fetchWeather() {
        var geoReq = new XMLHttpRequest();
        geoReq.timeout = 5000;
        geoReq.open("GET", "http://ip-api.com/json/", true);
        geoReq.onreadystatechange = function () {
            if (geoReq.readyState === XMLHttpRequest.DONE) {
                if (geoReq.status === 200) {
                    try {
                        var geoData = JSON.parse(geoReq.responseText);
                        var lat = geoData.lat;
                        var lon = geoData.lon;

                        root.ip = geoData.query;

                        var weatherReq = new XMLHttpRequest();
                        weatherReq.timeout = 5000;

                        var weatherUrl
                                = "https://api.open-meteo.com/v1/forecast?"
                                + "latitude=" + lat + "&longitude=" + lon
                                + "&current_weather=true";

                        weatherReq.open("GET", weatherUrl, true);
                        weatherReq.onreadystatechange = function () {
                            if (weatherReq.readyState === XMLHttpRequest.DONE) {
                                if (weatherReq.status === 200) {
                                    try {
                                        var weatherData = JSON.parse(
                                                    weatherReq.responseText);
                                        var currentWeather
                                                = weatherData.current_weather;

                                        root.temperature
                                                = currentWeather.temperature;
                                        root.icon = getWeatherIcon(
                                                    currentWeather.weathercode,
                                                    currentWeather.is_day
                                                    === 1);
                                    } catch (error) {
                                        console.error(
                                                    "Failed to parse weather data:",
                                                    error);
                                    }
                                } else {
                                    console.error("Weather request failed:",
                                                  weatherReq.status);
                                }
                            }
                        };

                        weatherReq.send();
                    } catch (error) {
                        console.error("Failed to parse weather geo data:",
                                      error);
                    }
                } else {
                    console.error("Weather geo request failed:", geoReq.status);
                }
            }
        };

        geoReq.send();
    }

    implicitWidth: (hoverDetector.containsMouse ? infoContainer.width + 8 : 0)
                   + weatherText.width
    implicitHeight: weatherText.height

    Behavior on implicitWidth {
        NumberAnimation {
            duration: root.slideDuration
            easing.type: Easing.OutCubic
        }
    }

    Component.onCompleted: {
        fetchWeather();
    }

    Timer {
        id: updateTimer

        interval: 1200
        running: true
        repeat: true

        onTriggered: {
            root.fetchWeather();
            var randomValue = Math.floor(Math.random() * (680000 - 100000)
                                         + 100000);


            updateTimer.interval = 1000000 + randomValue;
        }
    }

    Rectangle {
        id: infoContainer

        anchors.right: weatherContainer.left
        anchors.rightMargin: hoverDetector.containsMouse ? 8 : 0
        anchors.verticalCenter: parent.verticalCenter
        width: infoText.contentWidth + 10
        height: infoText.contentHeight + 2
        color: root.colBg
        radius: 6
        border.width: 1
        border.color: root.colBorder
        opacity: hoverDetector.containsMouse ? 1 : 0
        scale: hoverDetector.containsMouse ? 1 : 0
        transformOrigin: Item.Right
        visible: opacity > 0

        Behavior on anchors.rightMargin {
            NumberAnimation {
                duration: root.slideDuration
                easing.type: Easing.OutCubic
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: root.slideDuration
                easing.type: Easing.OutCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: root.slideDuration
                easing.type: Easing.OutCubic
            }
        }

        Text {
            id: infoText

            anchors.centerIn: parent
            anchors.verticalCenter: parent.verticalCenter
            text: root.temperature + "󰔄"
            color: root.colMain

            font {
                family: root.fontFamily
                pixelSize: root.fontSize - 1
                bold: true
            }
        }
    }

    Item {
        id: weatherContainer

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: weatherText.width
        height: weatherText.height

        Text {
            id: weatherText

            text: root.icon
            color: root.colMain

            font {
                family: "Symbols Nerd Font"
                pixelSize: root.fontSize
                bold: true
            }
        }
    }

    MouseArea {
        id: hoverDetector

        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true

        onPressed: function (mouse) {
            mouse.accepted = false;
        }
    }
}
