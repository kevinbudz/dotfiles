import QtQuick 2.15

Item {
    id: root

    // Determine whether this background is on a landscape or portrait screen
    readonly property bool isLandscape: width >= height

    readonly property string primarySource: isLandscape
        ? Qt.resolvedUrl("../backgrounds/landscape.png")
        : Qt.resolvedUrl("../backgrounds/portrait.png")

    readonly property var fallbackSources: [
        primarySource,
        Qt.resolvedUrl("../backgrounds/current.png"),
        config.background ? Qt.resolvedUrl(config.background) : "",
        Qt.resolvedUrl("../backgrounds/default.png")
    ]

    property int sourceIndex: 0

    Image {
        anchors.fill: parent
        source: root.fallbackSources[root.sourceIndex]
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: true

        onStatusChanged: {
            if (status === Image.Error && root.sourceIndex < root.fallbackSources.length - 1) {
                root.sourceIndex += 1
            }
        }
    }
}
