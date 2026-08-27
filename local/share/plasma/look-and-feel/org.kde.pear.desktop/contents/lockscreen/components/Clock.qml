import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property real referenceSize: 1080
    property date dateTime: new Date()

    readonly property int dateSize: Math.round(referenceSize * 0.034)
    readonly property int timeSize: Math.round(referenceSize * 0.15)

    spacing: 0

    FontConfig {
        id: fonts
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.dateTime = new Date()
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: Qt.formatDate(root.dateTime, "dddd, MMMM d")
        color: "#ffffff"
        opacity: 0.75
        font.pixelSize: root.dateSize
        font.weight: Font.Normal
        font.family: fonts.configFont
        style: Text.Normal
        renderType: Text.NativeRendering
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: Qt.formatTime(root.dateTime, "h:mm")
        color: "#ffffff"
        opacity: 0.95
        font.pixelSize: root.timeSize
        font.weight: Font.Bold
        font.family: fonts.configFont
        style: Text.Normal
        renderType: Text.NativeRendering
    }
}
