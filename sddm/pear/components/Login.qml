import QtQuick 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0

import "."

ColumnLayout {
    id: root

    property int userIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    property int sessionIndex: 0

    signal loginRequest(string username, string password, int sessionIndex)

    spacing: 10

    FontConfig {
        id: fonts
    }

    ListView {
        id: userList
        model: userModel
        currentIndex: userIndex
        visible: false
        width: 1
        height: 1
        interactive: false

        onCurrentIndexChanged: root.userIndex = currentIndex

        delegate: Item {
            required property int index
            required property string name
            required property string icon
            required property bool needsPassword
        }
    }

    Item {
        id: avatarFrame

        Layout.alignment: Qt.AlignHCenter
        width: 72
        height: 72

        readonly property string placeholderSource: Qt.resolvedUrl("../images/icons/account-circle.svg")
        readonly property string userPhotoSource: {
            const item = userList.currentItem
            if (item && isCustomUserPhoto(item.icon)) {
                return item.icon
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
                opacity: avatarFrame.userPhotoSource.length > 0 && !photoFailed ? 1 : 0.86
                smooth: avatarFrame.userPhotoSource.length > 0 && !photoFailed
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

        Connections {
            target: userList
            function onCurrentIndexChanged() {
                avatarImage.photoFailed = false
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: userModel.count > 1
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                userList.currentIndex = (userList.currentIndex + 1) % userModel.count
            }
        }
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: -2
        color: "#ffffff"
        opacity: 0.92
        text: currentUserName()
        font.pixelSize: 14
        font.weight: Font.DemiBold
        horizontalAlignment: Text.AlignHCenter
        renderType: Text.NativeRendering

        Binding on font.family {
            value: fonts.choose(config.usernameFont, config.globalFont)
            when: fonts.hasChoice(config.usernameFont, config.globalFont)
        }

        Binding on font.weight {
            value: fonts.weight(config.usernameFontWeight, config.globalFontWeight)
            when: fonts.hasWeight(config.usernameFontWeight, config.globalFontWeight)
        }

        Binding on font.italic {
            value: fonts.italic(config.usernameFontStyle, config.globalFontStyle)
            when: fonts.hasStyle(config.usernameFontStyle, config.globalFontStyle)
        }
    }

    PasswordInput {
        id: passwordField
        Layout.alignment: Qt.AlignHCenter
        capsLockOn: keyboard.capsLock

        onAccepted: attemptLogin()
        onSubmitClicked: attemptLogin()
    }

    Text {
        id: messageLabel
        Layout.alignment: Qt.AlignHCenter
        visible: text.length > 0
        color: Qt.rgba(1, 0.45, 0.45, 0.95)
        font.pixelSize: 13
        text: ""

        Binding on font.family {
            value: fonts.choose(config.loginErrorFont, config.globalFont)
            when: fonts.hasChoice(config.loginErrorFont, config.globalFont)
        }

        Binding on font.weight {
            value: fonts.weight(config.loginErrorFontWeight, config.globalFontWeight)
            when: fonts.hasWeight(config.loginErrorFontWeight, config.globalFontWeight)
        }

        Binding on font.italic {
            value: fonts.italic(config.loginErrorFontStyle, config.globalFontStyle)
            when: fonts.hasStyle(config.loginErrorFontStyle, config.globalFontStyle)
        }
    }

    function currentUserName() {
        const item = userList.currentItem
        if (item && item.name) {
            return item.name
        }
        return userModel.lastUser
    }

    // SDDM always supplies an icon (theme or /usr/share/sddm/faces/.face.icon).
    // Only KDE/user-specific paths count as a real profile picture.
    function isCustomUserPhoto(iconPath) {
        if (!iconPath || iconPath.length === 0) {
            return false
        }
        let path = iconPath
        if (path.startsWith("file://")) {
            path = path.slice(7)
        }
        if (path.indexOf("/var/lib/AccountsService/icons/") !== -1) {
            return true
        }
        if (path.endsWith("/.face.icon") && path.indexOf("/usr/share/sddm/faces") === -1
                && path.indexOf("/themes/") === -1) {
            return true
        }
        if (path.endsWith("/.face") && path.indexOf("/home/") !== -1) {
            return true
        }
        return false
    }

    function attemptLogin() {
        const username = currentUserName()
        if (!username) {
            return
        }
        loginRequest(username, passwordField.text, sessionIndex)
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
        userList.currentIndex = userIndex
        passwordField.forceActiveFocus()
    }
}
