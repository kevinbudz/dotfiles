import QtQuick

Item {
    id: root

    readonly property int maxVisibleChars: 16

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
    property bool capsLockOn: false
    readonly property bool hasText: passwordStore.value.length > 0
    property bool caretShown: true
    readonly property int bulletSize: 8
    readonly property int bulletSpacing: 3
    readonly property int bulletStep: bulletSize + bulletSpacing

    property string _lastDisplay: ""
    property bool _syncing: false
    property bool _replaceAllOnNextEdit: false

    signal accepted()
    signal submitClicked()

    implicitWidth: 200
    implicitHeight: 32

    FontConfig {
        id: fonts
    }

    Rectangle {
        id: pill
        anchors.fill: parent
        radius: height / 2
        color: Qt.rgba(1, 1, 1, field.activeFocus ? 0.28 : 0.2)
        opacity: root.hasText ? 1 : 0.65

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on opacity { NumberAnimation { duration: 130 } }
    }

    Text {
        anchors.centerIn: parent
        text: placeholder
        visible: !root.hasText
        color: Qt.rgba(1, 1, 1, 0.72)
        font.pixelSize: 14
        font.family: fonts.configFont
        horizontalAlignment: Text.AlignHCenter
    }

    TextInput {
        id: field
        anchors {
            left: parent.left
            right: submitButton.left
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: -1
            leftMargin: 16
            rightMargin: 6
        }
        height: parent.height
        clip: true
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        color: "transparent"
        selectedTextColor: "transparent"
        selectionColor: "transparent"
        echoMode: TextInput.Password
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
            if (root._syncing) return

            var newText = text
            var oldDisplay = root._lastDisplay

            if (newText === oldDisplay) return

            if (root._replaceAllOnNextEdit) {
                passwordStore.value = newText
                root._replaceAllOnNextEdit = false
            } else if (newText.length > oldDisplay.length && newText.indexOf(oldDisplay) === 0) {
                passwordStore.value += newText.slice(oldDisplay.length)
            } else if (newText.length < oldDisplay.length && oldDisplay.indexOf(newText) === 0) {
                passwordStore.value = passwordStore.value.slice(0, passwordStore.value.length - (oldDisplay.length - newText.length))
            } else {
                passwordStore.value = newText
            }

            root.updateDisplay()
        }
    }

    Item {
        id: bulletLayer
        x: field.x
        y: field.y
        width: field.width
        height: field.height
        clip: true
        visible: root.hasText

        Repeater {
            model: field.text.length

            Rectangle {
                width: root.bulletSize
                height: root.bulletSize
                radius: width / 2
                color: "#ffffff"
                opacity: 0.95
                x: (index * root.bulletStep) - caretIndicator.scrollX
                y: (bulletLayer.height - height) / 2 + 1
            }
        }
    }

    Timer {
        id: caretBlinkTimer
        interval: 500
        running: root.hasText && field.activeFocus
        repeat: true
        onTriggered: root.caretShown = !root.caretShown
    }

    Connections {
        target: field
        function onTextChanged() {
            root.caretShown = true
            if (caretBlinkTimer.running) caretBlinkTimer.restart()
        }
        function onCursorPositionChanged() {
            root.caretShown = true
            if (field.selectedText.length === 0) {
                root._replaceAllOnNextEdit = false
            }
            if (caretBlinkTimer.running) caretBlinkTimer.restart()
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

    Rectangle {
        id: caretIndicator
        width: 2
        height: 15
        radius: 1.5
        color: "#ffffff"
        opacity: 0.92
        visible: root.hasText && field.activeFocus && root.caretShown

        readonly property real textBeforeWidth: field.cursorPosition * root.bulletStep
        readonly property real fullTextWidth: field.text.length > 0
            ? ((field.text.length - 1) * root.bulletStep) + root.bulletSize
            : 0
        readonly property real scrollX: {
            var viewport = field.width
            if (fullTextWidth <= viewport) return 0
            var maxScroll = fullTextWidth - viewport
            var scroll = Math.max(0, textBeforeWidth - viewport + 8)
            if (textBeforeWidth - scroll < 8) scroll = Math.max(0, textBeforeWidth - 8)
            return Math.min(scroll, maxScroll)
        }
        readonly property real visibleCaretX: textBeforeWidth - scrollX

        x: Math.max(field.x, Math.min(field.x + visibleCaretX, field.x + field.width - width))
        y: field.y + ((field.height - height) / 2)
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
        font.pixelSize: 13
        font.family: fonts.configFont
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
