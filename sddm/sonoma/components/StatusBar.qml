import QtQuick 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0

import "."

RowLayout {
    id: root

    property string uiFont: config.fontFamilyUI || "SF Pro Text"

    spacing: 14
    layoutDirection: Qt.RightToLeft

    signal controlCenterToggled()

    GreeterStatus {
        id: greeterStatus
    }

    Item {
        Layout.preferredWidth: 20
        Layout.preferredHeight: 20

        MouseArea {
            id: controlArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.controlCenterToggled()
        }
    }

    ThemeIcon {
        iconSize: 16
        name: greeterStatus.networkIcon
        visible: greeterStatus.networkType !== "none"
        opacity: 0.7
    }

    RowLayout {
        spacing: 4
        visible: greeterStatus.hasBattery
        Layout.alignment: Qt.AlignVCenter

        ThemeIcon {
            iconSize: 16
            name: greeterStatus.batteryIcon
            opacity: 0.7
        }

        Text {
            text: greeterStatus.batteryPercent + "%"
            color: "#ffffff"
            font.family: uiFont
            font.pixelSize: 11
            opacity: 0.92
        }
    }

    LayoutBox {
        id: layoutBox
        visible: keyboard.enabled && keyboard.layouts.length > 0
        Layout.preferredHeight: 22
        Layout.minimumWidth: 48

        color: "transparent"
        borderColor: "transparent"
        focusColor: "transparent"
        hoverColor: Qt.rgba(1, 1, 1, 0.15)
        textColor: "#ffffff"
        menuColor: Qt.rgba(0.15, 0.15, 0.15, 0.92)

        font.family: uiFont
        font.pixelSize: 12

        arrowIcon: ""
        arrowColor: "transparent"
    }

    Text {
        visible: layoutBox.visible
        text: keyboard.layouts.length > layoutBox.currentIndex
            ? keyboard.layouts[layoutBox.currentIndex].shortName
            : ""
        color: "#ffffff"
        font.family: uiFont
        font.pixelSize: 12
        opacity: 0.92
        Layout.alignment: Qt.AlignVCenter
    }
}
