import QtQuick 2.15
import QtQuick.Layouts 1.15

import "."

Rectangle {
    id: root

    property string label
    property string icon: ""
    property bool enabled: true

    signal triggered()

    Layout.fillWidth: true
    implicitHeight: enabled ? 28 : 0
    visible: enabled
    radius: 6
    color: actionArea.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 7

        ThemeIcon {
            visible: root.icon.length > 0
            name: root.icon
            iconSize: 14
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: root.label
            color: "#ffffff"
            font.family: config.fontFamilyUI || "SF Pro Text"
            font.pixelSize: 12
            Layout.fillWidth: true
        }
    }

    MouseArea {
        id: actionArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.triggered()
    }
}
