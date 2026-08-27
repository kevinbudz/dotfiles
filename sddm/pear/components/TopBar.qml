import QtQuick 2.15
import QtQuick.Layouts 1.15

import "."

Item {
    id: root

    property alias sessionIndex: sessionMenu.sessionIndex
    property alias sessionMenuOpen: sessionMenu.expanded

    property bool opaqueBackground: false

    implicitHeight: 32
    height: 32

    Rectangle {
        z: -1
        anchors.fill: parent
        visible: root.opaqueBackground
        color: "#1a1a1e"
    }

    SessionMenu {
        id: sessionMenu
        z: 1
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
    }

    RowLayout {
        id: slot
        anchors.left: sessionMenu.right
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 32
        spacing: 8

        default property alias content: slot.data
    }
}
