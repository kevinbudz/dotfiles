import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    property var sessionManagement: null

    implicitHeight: 36
    height: 36

    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        Button {
            text: "Sleep"
            flat: true
            visible: sessionManagement && sessionManagement.canSuspend
            contentItem: Text {
                text: parent.text
                color: "#ffffff"
                opacity: parent.hovered ? 1.0 : 0.75
                font.pixelSize: 13
            }
            background: Rectangle {
                color: "transparent"
            }
            onClicked: sessionManagement.suspend()
        }

        Button {
            text: "Switch User"
            flat: true
            visible: sessionManagement && sessionManagement.canSwitchUser
            contentItem: Text {
                text: parent.text
                color: "#ffffff"
                opacity: parent.hovered ? 1.0 : 0.75
                font.pixelSize: 13
            }
            background: Rectangle {
                color: "transparent"
            }
            onClicked: sessionManagement.switchUser()
        }

        Button {
            text: "Restart"
            flat: true
            visible: sessionManagement && sessionManagement.canReboot
            contentItem: Text {
                text: parent.text
                color: "#ffffff"
                opacity: parent.hovered ? 1.0 : 0.75
                font.pixelSize: 13
            }
            background: Rectangle {
                color: "transparent"
            }
            onClicked: sessionManagement.reboot()
        }

        Button {
            text: "Shut Down"
            flat: true
            visible: sessionManagement && sessionManagement.canPowerOff
            contentItem: Text {
                text: parent.text
                color: "#ffffff"
                opacity: parent.hovered ? 1.0 : 0.75
                font.pixelSize: 13
            }
            background: Rectangle {
                color: "transparent"
            }
            onClicked: sessionManagement.powerOff()
        }
    }
}
