import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property bool capsLockOn: false
    property string notificationText: ""

    signal unlockRequest(string password)

    spacing: 10

    FontConfig {
        id: fonts
    }

    Item {
        id: avatarFrame

        Layout.alignment: Qt.AlignHCenter
        width: 80
        height: 80

        readonly property string placeholderSource: Qt.resolvedUrl("../images/icons/account-circle.svg")
        readonly property string userPhotoSource: {
            if (typeof kscreenlocker_userImage !== "undefined" && kscreenlocker_userImage && kscreenlocker_userImage.length > 0) {
                return "file://" + kscreenlocker_userImage
            }
            return ""
        }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            clip: true
            color: "transparent"

            Image {
                id: avatarImage
                anchors.fill: parent
                source: avatarFrame.userPhotoSource.length > 0 && !photoFailed
                        ? avatarFrame.userPhotoSource
                        : avatarFrame.placeholderSource
                fillMode: avatarFrame.userPhotoSource.length > 0 && !photoFailed
                        ? Image.PreserveAspectCrop
                        : Image.PreserveAspectFit
                opacity: avatarFrame.userPhotoSource.length > 0 && !photoFailed ? 1 : 0.88
                smooth: true
                antialiasing: true
                cache: false

                property bool photoFailed: false

                onSourceChanged: photoFailed = false
                onStatusChanged: {
                    if (status === Image.Error) {
                        photoFailed = true
                    }
                }
            }
        }
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: -2
        color: "#ffffff"
        opacity: 0.95
        text: typeof kscreenlocker_userName !== "undefined" && kscreenlocker_userName ? kscreenlocker_userName : "User"
        font.pixelSize: 15
        font.weight: Font.DemiBold
        font.family: fonts.configFont
        horizontalAlignment: Text.AlignHCenter
        renderType: Text.NativeRendering
    }

    PasswordInput {
        id: passwordField
        Layout.alignment: Qt.AlignHCenter
        capsLockOn: root.capsLockOn

        onAccepted: attemptUnlock()
        onSubmitClicked: attemptUnlock()
    }

    Text {
        id: messageLabel
        Layout.alignment: Qt.AlignHCenter
        visible: text.length > 0
        color: Qt.rgba(1, 0.45, 0.45, 0.95)
        font.pixelSize: 13
        font.family: fonts.configFont
        text: root.notificationText
    }

    function attemptUnlock() {
        if (passwordField.text.length === 0) return
        root.unlockRequest(passwordField.text)
    }

    function onLoginFailed() {
        messageLabel.text = "Incorrect password"
        passwordField.selectAll()
        passwordField.forceActiveFocus()
        shakeAnimation.start()
    }

    function onLoginSucceeded() {
        messageLabel.text = ""
    }

    SequentialAnimation {
        id: shakeAnimation

        NumberAnimation {
            target: passwordField
            property: "x"
            from: 0
            to: -8
            duration: 50
        }
        NumberAnimation {
            target: passwordField
            property: "x"
            from: -8
            to: 8
            duration: 50
        }
        NumberAnimation {
            target: passwordField
            property: "x"
            from: 8
            to: -6
            duration: 50
        }
        NumberAnimation {
            target: passwordField
            property: "x"
            from: -6
            to: 0
            duration: 50
        }
    }

    Component.onCompleted: {
        passwordField.forceActiveFocus()
    }
}
