import QtQuick 2.15

Item {
    id: root

    readonly property int maxVisibleChars: 13

    QtObject {
        id: passwordStore
        property string value: ""

        onValueChanged: {
            if (!root._syncing) {
                root.updateDisplay()
            }
        }
    }

    property alias text: passwordStore.value
    property string placeholder: "Enter Password"
    property string uiFont: config.fontFamilyUI || "SF Pro Text"
    property bool capsLockOn: false
    readonly property bool hasText: passwordStore.value.length > 0
    property bool caretShown: true

    property string _lastDisplay: ""
    property bool _syncing: false
    property bool _replaceAllOnNextEdit: false

    signal accepted()
    signal submitClicked()

    implicitWidth: config.passwordFieldWidth ? parseInt(config.passwordFieldWidth) : 180
    implicitHeight: 30

    Rectangle {
        id: pill
        anchors.fill: parent
        radius: height / 2
        color: Qt.rgba(1, 1, 1, field.activeFocus ? 0.28 : 0.2)
        opacity: root.hasText ? 1 : 0

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on opacity { NumberAnimation { duration: 130 } }
    }

    Text {
        anchors.centerIn: parent
        text: placeholder
        visible: !root.hasText
        color: Qt.rgba(1, 1, 1, 0.72)
        font.family: uiFont
        font.pixelSize: 14
        horizontalAlignment: Text.AlignHCenter
    }

    TextInput {
        id: field
        anchors {
            left: parent.left
            right: submitButton.left
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: 5
            leftMargin: 16
            rightMargin: 6
        }
        height: parent.height
        clip: true
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        color: root.hasText ? "#ffffff" : "transparent"
        font.family: uiFont
        font.pixelSize: 34
        font.letterSpacing: -7
        echoMode: TextInput.Password
        passwordCharacter: "•"
        selectByMouse: true
        focus: true
        cursorDelegate: Item {
            width: 0
            height: 0
            visible: false
        }

        Keys.onReturnPressed: root.accepted()
        Keys.onEnterPressed: root.accepted()

        onTextChanged: {
            if (root._syncing) {
                return
            }

            var newText = text
            var oldDisplay = root._lastDisplay

            if (newText === oldDisplay) {
                return
            }

            if (root._replaceAllOnNextEdit) {
                passwordStore.value = newText
                root._replaceAllOnNextEdit = false
            } else if (newText.length > oldDisplay.length
                       && newText.indexOf(oldDisplay) === 0) {
                passwordStore.value += newText.slice(oldDisplay.length)
            } else if (newText.length < oldDisplay.length
                       && oldDisplay.indexOf(newText) === 0) {
                passwordStore.value = passwordStore.value.slice(0, passwordStore.value.length - (oldDisplay.length - newText.length))
            } else {
                passwordStore.value = newText
            }

            root.updateDisplay()
        }
    }

    Timer {
        id: caretBlinkTimer
        interval: {
            const flash = Qt.styleHints.cursorFlashTime
            return flash > 0 ? flash / 2 : 500
        }
        running: root.hasText && field.activeFocus
        repeat: true
        onTriggered: root.caretShown = !root.caretShown
        onRunningChanged: if (running) {
            root.caretShown = true
        }
    }

    Connections {
        target: field
        function onTextChanged() {
            root.caretShown = true
            if (caretBlinkTimer.running) {
                caretBlinkTimer.restart()
            }
        }
        function onCursorPositionChanged() {
            root.caretShown = true
            if (field.selectedText.length === 0) {
                root._replaceAllOnNextEdit = false
            }
            if (caretBlinkTimer.running) {
                caretBlinkTimer.restart()
            }
        }
    }

    function updateDisplay() {
        _syncing = true
        if (passwordStore.value.length <= maxVisibleChars) {
            field.text = passwordStore.value
        } else {
            field.text = passwordStore.value.substring(passwordStore.value.length - maxVisibleChars)
        }
        field.cursorPosition = field.text.length
        _lastDisplay = field.text
        _syncing = false
    }

    Component.onCompleted: updateDisplay()

    function bulletText(length) {
        var bullet = field.passwordCharacter
        var result = ""
        for (var i = 0; i < length; ++i) {
            result += bullet
        }
        return result
    }

    TextMetrics {
        id: caretMetrics
        font.family: field.font.family
        font.pixelSize: field.font.pixelSize
        font.letterSpacing: field.font.letterSpacing
        text: root.bulletText(field.cursorPosition)
    }

    TextMetrics {
        id: fullTextMetrics
        font.family: field.font.family
        font.pixelSize: field.font.pixelSize
        font.letterSpacing: field.font.letterSpacing
        text: root.bulletText(field.text.length)
    }

    Rectangle {
        id: caretIndicator
        width: 2
        height: 15
        radius: 1.5
        color: "#ffffff"
        opacity: 0.92
        visible: root.hasText && field.activeFocus && root.caretShown

        readonly property real textBeforeWidth: caretMetrics.advanceWidth
        readonly property real fullTextWidth: fullTextMetrics.advanceWidth
        readonly property real scrollX: {
            var viewport = field.width
            if (fullTextWidth <= viewport) {
                return 0
            }
            var maxScroll = fullTextWidth - viewport
            var scroll = Math.max(0, textBeforeWidth - viewport + 8)
            if (textBeforeWidth - scroll < 8) {
                scroll = Math.max(0, textBeforeWidth - 8)
            }
            return Math.min(scroll, maxScroll)
        }
        readonly property real visibleCaretX: textBeforeWidth - scrollX

        x: Math.max(field.x, Math.min(field.x + visibleCaretX + 4, field.x + field.width - width))
        y: field.y + ((field.height - height) / 2) - 5
    }

    Item {
        id: submitButton
        width: 24
        height: 24
        anchors {
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        enabled: root.hasText
        opacity: root.hasText ? (submitArea.containsMouse ? 1 : 0.78) : 0

        Behavior on opacity { NumberAnimation { duration: 130 } }

        Image {
            anchors.centerIn: parent
            width: 18
            height: 18
            source: Qt.resolvedUrl("../images/icons/arrow-right.svg")
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        MouseArea {
            id: submitArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.submitClicked()
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        anchors.topMargin: 8
        visible: capsLockOn
        text: "Caps Lock is on"
        color: Qt.rgba(1, 1, 1, 0.85)
        font.family: uiFont
        font.pixelSize: 13
    }

    function forceActiveFocus() {
        field.forceActiveFocus()
    }

    function clear() {
        passwordStore.value = ""
        updateDisplay()
    }

    function selectAll() {
        field.selectAll()
        _replaceAllOnNextEdit = true
    }
}
