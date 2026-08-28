import QtQuick 2.15
import SddmComponents 2.0

import "components"

Item {
    id: root

    width: 1920
    height: 1080

    LayoutMirroring.enabled: Qt.locale().textDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    // Background on all monitors
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
        }
    }

    // Target screen geometry helper
    readonly property var targetGeometry: {
        var target = (config.loginScreenOutput || "").trim()
        if (typeof screenModel !== "undefined" && screenModel && screenModel.count > 0) {
            for (var i = 0; i < screenModel.count; ++i) {
                var item = screenModel.get(i)
                if (item && target.length > 0 && (item.name === target || item.name.indexOf(target) >= 0)) {
                    return item.geometry
                }
            }
            if (screenModel.primaryIndex >= 0 && screenModel.primaryIndex < screenModel.count) {
                var p = screenModel.get(screenModel.primaryIndex)
                if (p) return p.geometry
            }
            var first = screenModel.get(0)
            if (first) return first.geometry
        }
        return Qt.rect(0, 0, root.width, root.height)
    }

    Item {
        id: uiContainer
        x: root.targetGeometry.x
        y: root.targetGeometry.y
        width: root.targetGeometry.width
        height: root.targetGeometry.height
        visible: true

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
            login.onLoginFailed()
        }

        function onLoginSucceeded() {
            login.onLoginSucceeded()
        }
    }
}
