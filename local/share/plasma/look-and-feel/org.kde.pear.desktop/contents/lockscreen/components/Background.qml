import QtQuick

Item {
    id: root

    property string fallback: Qt.resolvedUrl("../backgrounds/default.png")

    readonly property var sources: [
        "file://" + Qt.application.arguments[0] !== "" ? Qt.resolvedUrl("../backgrounds/current.png") : "",
        Qt.resolvedUrl("../backgrounds/default.png")
    ]

    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("../backgrounds/current.png")
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: true

        onStatusChanged: {
            if (status === Image.Error) {
                source = Qt.resolvedUrl("../backgrounds/default.png")
            }
        }
    }
}
