import QtQuick 2.15
import Qt.labs.folderlistmodel 2.15

Item {
    id: root

    width: 0
    height: 0
    visible: false

    property bool hasBattery: false
    property int batteryPercent: 0
    property string networkType: "none" // ethernet | wifi | none

    readonly property string batteryIcon: {
        const p = batteryPercent
        if (p >= 90) return "battery-full"
        if (p >= 65) return "battery-good"
        if (p >= 40) return "battery-low"
        if (p >= 15) return "battery-empty"
        return "battery-caution"
    }

    readonly property string networkIcon: {
        if (networkType === "ethernet")
            return "network-wired-activated"
        if (networkType === "wifi")
            return "network-wireless-100"
        return ""
    }

    FolderListModel {
        id: powerSupplyModel
        folder: "file:///sys/class/power_supply"
        showFiles: false
        showDirs: true
    }

    FolderListModel {
        id: netModel
        folder: "file:///sys/class/net"
        showFiles: false
        showDirs: true
    }

    function readSysfs(path) {
        const xhr = new XMLHttpRequest()
        xhr.open("GET", "file://" + path, false)
        try {
            xhr.send()
        } catch (e) {
            return ""
        }
        if (xhr.status === 200 || xhr.status === 0)
            return xhr.responseText.replace(/\s+$/, "")
        return ""
    }

    function refreshBattery() {
        hasBattery = false
        batteryPercent = 0

        for (let i = 0; i < powerSupplyModel.count; i++) {
            const name = powerSupplyModel.get(i, "fileName")
            if (name.indexOf("BAT") !== 0 && name !== "battery")
                continue

            const base = "/sys/class/power_supply/" + name
            if (readSysfs(base + "/type") !== "Battery")
                continue

            hasBattery = true
            const cap = parseInt(readSysfs(base + "/capacity"), 10)
            if (!isNaN(cap) && cap >= 0)
                batteryPercent = cap
            return
        }
    }

    function interfaceUp(base) {
        if (readSysfs(base + "/operstate") !== "up")
            return false

        const carrierPath = base + "/carrier"
        const carrier = readSysfs(carrierPath)
        if (carrier.length > 0)
            return carrier === "1"
        return true
    }

    function refreshNetwork() {
        networkType = "none"

        for (let i = 0; i < netModel.count; i++) {
            const name = netModel.get(i, "fileName")
            if (name === "lo")
                continue

            const base = "/sys/class/net/" + name
            const type = readSysfs(base + "/type")
            if (type !== "1")
                continue
            if (!interfaceUp(base))
                continue

            networkType = "ethernet"
            return
        }

        for (let i = 0; i < netModel.count; i++) {
            const name = netModel.get(i, "fileName")
            if (name === "lo")
                continue

            const base = "/sys/class/net/" + name
            if (readSysfs(base + "/type") !== "801")
                continue
            if (!interfaceUp(base))
                continue

            networkType = "wifi"
            return
        }
    }

    function refresh() {
        refreshBattery()
        refreshNetwork()
    }

    Component.onCompleted: refresh()

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
