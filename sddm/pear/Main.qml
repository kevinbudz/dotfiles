import QtQuick 2.15
import SddmComponents 2.0

import "components"

Item {
    id: root

    width: 1920
    height: 1080

    // Detect if this screen instance is landscape
    readonly property bool isLandscape: width >= height

    // Check if this screen is the primary screen or target
    readonly property bool isTargetScreen: {
        if (typeof primaryScreen !== "undefined") {
            return primaryScreen
        }
        return true
    }

    // Show UI only on the primary landscape monitor
    readonly property bool showLoginUi: isLandscape && isTargetScreen

    LayoutMirroring.enabled: Qt.locale().textDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    // Background for single root multi-screen setups
    Repeater {
        model: (typeof screenModel !== "undefined" && screenModel && screenModel.count > 1) ? screenModel : 0

        Item {
            x: geometry.x
            y: geometry.y
            width: geometry.width
            height: geometry.height

            Background {
                anchors.fill: parent
            }
        }
    }

    // Default full-screen background for per-screen window setups
    Background {
        anchors.fill: parent
        visible: (typeof screenModel === "undefined" || !screenModel || screenModel.count <= 1)
    }

    // Login UI Container - ONLY visible on the landscape display
    Item {
        id: uiContainer
        anchors.fill: parent
        visible: root.showLoginUi

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
