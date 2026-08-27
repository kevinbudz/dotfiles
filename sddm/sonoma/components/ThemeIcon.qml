import QtQuick 2.15

Item {
    id: root

    property string name: ""
    property int iconSize: 16

    implicitWidth: iconSize
    implicitHeight: iconSize
    opacity: 0.92

    Image {
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize
        source: root.name.length > 0
            ? Qt.resolvedUrl("../images/more/" + root.name + ".svg")
            : ""
        fillMode: Image.PreserveAspectFit
        smooth: true
    }
}
