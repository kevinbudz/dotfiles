import QtQuick 2.15
import SddmComponents 2.0

import "components"

Item {
    id: root

    width: 1920
    height: 1080

    property bool controlMenuOpen: false

    LayoutMirroring.enabled: Qt.locale().textDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    Repeater {
        model: screenModel

        Item {
            x: geometry.x
            y: geometry.y
            width: geometry.width
            height: geometry.height

            WallpaperBackground {
                anchors.fill: parent
            }
        }
    }

    SonomaClock {
        id: clock
        referenceSize: Math.min(root.width, root.height)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Math.min(root.width, root.height) * (parseFloat(config.clockTopMargin) || 0.12)
    }

    SessionLabel {
        z: 2
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 8
        anchors.leftMargin: 20
        sessionIndex: controlMenu.sessionIndex
    }

    StatusBar {
        id: statusBar
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 8
        anchors.rightMargin: 8

        onControlCenterToggled: controlMenuOpen = !controlMenuOpen
    }

    ControlMenu {
        id: controlMenu
        anchors.top: statusBar.bottom
        anchors.topMargin: 4
        anchors.right: statusBar.right
        anchors.rightMargin: 0
        open: controlMenuOpen

        onClosed: controlMenuOpen = false
    }

    MouseArea {
        anchors.fill: parent
        z: controlMenuOpen ? 0 : -1
        visible: controlMenuOpen
        onClicked: controlMenuOpen = false
    }

    LoginPanel {
        id: loginPanel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * (parseFloat(config.loginBottomMargin) || 0.14)
        sessionIndex: controlMenu.sessionIndex
        z: 1

        onLoginRequest: (username, password, sessionIdx) => {
            sddm.login(username, password, sessionIdx)
        }
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            loginPanel.onLoginFailed()
        }

        function onLoginSucceeded() {
            loginPanel.onLoginSucceeded()
        }
    }
}
