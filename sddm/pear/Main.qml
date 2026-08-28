import QtQuick 2.15
import SddmComponents 2.0

import "components"

Item {
    id: root

    width: 1920
    height: 1080

    LayoutMirroring.enabled: Qt.locale().textDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    // Fallback background when screenModel is not available
    Background {
        anchors.fill: parent
        visible: typeof screenModel === "undefined" || !screenModel || screenModel.count === 0
    }

    // Multi-screen repeater: creates background on all screens, but UI ONLY on landscape screens
    Repeater {
        model: screenModel

        Item {
            x: geometry.x
            y: geometry.y
            width: geometry.width
            height: geometry.height

            Background {
                anchors.fill: parent
            }

            Loader {
                anchors.fill: parent
                // ONLY activate the login UI if the monitor is landscape (width >= height)
                active: geometry.width >= geometry.height
                sourceComponent: loginUiComponent
            }
        }
    }

    // Fallback UI loader for single-screen test mode or when screenModel is empty
    Loader {
        anchors.fill: parent
        active: typeof screenModel === "undefined" || !screenModel || screenModel.count === 0
        sourceComponent: loginUiComponent
    }

    // The complete Login UI Component (TopBar, macOS Clock, Login Form)
    Component {
        id: loginUiComponent

        Item {
            anchors.fill: parent

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
        }
    }
}
