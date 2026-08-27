import QtQuick 2.15

Item {
    id: root

    property string fallback: Qt.resolvedUrl("../backgrounds/default.png")

    readonly property var sources: [
        Qt.resolvedUrl("../backgrounds/current.png"),
        config.background ? Qt.resolvedUrl(config.background) : "",
        Qt.resolvedUrl("../backgrounds/default.png")
    ]

    property int sourceIndex: 0

    Image {
        anchors.fill: parent
        source: root.sources[root.sourceIndex] || root.fallback
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: true

        onStatusChanged: {
            if (status === Image.Error && root.sourceIndex < root.sources.length - 1) {
                root.sourceIndex += 1
            }
        }
    }
}
