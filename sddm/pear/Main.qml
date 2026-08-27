import QtQuick 2.15
import SddmComponents 2.0

import "components"

Item {
    id: root

    width: 1920
    height: 1080

    property string screenName: ""

    readonly property bool showLoginUi: {
        var target = (config.loginScreenOutput || "").trim()
        if (target.length > 0)
            return screenName === target || screenName.indexOf(target) >= 0
        return primaryScreen
    }

    LayoutMirroring.enabled: Qt.locale().textDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    Repeater {
        model: screenModel

        Item {
            x: geometry.x
            y: geometry.y
            width: geometry.width
            height: geometry.height

            Component.onCompleted: root.screenName = name

            Background {
                anchors.fill: parent
            }
        }
    }

    Clock {
        id: clock
        visible: root.showLoginUi
        referenceSize: Math.min(root.width, root.height)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Math.min(root.width, root.height) * (parseFloat(config.clockTopMargin) || 0.12)
    }

    TopBar {
        id: topBar
        visible: root.showLoginUi
        z: 2
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
    }

    MouseArea {
        anchors.fill: parent
        z: topBar.sessionMenuOpen ? 1 : -1
        enabled: root.showLoginUi && topBar.sessionMenuOpen
        visible: root.showLoginUi && topBar.sessionMenuOpen
        propagateComposedEvents: true
        onClicked: (mouse) => {
            topBar.sessionMenuOpen = false
            mouse.accepted = true
        }
    }

    Login {
        id: login
        visible: root.showLoginUi
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * (parseFloat(config.loginBottomMargin) || 0.14)
        sessionIndex: topBar.sessionIndex
        z: 1

        onLoginRequest: (username, password, sessionIdx) => {
            sddm.login(username, password, sessionIdx)
        }
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            login.onLoginFailed()
        }

        function onLoginSucceeded() {
            login.onLoginSucceeded()
        }
    }
}
