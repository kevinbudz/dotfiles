import QtQuick 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0

import "."

ColumnLayout {
    id: root

    property int userIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    property int sessionIndex: 0
    property string uiFont: config.fontFamilyUI || "SF Pro Text"

    signal loginRequest(string username, string password, int sessionIndex)

    spacing: 10

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

        Image {
            anchors.fill: parent
            source: Qt.resolvedUrl("../images/icons/account-circle.svg")
            fillMode: Image.PreserveAspectFit
            opacity: 0.86
            smooth: true
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
        font.family: uiFont
        font.pixelSize: 14
        font.weight: Font.DemiBold
        horizontalAlignment: Text.AlignHCenter
        renderType: Text.NativeRendering
    }

    FrostedPill {
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
        font.family: uiFont
        font.pixelSize: 13
        text: ""
    }

    function currentUserName() {
        const item = userList.currentItem
        if (item && item.name) {
            return item.name
        }
        return userModel.lastUser
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
