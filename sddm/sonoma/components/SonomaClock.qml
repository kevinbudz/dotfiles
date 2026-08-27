import QtQuick 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root

    // Use the shorter edge so portrait monitors don't scale text to the long side.
    property real referenceSize: 1080
    property string displayFont: config.fontFamily || "SF Pro Display"
    property date dateTime: new Date()

    readonly property int dateSize: Math.round(referenceSize * 0.034)
    readonly property int timeSize: Math.round(referenceSize * 0.15)

    spacing: 0

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
        opacity: 0.7
        font.family: displayFont
        font.pixelSize: dateSize
        font.weight: Font.Normal
        style: Text.Normal
        renderType: Text.NativeRendering
    }

    Text {
        id: timeLabel
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: -2
        text: Qt.formatTime(root.dateTime, "h:mm")
        color: "#ffffff"
        opacity: 0.7
        font.family: displayFont
        font.pixelSize: timeSize
        font.weight: Font.Medium
        font.letterSpacing: -3
        style: Text.Normal
        renderType: Text.NativeRendering
    }
}
