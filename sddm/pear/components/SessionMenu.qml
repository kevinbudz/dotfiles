import QtQuick 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0

Item {
    id: root

    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property bool expanded: false

    readonly property int headerHeight: 32
    readonly property color menuColor: Qt.rgba(1, 1, 1, 0.15)
    readonly property int rowHeight: 30
    readonly property int menuPadding: 6
    readonly property int menuSpacing: 2
    readonly property int iconSize: 20
    readonly property string longestSessionName: {
        let longest = ""
        for (let i = 0; i < sessionEntries.count; i++) {
            const entry = sessionEntries.objectAt(i)
            if (entry && entry.sessionName.length > longest.length)
                longest = entry.sessionName
        }
        return longest
    }
    readonly property real menuContentWidth: menuPadding * 2
        + 16 + iconSize + 8 + menuMeasure.advanceWidth

    width: trigger.width
    height: headerHeight
    clip: false
    z: expanded ? 10 : 0

    FontConfig {
        id: fonts
    }

    // Short label on the header trigger only (e.g. "Wayland")
    function sessionShortLabel(name) {
        if (!name)
            return ""
        if (name.indexOf("Wayland") >= 0)
            return "Wayland"
        if (name.indexOf("X11") >= 0 || name.indexOf("Xorg") >= 0)
            return "X11"
        return name
    }

    function sessionNameAt(index) {
        for (let i = 0; i < sessionEntries.count; i++) {
            const entry = sessionEntries.objectAt(i)
            if (entry && entry.idx === index)
                return entry.sessionName
        }
        return ""
    }

    function sessionFileAt(index) {
        for (let i = 0; i < sessionEntries.count; i++) {
            const entry = sessionEntries.objectAt(i)
            if (entry && entry.idx === index)
                return entry.sessionFile
        }
        return ""
    }

    function sessionIconKey(name, file) {
        const blob = (name + " " + file).toLowerCase()
        if (blob.indexOf("plasma") >= 0 || blob.indexOf("kde") >= 0 || file === "plasma.desktop")
            return "plasma"
        if (blob.indexOf("gnome") >= 0)
            return "gnome"
        if (blob.indexOf("hyprland") >= 0)
            return "hyprland"
        if (blob.indexOf("sway") >= 0)
            return "sway"
        if (blob.indexOf("xfce") >= 0)
            return "xfce"
        if (blob.indexOf("cinnamon") >= 0)
            return "cinnamon"
        if (blob.indexOf("mate") >= 0)
            return "mate"
        if (blob.indexOf("lxqt") >= 0)
            return "lxqt"
        if (blob.indexOf("i3") >= 0)
            return "i3"
        if (file.length > 0)
            return file.replace(/\.desktop$/i, "")
        return "generic"
    }

    function sessionIconSource(name, file) {
        const key = sessionIconKey(name, file)
        if (key === "plasma")
            return Qt.resolvedUrl("../images/icons/sessions/plasma.svg")
        if (file.length > 0) {
            const base = file.replace(/\.desktop$/i, "")
            return Qt.resolvedUrl("../images/icons/sessions/" + base + ".svg")
        }
        return Qt.resolvedUrl("../images/icons/sessions/" + key + ".svg")
    }

    function selectSession(index) {
        if (index < 0 || index >= sessionModel.count)
            return
        sessionIndex = index
        expanded = false
    }

    Item {
        id: trigger
        height: headerHeight
        width: triggerRow.width
        clip: true

        Row {
            id: triggerRow
            height: headerHeight
            spacing: 6
            anchors.verticalCenter: parent.verticalCenter

            Image {
                anchors.verticalCenter: parent.verticalCenter
                source: root.sessionIconSource(
                    root.sessionNameAt(root.sessionIndex),
                    root.sessionFileAt(root.sessionIndex))
                sourceSize: Qt.size(root.iconSize, root.iconSize)
                width: root.iconSize
                height: root.iconSize
                fillMode: Image.PreserveAspectFit
                opacity: 0.85
                smooth: false
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.sessionShortLabel(root.sessionNameAt(root.sessionIndex))
                color: "#ffffff"
                font.pixelSize: 12
                font.weight: Font.DemiBold
                opacity: 0.92
                renderType: Text.NativeRendering

                Binding on font.family {
                    value: fonts.choose(config.sessionLabelFont, config.globalFont)
                    when: fonts.hasChoice(config.sessionLabelFont, config.globalFont)
                }

                Binding on font.weight {
                    value: fonts.weight(config.sessionLabelFontWeight, config.globalFontWeight)
                    when: fonts.hasWeight(config.sessionLabelFontWeight, config.globalFontWeight)
                }

                Binding on font.italic {
                    value: fonts.italic(config.sessionLabelFontStyle, config.globalFontStyle)
                    when: fonts.hasStyle(config.sessionLabelFontStyle, config.globalFontStyle)
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.expanded ? "▴" : "▾"
                color: "#ffffff"
                font.pixelSize: 8
                opacity: 0.55
                renderType: Text.NativeRendering

                Binding on font.family {
                    value: fonts.choose(config.sessionIndicatorFont, config.globalFont)
                    when: fonts.hasChoice(config.sessionIndicatorFont, config.globalFont)
                }

                Binding on font.weight {
                    value: fonts.weight(config.sessionIndicatorFontWeight, config.globalFontWeight)
                    when: fonts.hasWeight(config.sessionIndicatorFontWeight, config.globalFontWeight)
                }

                Binding on font.italic {
                    value: fonts.italic(config.sessionIndicatorFontStyle, config.globalFontStyle)
                    when: fonts.hasStyle(config.sessionIndicatorFontStyle, config.globalFontStyle)
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }
    }

    Rectangle {
        id: menu
        visible: root.expanded && sessionModel.count > 0
        y: headerHeight + 4
        width: Math.max(trigger.width, root.menuContentWidth)
        height: menuPadding * 2
            + sessionModel.count * root.rowHeight
            + Math.max(0, sessionModel.count - 1) * root.menuSpacing
        radius: 20
        color: root.menuColor
        border.color: Qt.rgba(1, 1, 1, 0.12)
        border.width: 1

        Column {
            id: menuColumn
            x: menuPadding
            y: menuPadding
            width: menu.width - menuPadding * 2
            spacing: menuSpacing

            Repeater {
                model: sessionModel

                delegate: Item {
                    required property int index
                    required property string name
                    required property string file

                    width: menuColumn.width
                    height: root.rowHeight

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        Image {
                            anchors.verticalCenter: parent.verticalCenter
                            source: root.sessionIconSource(name, file)
                            sourceSize: Qt.size(root.iconSize, root.iconSize)
                            width: root.iconSize
                            height: root.iconSize
                            fillMode: Image.PreserveAspectFit
                            opacity: 0.85
                            smooth: false
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: name
                            color: "#ffffff"
                            font.pixelSize: 12
                            opacity: index === root.sessionIndex ? 0.95 : 0.8
                            renderType: Text.NativeRendering

                            Binding on font.family {
                                value: fonts.choose(config.sessionMenuFont, config.globalFont)
                                when: fonts.hasChoice(config.sessionMenuFont, config.globalFont)
                            }

                            Binding on font.weight {
                                value: fonts.weight(config.sessionMenuFontWeight, config.globalFontWeight)
                                when: fonts.hasWeight(config.sessionMenuFontWeight, config.globalFontWeight)
                            }

                            Binding on font.italic {
                                value: fonts.italic(config.sessionMenuFontStyle, config.globalFontStyle)
                                when: fonts.hasStyle(config.sessionMenuFontStyle, config.globalFontStyle)
                            }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 14
                        color: index === root.sessionIndex
                            ? Qt.rgba(1, 1, 1, 0.14)
                            : (rowMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent")
                        z: -1
                    }

                    MouseArea {
                        id: rowMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.selectSession(index)
                    }
                }
            }
        }
    }

    TextMetrics {
        id: menuMeasure
        font.pixelSize: 12
        text: root.longestSessionName

        Binding on font.family {
            value: fonts.choose(config.sessionMenuFont, config.globalFont)
            when: fonts.hasChoice(config.sessionMenuFont, config.globalFont)
        }

        Binding on font.weight {
            value: fonts.weight(config.sessionMenuFontWeight, config.globalFontWeight)
            when: fonts.hasWeight(config.sessionMenuFontWeight, config.globalFontWeight)
        }

        Binding on font.italic {
            value: fonts.italic(config.sessionMenuFontStyle, config.globalFontStyle)
            when: fonts.hasStyle(config.sessionMenuFontStyle, config.globalFontStyle)
        }
    }

    Instantiator {
        id: sessionEntries
        model: sessionModel
        delegate: QtObject {
            property int idx: index
            property string sessionName: name
            property string sessionFile: file
        }
    }
}
