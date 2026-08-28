import QtQuick 2.15
import SddmComponents 2.0

import "components"

Item {
    id: root

    width: 1920
    height: 1080

    // Determine if the login UI should be displayed on this screen
    readonly property bool showLoginUi: {
        // 1. Never show login UI on a vertical/portrait display
        if (root.width < root.height) {
            return false
        }

        // 2. If SDDM marks this view as the primary screen, show it
        if (typeof primaryScreen !== "undefined" && primaryScreen === true) {
            return true
        }

        // 3. If there is only one screen or running in test mode
        if (typeof primaryScreen === "undefined" || typeof screenModel === "undefined" || !screenModel || screenModel.count <= 1) {
            return true
        }

        // 4. In a multi-screen setup, if this is the only landscape monitor, show it
        if (typeof screenModel !== "undefined" && screenModel && screenModel.count > 1) {
            var landscapeScreens = 0
            for (var i = 0; i < screenModel.count; ++i) {
                var scr = screenModel.get(i)
                if (scr && scr.geometry.width >= scr.geometry.height) {
                    landscapeScreens++
                }
            }
            if (landscapeScreens <= 1) {
                return true
            }
        }

        return false
    }

    LayoutMirroring.enabled: Qt.locale().textDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    // Background wallpaper is always rendered on every monitor
    Background {
        id: bg
        anchors.fill: parent
        z: 0
    }

    // Login UI Container (Clock, TopBar, Login form)
    Item {
        id: uiContainer
        anchors.fill: parent
        visible: root.showLoginUi
        z: 1

        TopBar {
            id: topBar
            z: 2
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
        }

        Clock {
            id: clock
            referenceSize: Math.min(parent.width, parent.height)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Math.min(parent.width, parent.height) * (parseFloat(config.clockTopMargin) || 0.12)
        }

        MouseArea {
            anchors.fill: parent
            z: topBar.sessionMenuOpen ? 1 : -1
            enabled: topBar.sessionMenuOpen
            visible: topBar.sessionMenuOpen
            propagateComposedEvents: true
            onClicked: (mouse) => {
                topBar.sessionMenuOpen = false
                mouse.accepted = true
            }
        }

        Login {
            id: login
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.height * (parseFloat(config.loginBottomMargin) || 0.14)
            sessionIndex: topBar.sessionIndex
            z: 1

            onLoginRequest: (username, password, sessionIdx) => {
                sddm.login(username, password, sessionIdx)
            }
        }
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            if (root.showLoginUi) {
                login.onLoginFailed()
            }
        }

        function onLoginSucceeded() {
            if (root.showLoginUi) {
                login.onLoginSucceeded()
            }
        }
    }
}
