import QtQuick 2.15
import QtQuick.Layouts 1.15

RowLayout {
    id: root

    property int sessionIndex: sessionModel.lastIndex
    property string displayFont: config.fontFamily || "SF Pro Display"
    property string _sessionName: ""

    spacing: 6
    opacity: 0.7
    visible: label.text.length > 0

    LayoutMirroring.enabled: false

    function sessionLabel(name) {
        if (!name)
            return ""
        if (name.indexOf("Wayland") >= 0)
            return "Wayland"
        if (name.indexOf("X11") >= 0 || name.indexOf("Xorg") >= 0)
            return "X11"
        return name
    }

    function refreshName() {
        _sessionName = ""
        for (let i = 0; i < sessionNames.count; i++) {
            const entry = sessionNames.objectAt(i)
            if (entry && entry.idx === sessionIndex) {
                _sessionName = entry.sessionName
                break
            }
        }
    }

    Image {
        source: Qt.resolvedUrl("../images/icons/start-here-kde.svg")
        sourceSize: Qt.size(18, 18)
        Layout.preferredWidth: 18
        Layout.preferredHeight: 18
        fillMode: Image.PreserveAspectFit
    }

    Text {
        id: label
        text: sessionLabel(_sessionName)
        color: "#ffffff"
        font.family: displayFont
        font.weight: Font.Bold
        font.pixelSize: 14
    }

    Instantiator {
        id: sessionNames
        model: sessionModel
        delegate: QtObject {
            property int idx: index
            property string sessionName: name
        }
        onObjectAdded: root.refreshName()
        onObjectRemoved: root.refreshName()
    }

    onSessionIndexChanged: refreshName()
    Component.onCompleted: refreshName()
}
