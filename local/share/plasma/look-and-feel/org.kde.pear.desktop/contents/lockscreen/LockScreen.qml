import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.private.sessions
import org.kde.plasma.private.keyboardindicator as KeyboardIndicator

import "components"

Item {
    id: root

    property bool debug: false
    property string notification: ""
    signal clearPassword()
    signal notificationRepeated()

    // Required properties for kscreenlocker
    property bool viewVisible: false

    LayoutMirroring.enabled: Qt.locale().textDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    implicitWidth: 1920
    implicitHeight: 1080

    // Background
    Background {
        anchors.fill: parent
    }

    SessionManagement {
        id: sessionManagement
    }

    KeyboardIndicator.KeyState {
        id: capsLockState
        key: Qt.Key_CapsLock
    }

    Connections {
        target: authenticator

        function onFailed(kind) {
            login.onLoginFailed()
        }

        function onSucceeded() {
            login.onLoginSucceeded()
            Qt.quit()
        }

        function onInfoMessageChanged() {
            if (authenticator.infoMessage) {
                root.notification = authenticator.infoMessage
            }
        }

        function onErrorMessageChanged() {
            if (authenticator.errorMessage) {
                root.notification = authenticator.errorMessage
            }
        }
    }

    // Top status / session control bar
    TopBar {
        id: topBar
        z: 2
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        sessionManagement: sessionManagement
    }

    // Center-top Clock
    Clock {
        id: clock
        referenceSize: Math.min(root.width, root.height)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Math.min(root.width, root.height) * 0.12
    }

    // Center-bottom Login card
    Login {
        id: login
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.14
        capsLockOn: capsLockState.locked
        notificationText: root.notification
        z: 1

        onUnlockRequest: (password) => {
            authenticator.respond(password)
        }
    }

    Component.onCompleted: {
        authenticator.startAuthenticating()
    }
}
