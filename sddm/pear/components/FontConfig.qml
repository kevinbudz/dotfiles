import QtQuick 2.15

QtObject {
    function clean(value) {
        if (!value) {
            return ""
        }
        return String(value).replace(/^\s+|\s+$/g, "")
    }

    function hasValue(value) {
        return clean(value).length > 0
    }

    function choose(primary, secondary) {
        if (hasValue(primary)) {
            return clean(primary)
        }
        if (hasValue(secondary)) {
            return clean(secondary)
        }
        return ""
    }

    function hasChoice(primary, secondary) {
        return choose(primary, secondary).length > 0
    }

    function weight(primary, secondary) {
        var value = choose(primary, secondary).toLowerCase()
        var numeric = parseInt(value, 10)
        if (!isNaN(numeric)) {
            if (numeric >= 900) {
                return Font.Black
            }
            if (numeric >= 800) {
                return Font.ExtraBold
            }
            if (numeric >= 700) {
                return Font.Bold
            }
            if (numeric >= 600) {
                return Font.DemiBold
            }
            if (numeric >= 500) {
                return Font.Medium
            }
            if (numeric <= 100) {
                return Font.Thin
            }
            if (numeric <= 200) {
                return Font.ExtraLight
            }
            if (numeric <= 300) {
                return Font.Light
            }
            return Font.Normal
        }

        value = value.replace(/[\s_-]/g, "")
        if (value === "thin") {
            return Font.Thin
        }
        if (value === "extralight" || value === "ultralight") {
            return Font.ExtraLight
        }
        if (value === "light") {
            return Font.Light
        }
        if (value === "medium") {
            return Font.Medium
        }
        if (value === "demibold" || value === "semibold") {
            return Font.DemiBold
        }
        if (value === "bold") {
            return Font.Bold
        }
        if (value === "extrabold" || value === "ultrabold") {
            return Font.ExtraBold
        }
        if (value === "black" || value === "heavy") {
            return Font.Black
        }
        return Font.Normal
    }

    function hasWeight(primary, secondary) {
        return hasChoice(primary, secondary)
    }

    function italic(primary, secondary) {
        var value = choose(primary, secondary).toLowerCase()
        return value.indexOf("italic") !== -1 || value.indexOf("oblique") !== -1
    }

    function hasStyle(primary, secondary) {
        return hasChoice(primary, secondary)
    }
}
