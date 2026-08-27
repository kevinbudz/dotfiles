import QtQuick

Item {
    id: root

    readonly property string configFont: "Google Sans"
    readonly property string fallbackFont: "Noto Sans"

    function choose(specific, globalFallback) {
        if (specific && specific.length > 0) return specific
        if (globalFallback && globalFallback.length > 0) return globalFallback
        return configFont
    }

    function hasChoice(specific, globalFallback) {
        return true
    }

    function weight(specificWeight, globalWeight) {
        if (specificWeight !== undefined && specificWeight !== null) return specificWeight
        if (globalWeight !== undefined && globalWeight !== null) return globalWeight
        return Font.Normal
    }

    function hasWeight(specificWeight, globalWeight) {
        return true
    }

    function italic(specificStyle, globalStyle) {
        return false
    }

    function hasStyle(specificStyle, globalStyle) {
        return false
    }
}
