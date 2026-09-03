#!/usr/bin/env bash
# Apply the current Plasma wallpaper to the lock screen and Pear SDDM theme.
set -euo pipefail

USER_HOME="${HOME}"
CONFIG="${XDG_CONFIG_HOME:-$USER_HOME/.config}/plasma-org.kde.plasma.desktop-appletsrc"
LOCK_CONFIG="${XDG_CONFIG_HOME:-$USER_HOME/.config}/kscreenlockerrc"
WALLPAPERS_DIR="$USER_HOME/.local/share/wallpapers"

read_plasma_wallpaper() {
    local config="$1"
    [[ -r "$config" ]] || return 0

    awk -F= '
        /^\[Containments\]\[[0-9]+\]$/ {
            in_wallpaper = 0
            is_desktop = 0
            loc = -1
            last_screen = ""
        }
        /^plugin=/ { is_desktop = ($2 == "org.kde.desktopcontainment" || $2 == "org.kde.plasma.folder") }
        /^location=/ { loc = $2 + 0 }
        /^lastScreen=/ { last_screen = $2 + 0 }
        /^\[Containments\]\[[0-9]+\]\[Wallpaper\]/ { in_wallpaper = 1 }
        in_wallpaper && /^Image=/ {
            path = substr($0, index($0, "=") + 1)
            sub(/^file:\/\//, "", path)
            if (is_desktop && loc == 0) {
                print path
                if (last_screen == "" || last_screen == 0) exit
            }
        }
    ' "$config"
}

resolve_wallpaper() {
    local path="$1"
    local profile src

    if [[ -z "$path" ]]; then
        return 1
    fi

    if [[ "$path" == *"/superpaper/"* || "$path" == *"/cache/superpaper/"* ]]; then
        for profile in "$USER_HOME/.config/superpaper/profiles/"*; do
            [[ -f "$profile" ]] || continue
            src="$(grep -m1 '^display0paths=' "$profile" | cut -d= -f2- | cut -d';' -f1)"
            if [[ -n "$src" && -f "$src" ]]; then
                printf '%s\n' "$src"
                return 0
            fi
        done
    fi

    if [[ -f "$path" ]]; then
        printf '%s\n' "$path"
        return 0
    fi
    return 1
}

render_sddm_backgrounds() {
    local src="$1"
    local dest_dir="$2"
    [[ -f "$src" && -d "$dest_dir" ]] || return 0
    mkdir -p "$dest_dir"

    if command -v magick >/dev/null; then
        magick "$src" -resize '1920x1080^' -gravity center -extent 1920x1080 "$dest_dir/landscape.png"
        magick "$src" -resize '1080x1920^' -gravity center -extent 1080x1920 "$dest_dir/portrait.png"
        cp -f "$dest_dir/landscape.png" "$dest_dir/current.png"
    elif command -v convert >/dev/null; then
        convert "$src" -resize '1920x1080^' -gravity center -extent 1920x1080 "$dest_dir/landscape.png"
        convert "$src" -resize '1080x1920^' -gravity center -extent 1080x1920 "$dest_dir/portrait.png"
        cp -f "$dest_dir/landscape.png" "$dest_dir/current.png"
    else
        cp -f "$src" "$dest_dir/current.png"
    fi

    if [[ -w "$dest_dir/../theme.conf" ]] && grep -q '^background=' "$dest_dir/../theme.conf"; then
        sed -i 's|^background=.*|background=backgrounds/current.png|' "$dest_dir/../theme.conf"
    fi
}

apply_lock_screen() {
    local src="$1"
    local uri="file://$src"
    [[ -f "$src" ]] || return 0

    if command -v kwriteconfig6 >/dev/null; then
        kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "$uri"
        kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key PreviewImage "$uri"
    else
        mkdir -p "$(dirname "$LOCK_CONFIG")"
        if [[ -f "$LOCK_CONFIG" ]]; then
            sed -i "s|^Image=.*|Image=$uri|" "$LOCK_CONFIG"
            sed -i "s|^PreviewImage=.*|PreviewImage=$uri|" "$LOCK_CONFIG"
        fi
    fi
}

WALL="${1:-}"
if [[ -z "$WALL" ]]; then
    WALL="$(read_plasma_wallpaper "$CONFIG" | head -n1 || true)"
fi
WALL="$(resolve_wallpaper "${WALL:-}" || true)"

if [[ -z "$WALL" || ! -f "$WALL" ]]; then
    exit 0
fi

mkdir -p "$WALLPAPERS_DIR"
dest="$WALLPAPERS_DIR/$(basename "$WALL")"
if [[ "$WALL" != "$dest" ]]; then
    cp -f "$WALL" "$dest"
    WALL="$dest"
fi

apply_lock_screen "$WALL"

for theme_dir in \
    "$USER_HOME/.local/share/sddm/themes/pear" \
    "/usr/share/sddm/themes/pear"
do
    if [[ -d "$theme_dir/backgrounds" && -w "$theme_dir/backgrounds" ]]; then
        render_sddm_backgrounds "$WALL" "$theme_dir/backgrounds"
    fi
done
