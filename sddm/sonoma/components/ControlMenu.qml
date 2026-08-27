import QtQuick 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0

import "."

Rectangle {
    id: root

    property string uiFont: config.fontFamilyUI || "SF Pro Text"
    property alias sessionIndex: sessionBox.index
    property bool open: false

    signal closed()

    width: 188
    height: menuColumn.implicitHeight + 14
    radius: 11
    visible: open
    color: Qt.rgba(0.12, 0.12, 0.12, 0.88)
    border.color: Qt.rgba(1, 1, 1, 0.2)
    border.width: 1

    function closeMenu() {
        closed()
    }

    ColumnLayout {
        id: menuColumn
        anchors.fill: parent
        anchors.margins: 7
        spacing: 2

        RowLayout {
            spacing: 5
            Layout.leftMargin: 4

            ThemeIcon {
                name: "keyboard-layout"
                iconSize: 11
                opacity: 0.55
            }

            Text {
                text: "Session"
                color: Qt.rgba(1, 1, 1, 0.55)
                font.family: uiFont
                font.pixelSize: 10
            }
        }

        ComboBox {
            id: sessionBox
            Layout.fillWidth: true
            height: 28
            model: sessionModel
            index: sessionModel.lastIndex

            color: Qt.rgba(1, 1, 1, 0.1)
            borderColor: Qt.rgba(1, 1, 1, 0.2)
            focusColor: Qt.rgba(1, 1, 1, 0.25)
            hoverColor: Qt.rgba(1, 1, 1, 0.18)
            textColor: "#ffffff"
            menuColor: Qt.rgba(0.15, 0.15, 0.15, 0.95)
            font.family: uiFont
            font.pixelSize: 11
            arrowIcon: ""
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(1, 1, 1, 0.12)
            Layout.topMargin: 2
            Layout.bottomMargin: 2
        }

        ControlMenuAction {
            label: "Sleep"
            enabled: sddm.canSuspend
            onTriggered: {
                sddm.suspend()
                root.closeMenu()
            }
        }
        ControlMenuAction {
            label: "Restart"
            enabled: sddm.canReboot
            onTriggered: {
                sddm.reboot()
                root.closeMenu()
            }
        }
        ControlMenuAction {
            label: "Shut Down"
            enabled: sddm.canPowerOff
            onTriggered: {
                sddm.powerOff()
                root.closeMenu()
            }
        }
    }
}
