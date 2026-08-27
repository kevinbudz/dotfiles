#!/usr/bin/env bash
# Copies the current Plasma desktop wallpaper into the theme so SDDM can display it.
set -euo pipefail

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$THEME_DIR/backgrounds/current.png"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/plasma-org.kde.plasma.desktop-appletsrc"

mkdir -p "$(dirname "$OUT")"

if [[ ! -r "$CONFIG" ]]; then
    exit 0
fi

# Prefer the primary screen (lastScreen=0) desktop containment wallpaper.
WALL="$(
    awk -F= '
        /^\[Containments\]\[[0-9]+\]$/ {
            section = $0
            in_wallpaper = 0
            is_desktop = 0
            loc = -1
            last_screen = ""
        }
        section != "" && /^plugin=/ { is_desktop = ($2 == "org.kde.plasma.folder") }
        section != "" && /^location=/ { loc = $2 + 0 }
        section != "" && /^lastScreen=/ { last_screen = $2 + 0 }
        /^\[Containments\]\[[0-9]+\]\[Wallpaper\]/ { in_wallpaper = 1 }
        in_wallpaper && /^Image=/ {
            path = substr($0, index($0, "=") + 1)
            sub(/^file:\/\//, "", path)
            if (is_desktop && loc == 0 && (last_screen == "" || last_screen == 0)) {
                print path
                exit
            }
        }
    ' "$CONFIG"
)"

# Fallback: first Image= entry in the config.
if [[ -z "$WALL" ]]; then
    WALL="$(grep -m1 '^Image=file://' "$CONFIG" | sed 's|^Image=file://||')"
fi

if [[ -z "$WALL" || ! -f "$WALL" ]]; then
    exit 0
fi

cp -f "$WALL" "$OUT"
chmod 644 "$OUT"

# Keep theme.conf in sync for tools that read it directly.
if [[ -w "$THEME_DIR/theme.conf" ]]; then
    if grep -q '^background=' "$THEME_DIR/theme.conf"; then
        sed -i "s|^background=.*|background=backgrounds/current.png|" "$THEME_DIR/theme.conf"
    else
        printf '\nbackground=backgrounds/current.png\n' >> "$THEME_DIR/theme.conf"
    fi
fi
