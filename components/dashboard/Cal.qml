import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs

Item {
    id: root

    property date currentDate: new Date()
    property date selectedDate: new Date()
    property int month: currentDate.getMonth()
    property int year: currentDate.getFullYear()

    function updateDate() {
        root.currentDate = new Date();
    }

    Rectangle {
        width: 284
        height: 280
        color: "transparent"
        anchors.centerIn: parent
        radius: Config.general.cornerRadius
        border.color: Config.colors.passive
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            DayOfWeekRow {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                Layout.preferredWidth: 20
                Layout.alignment: Qt.AlignHCenter
                locale: States.locale

                delegate: Rectangle {
                    implicitWidth: 32
                    implicitHeight: Config.general.fontSize + 2
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: model.shortName
                        font.family: Config.general.fontFamily
                        font.pixelSize: Config.general.fontSize
                        font.bold: true
                        color: Config.colors.fg
                    }
                }
            }

            Rectangle {
                height: 1
                Layout.fillWidth: true
                Layout.topMargin: 4
                color: Config.colors.passive
            }

            MonthGrid {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter
                month: root.month
                year: root.year
                locale: States.locale

                delegate: Rectangle {
                    required property var model
                    property bool isCurrentMonth: model.month === root.month
                    property bool isToday: model.date.toDateString()
                                           === root.currentDate.toDateString()
                    property bool isSelected: model.date.toDateString()
                                              === root.selectedDate.toDateString(
                                                  )

                    implicitWidth: 32
                    implicitHeight: 32
                    color: isSelected ? Config.colors.accent : isToday
                                        ? Config.colors.fg : "transparent"
                    radius: height / 2

                    Behavior on color {
                        ColAnim {}
                    }

                    Text {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: model.day
                        font.family: Config.general.fontFamily
                        font.pixelSize: Config.general.fontSize
                        color: parent.isSelected ? Config.colors.fg :
                                                   parent.isToday
                                                   ? Config.colors.extraDark :
                                                     parent.isCurrentMonth
                                                     ? Config.colors.fg :
                                                       Qt.darker(
                                                           Config.colors.fg,
                                                           1.7)
                        font.bold: parent.isToday || parent.isSelected
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: root.selectedDate = model.date
                    }
                }
            }
        }
    }
}
