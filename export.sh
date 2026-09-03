#!/usr/bin/env bash
# export.sh - Export current KDE Plasma look & feel settings into this dotfiles repo
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_HOME="${HOME}"

echo "=========================================================="
echo " Exporting KDE Plasma look & feel settings to dotfiles..."
echo "=========================================================="

copy_file() {
    local src="$1"
    local dst="$2"
    if [[ -f "$src" ]]; then
        mkdir -p "$(dirname "$dst")"
        cp -f "$src" "$dst"
        echo "  [FILE] $src -> $(realpath --relative-to="$DOTFILES_DIR" "$dst")"
    fi
}

copy_dir() {
    local src="$1"
    local dst="$2"
    if [[ -d "$src" ]]; then
        mkdir -p "$dst"
        rsync -a --delete --exclude='*.bak' --exclude='*.bak.*' --exclude='icon-theme.cache' --exclude='.uuid' "$src/" "$dst/"
        echo "  [DIR]  $src -> $(realpath --relative-to="$DOTFILES_DIR" "$dst")"
    fi
}

strip_ini_group() {
    local file="$1"
    local group="$2"
    [[ -f "$file" ]] || return 0
    awk -v g="[$group]" '
        $0 == g { skip = 1; next }
        /^\[/ { skip = 0 }
        !skip { print }
    ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

round_corners_value() {
    local key="$1"
    local default="$2"
    local value=""
    if command -v kreadconfig6 >/dev/null; then
        value="$(kreadconfig6 --file kwinrc --group Round-Corners --key "$key")"
        if [[ -z "$value" ]]; then
            value="$(kreadconfig6 --file kwinrc --group Effect-kwin4_effect_shapecorners --key "$key")"
        fi
    fi
    printf '%s' "${value:-$default}"
}

# KConfig only writes keys that differ from plugin defaults, and older
# Rounded Corners builds used [Effect-kwin4_effect_shapecorners]. Snapshot
# the live effect into a complete [Round-Corners] group so install applies it.
snapshot_round_corners() {
    local kwinrc="$DOTFILES_DIR/config/kwinrc"
    [[ -f "$kwinrc" ]] || return 0

    strip_ini_group "$kwinrc" "Effect-kwin4_effect_shapecorners"
    strip_ini_group "$kwinrc" "Round-Corners"

    {
        echo
        echo "[Round-Corners]"
        echo "Size=$(round_corners_value Size 8)"
        echo "InactiveCornerRadius=$(round_corners_value InactiveCornerRadius 8)"
        echo "UseSquircleShape=$(round_corners_value UseSquircleShape false)"
        echo "Squircleness=$(round_corners_value Squircleness 0.55)"
        echo "AnimationDuration=$(round_corners_value AnimationDuration 250)"
        echo "UseNativeDecorationShadows=$(round_corners_value UseNativeDecorationShadows false)"
        echo "ShadowSize=$(round_corners_value ShadowSize 40)"
        echo "InactiveShadowSize=$(round_corners_value InactiveShadowSize 40)"
        echo "ShadowColor=$(round_corners_value ShadowColor 0,0,0)"
        echo "InactiveShadowColor=$(round_corners_value InactiveShadowColor 0,0,0)"
        echo "ActiveShadowAlpha=$(round_corners_value ActiveShadowAlpha 72)"
        echo "InactiveShadowAlpha=$(round_corners_value InactiveShadowAlpha 64)"
        echo "ActiveShadowPalette=$(round_corners_value ActiveShadowPalette 11)"
        echo "InactiveShadowPalette=$(round_corners_value InactiveShadowPalette 11)"
        echo "ActiveShadowUsePalette=$(round_corners_value ActiveShadowUsePalette false)"
        echo "InactiveShadowUsePalette=$(round_corners_value InactiveShadowUsePalette false)"
        echo "ActiveShadowUseCustom=$(round_corners_value ActiveShadowUseCustom false)"
        echo "InactiveShadowUseCustom=$(round_corners_value InactiveShadowUseCustom false)"
        echo "OutlineThickness=$(round_corners_value OutlineThickness 0)"
        echo "InactiveOutlineThickness=$(round_corners_value InactiveOutlineThickness 0)"
        echo "OutlineColor=$(round_corners_value OutlineColor 0,0,0)"
        echo "InactiveOutlineColor=$(round_corners_value InactiveOutlineColor 0,0,0)"
        echo "ActiveOutlineAlpha=$(round_corners_value ActiveOutlineAlpha 255)"
        echo "InactiveOutlineAlpha=$(round_corners_value InactiveOutlineAlpha 255)"
        echo "ActiveOutlinePalette=$(round_corners_value ActiveOutlinePalette 12)"
        echo "InactiveOutlinePalette=$(round_corners_value InactiveOutlinePalette 12)"
        echo "ActiveOutlineUsePalette=$(round_corners_value ActiveOutlineUsePalette false)"
        echo "InactiveOutlineUsePalette=$(round_corners_value InactiveOutlineUsePalette false)"
        echo "ActiveOutlineUseCustom=$(round_corners_value ActiveOutlineUseCustom true)"
        echo "InactiveOutlineUseCustom=$(round_corners_value InactiveOutlineUseCustom true)"
        echo "OutlineIsGradient=$(round_corners_value OutlineIsGradient false)"
        echo "InactiveOutlineIsGradient=$(round_corners_value InactiveOutlineIsGradient false)"
        echo "OutlineColor2=$(round_corners_value OutlineColor2 0,0,0)"
        echo "InactiveOutlineColor2=$(round_corners_value InactiveOutlineColor2 0,0,0)"
        echo "OutlineGradientAngle=$(round_corners_value OutlineGradientAngle 45)"
        echo "InactiveOutlineGradientAngle=$(round_corners_value InactiveOutlineGradientAngle 45)"
        echo "SecondOutlineThickness=$(round_corners_value SecondOutlineThickness 0.75)"
        echo "InactiveSecondOutlineThickness=$(round_corners_value InactiveSecondOutlineThickness 0.75)"
        echo "SecondOutlineColor=$(round_corners_value SecondOutlineColor 255,255,255)"
        echo "InactiveSecondOutlineColor=$(round_corners_value InactiveSecondOutlineColor 255,255,255)"
        echo "ActiveSecondOutlineAlpha=$(round_corners_value ActiveSecondOutlineAlpha 41)"
        echo "InactiveSecondOutlineAlpha=$(round_corners_value InactiveSecondOutlineAlpha 43)"
        echo "ActiveSecondOutlinePalette=$(round_corners_value ActiveSecondOutlinePalette 12)"
        echo "InactiveSecondOutlinePalette=$(round_corners_value InactiveSecondOutlinePalette 12)"
        echo "ActiveSecondOutlineUsePalette=$(round_corners_value ActiveSecondOutlineUsePalette false)"
        echo "InactiveSecondOutlineUsePalette=$(round_corners_value InactiveSecondOutlineUsePalette false)"
        echo "ActiveSecondOutlineUseCustom=$(round_corners_value ActiveSecondOutlineUseCustom true)"
        echo "InactiveSecondOutlineUseCustom=$(round_corners_value InactiveSecondOutlineUseCustom true)"
        echo "SecondOutlineIsGradient=$(round_corners_value SecondOutlineIsGradient false)"
        echo "InactiveSecondOutlineIsGradient=$(round_corners_value InactiveSecondOutlineIsGradient false)"
        echo "SecondOutlineColor2=$(round_corners_value SecondOutlineColor2 255,255,255)"
        echo "InactiveSecondOutlineColor2=$(round_corners_value InactiveSecondOutlineColor2 255,255,255)"
        echo "SecondOutlineGradientAngle=$(round_corners_value SecondOutlineGradientAngle 45)"
        echo "InactiveSecondOutlineGradientAngle=$(round_corners_value InactiveSecondOutlineGradientAngle 45)"
        echo "OuterOutlineThickness=$(round_corners_value OuterOutlineThickness 0)"
        echo "InactiveOuterOutlineThickness=$(round_corners_value InactiveOuterOutlineThickness 0)"
        echo "OuterOutlineColor=$(round_corners_value OuterOutlineColor 0,0,0)"
        echo "InactiveOuterOutlineColor=$(round_corners_value InactiveOuterOutlineColor 0,0,0)"
        echo "ActiveOuterOutlineAlpha=$(round_corners_value ActiveOuterOutlineAlpha 255)"
        echo "InactiveOuterOutlineAlpha=$(round_corners_value InactiveOuterOutlineAlpha 255)"
        echo "ActiveOuterOutlinePalette=$(round_corners_value ActiveOuterOutlinePalette 12)"
        echo "InactiveOuterOutlinePalette=$(round_corners_value InactiveOuterOutlinePalette 12)"
        echo "ActiveOuterOutlineUsePalette=$(round_corners_value ActiveOuterOutlineUsePalette false)"
        echo "InactiveOuterOutlineUsePalette=$(round_corners_value InactiveOuterOutlineUsePalette false)"
        echo "ActiveOuterOutlineUseCustom=$(round_corners_value ActiveOuterOutlineUseCustom true)"
        echo "InactiveOuterOutlineUseCustom=$(round_corners_value InactiveOuterOutlineUseCustom true)"
        echo "OuterOutlineIsGradient=$(round_corners_value OuterOutlineIsGradient false)"
        echo "InactiveOuterOutlineIsGradient=$(round_corners_value InactiveOuterOutlineIsGradient false)"
        echo "OuterOutlineColor2=$(round_corners_value OuterOutlineColor2 0,0,0)"
        echo "InactiveOuterOutlineColor2=$(round_corners_value InactiveOuterOutlineColor2 0,0,0)"
        echo "OuterOutlineGradientAngle=$(round_corners_value OuterOutlineGradientAngle 45)"
        echo "InactiveOuterOutlineGradientAngle=$(round_corners_value InactiveOuterOutlineGradientAngle 45)"
        echo "IncludeNormalWindows=$(round_corners_value IncludeNormalWindows true)"
        echo "IncludeDialogs=$(round_corners_value IncludeDialogs true)"
        echo "DisableRoundTile=$(round_corners_value DisableRoundTile true)"
        echo "DisableOutlineTile=$(round_corners_value DisableOutlineTile true)"
        echo "DisableRoundMaximize=$(round_corners_value DisableRoundMaximize true)"
        echo "DisableOutlineMaximize=$(round_corners_value DisableOutlineMaximize true)"
        echo "DisableRoundFullScreen=$(round_corners_value DisableRoundFullScreen true)"
        echo "DisableOutlineFullScreen=$(round_corners_value DisableOutlineFullScreen true)"
        local inclusions exclusions
        inclusions="$(round_corners_value Inclusions "")"
        exclusions="$(round_corners_value Exclusions "")"
        [[ -n "$inclusions" ]] && echo "Inclusions=$inclusions"
        [[ -n "$exclusions" ]] && echo "Exclusions=$exclusions"
    } >> "$kwinrc"

    if ! grep -q '^kwin4_effect_shapecornersEnabled=' "$kwinrc"; then
        if grep -q '^\[Plugins\]$' "$kwinrc"; then
            sed -i '/^\[Plugins\]$/a kwin4_effect_shapecornersEnabled=true' "$kwinrc"
        fi
    fi
    echo "  [OK]   Snapshotted Rounded Corners effect into config/kwinrc"
}

resolve_live_wallpaper() {
    local path="${1:-}"
    local profile src
    [[ -n "$path" ]] || return 1
    if [[ "$path" == *"/superpaper/"* ]]; then
        for profile in "$USER_HOME/.config/superpaper/profiles/"*; do
            [[ -f "$profile" ]] || continue
            src="$(grep -m1 '^display0paths=' "$profile" | cut -d= -f2- | cut -d';' -f1)"
            if [[ -n "$src" && -f "$src" ]]; then
                printf '%s\n' "$src"
                return 0
            fi
        done
    fi
    [[ -f "$path" ]] || return 1
    printf '%s\n' "$path"
}

render_sddm_backgrounds() {
    local src="$1"
    local dest_dir="$2"
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
}

export_current_wallpaper() {
    local appletsrc="$DOTFILES_DIR/config/plasma-org.kde.plasma.desktop-appletsrc"
    local lockrc="$DOTFILES_DIR/config/kscreenlockerrc"
    local live_path dest_name dest_path uri
    mkdir -p "$DOTFILES_DIR/wallpapers"

    live_path="$(grep -m1 '^Image=file://' "$USER_HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" 2>/dev/null | sed 's|^Image=file://||' || true)"
    live_path="$(resolve_live_wallpaper "$live_path" || true)"
    if [[ -z "$live_path" || ! -f "$live_path" ]]; then
        live_path="$(grep -m1 '^Image=file://' "$USER_HOME/.config/kscreenlockerrc" 2>/dev/null | sed 's|^Image=file://||' || true)"
        live_path="$(resolve_live_wallpaper "$live_path" || true)"
    fi
    [[ -n "$live_path" && -f "$live_path" ]] || return 0

    dest_name="$(basename "$live_path")"
    dest_path="$DOTFILES_DIR/wallpapers/$dest_name"
    cp -f "$live_path" "$dest_path"
    echo "  [FILE] $live_path -> wallpapers/$dest_name"

    uri="file://$USER_HOME/.local/share/wallpapers/$dest_name"
    if [[ -f "$appletsrc" ]]; then
        sed -i "s|^Image=file://.*|Image=$uri|" "$appletsrc"
        sed -i "s|^SlidePaths=.*|SlidePaths=$USER_HOME/.local/share/wallpapers/|" "$appletsrc"
    fi
    if [[ -f "$lockrc" ]]; then
        sed -i "s|^Image=file://.*|Image=$uri|" "$lockrc"
        sed -i "s|^PreviewImage=file://.*|PreviewImage=$uri|" "$lockrc"
    fi

    if [[ -d "$DOTFILES_DIR/sddm/pear/backgrounds" ]]; then
        render_sddm_backgrounds "$dest_path" "$DOTFILES_DIR/sddm/pear/backgrounds"
        echo "  [OK]   Updated Pear SDDM backgrounds from current wallpaper"
    fi
}

# 1. Config files
copy_file "$USER_HOME/.config/breezerc" "$DOTFILES_DIR/config/breezerc"
copy_file "$USER_HOME/.config/dolphinrc" "$DOTFILES_DIR/config/dolphinrc"
copy_file "$USER_HOME/.config/kactivitymanagerdrc" "$DOTFILES_DIR/config/kactivitymanagerdrc"
copy_file "$USER_HOME/.config/kdeglobals" "$DOTFILES_DIR/config/kdeglobals"
copy_file "$USER_HOME/.config/kglobalshortcutsrc" "$DOTFILES_DIR/config/kglobalshortcutsrc"
copy_file "$USER_HOME/.config/kwinrc" "$DOTFILES_DIR/config/kwinrc"
copy_file "$USER_HOME/.config/kwinrulesrc" "$DOTFILES_DIR/config/kwinrulesrc"
copy_file "$USER_HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" "$DOTFILES_DIR/config/plasma-org.kde.plasma.desktop-appletsrc"
copy_file "$USER_HOME/.config/plasmarc" "$DOTFILES_DIR/config/plasmarc"
copy_file "$USER_HOME/.config/plasmashellrc" "$DOTFILES_DIR/config/plasmashellrc"
copy_file "$USER_HOME/.config/kscreenlockerrc" "$DOTFILES_DIR/config/kscreenlockerrc"
copy_file "$USER_HOME/.config/spectaclerc" "$DOTFILES_DIR/config/spectaclerc"
copy_file "$USER_HOME/.config/gtkrc" "$DOTFILES_DIR/config/gtkrc"
copy_file "$USER_HOME/.config/gtkrc-2.0" "$DOTFILES_DIR/config/gtkrc-2.0"
copy_file "$USER_HOME/.config/alacritty/alacritty.toml" "$DOTFILES_DIR/config/alacritty/alacritty.toml"
copy_file "$USER_HOME/.config/autostart/klassy-gtk-fix.desktop" "$DOTFILES_DIR/config/autostart/klassy-gtk-fix.desktop"
copy_file "$USER_HOME/.config/autostart/plasma-sddm-wallpaper.desktop" "$DOTFILES_DIR/config/autostart/plasma-sddm-wallpaper.desktop"
copy_file "$USER_HOME/.config/fontconfig/fonts.conf" "$DOTFILES_DIR/config/fontconfig/fonts.conf"
copy_file "$USER_HOME/.config/kdedefaults/kdeglobals" "$DOTFILES_DIR/config/kdedefaults/kdeglobals"
copy_file "$USER_HOME/.config/klassy/klassyrc" "$DOTFILES_DIR/config/klassy/klassyrc"
copy_file "$USER_HOME/.config/klassy/windecopresetsrc" "$DOTFILES_DIR/config/klassy/windecopresetsrc"
copy_file "$USER_HOME/.config/systemd/user/klassy-gtk-fix.path" "$DOTFILES_DIR/config/systemd/user/klassy-gtk-fix.path"
copy_file "$USER_HOME/.config/systemd/user/klassy-gtk-fix.service" "$DOTFILES_DIR/config/systemd/user/klassy-gtk-fix.service"
copy_file "$USER_HOME/.config/xsettingsd/xsettingsd.conf" "$DOTFILES_DIR/config/xsettingsd/xsettingsd.conf"
copy_file "$USER_HOME/.config/fish/config.fish" "$DOTFILES_DIR/config/fish/config.fish"

# Directories & assets
copy_dir "$USER_HOME/.config/gtk-3.0" "$DOTFILES_DIR/config/gtk-3.0"
copy_dir "$USER_HOME/.config/gtk-4.0" "$DOTFILES_DIR/config/gtk-4.0"
copy_dir "$USER_HOME/.config/fastfetch" "$DOTFILES_DIR/config/fastfetch"
copy_dir "$USER_HOME/.config/environment.d" "$DOTFILES_DIR/config/environment.d"

# 2. Local bin & share
copy_file "$USER_HOME/.local/lib/qt6/plugins/plasma/applets/org.kde.plasma.taskmanager.so" "$DOTFILES_DIR/local/lib/qt6/plugins/plasma/applets/org.kde.plasma.taskmanager.so"
copy_file "$USER_HOME/.local/bin/klassy-gtk-fix.sh" "$DOTFILES_DIR/local/bin/klassy-gtk-fix.sh"
copy_file "$USER_HOME/.local/bin/fastfetch" "$DOTFILES_DIR/local/bin/fastfetch"
copy_file "$USER_HOME/.local/bin/ff" "$DOTFILES_DIR/local/bin/ff"
copy_file "$USER_HOME/.local/share/icons/Papirus-Apps-Only/index.theme" "$DOTFILES_DIR/local/share/icons/Papirus-Apps-Only/index.theme"
copy_file "$USER_HOME/.local/share/plasma_icons/Alacritty.desktop" "$DOTFILES_DIR/local/share/plasma_icons/Alacritty.desktop"
copy_file "$USER_HOME/.local/share/applications/Alacritty.desktop" "$DOTFILES_DIR/local/share/applications/Alacritty.desktop"

copy_dir "$USER_HOME/.local/share/klassy-gtk-fixes" "$DOTFILES_DIR/local/share/klassy-gtk-fixes"
copy_dir "$USER_HOME/.local/share/plasma/plasmoids/io.github.kevinbudz.quickclock" "$DOTFILES_DIR/local/share/plasma/plasmoids/io.github.kevinbudz.quickclock"
copy_dir "$USER_HOME/.local/share/plasma/desktoptheme/custom-dock" "$DOTFILES_DIR/local/share/plasma/desktoptheme/custom-dock"
copy_dir "$USER_HOME/.local/share/fonts" "$DOTFILES_DIR/local/share/fonts"
copy_dir "$USER_HOME/.local/share/wallpapers" "$DOTFILES_DIR/wallpapers"

# 3. SDDM theme (Pear - default)
if [[ -d "$USER_HOME/.local/share/sddm/themes/pear" ]]; then
    copy_dir "$USER_HOME/.local/share/sddm/themes/pear" "$DOTFILES_DIR/sddm/pear"
elif [[ -d "/usr/share/sddm/themes/pear" ]]; then
    copy_dir "/usr/share/sddm/themes/pear" "$DOTFILES_DIR/sddm/pear"
fi

# 3b. Firefox about:config (user.js) + userChrome.css
# Detect Firefox base dirs (standard + XDG) and export from the profile that has customisation
for base in "$USER_HOME/.mozilla/firefox" "$USER_HOME/.config/mozilla/firefox"; do
    [[ -d "$base" ]] || continue
    if [[ -f "$base/profiles.ini" ]]; then
        while IFS= read -r profile_path; do
            [[ -z "$profile_path" ]] && continue
            if [[ "$profile_path" = /* ]]; then
                profile_dir="$profile_path"
            else
                profile_dir="$base/$profile_path"
            fi
            [[ -d "$profile_dir" ]] || continue
            # Export if profile contains custom Firefox tweaks
            if [[ -f "$profile_dir/user.js" ]]; then
                copy_file "$profile_dir/user.js" "$DOTFILES_DIR/firefox/user.js"
            fi
            if [[ -f "$profile_dir/chrome/userChrome.css" ]]; then
                mkdir -p "$DOTFILES_DIR/firefox/chrome"
                cp -f "$profile_dir/chrome/userChrome.css" "$DOTFILES_DIR/firefox/chrome/userChrome.css"
                echo "  [FILE] $profile_dir/chrome/userChrome.css -> firefox/chrome/userChrome.css"
            fi
        done < <(grep -E "^Path=" "$base/profiles.ini" | cut -d= -f2-)
    fi
done

# 4. Clean up any leftover cache / backup files
find "$DOTFILES_DIR" -type f \( -name "*.bak" -o -name "*.bak.*" -o -name ".uuid" -o -name "icon-theme.cache" \) -delete

# 5. Sanitize HOME path placeholders across config files
echo "==> Sanitizing absolute home paths..."
while IFS= read -r file; do
    if file "$file" | grep -q 'text'; then
        sed -i "s|$USER_HOME|__HOME__|g" "$file"
    fi
done < <(find "$DOTFILES_DIR/config" "$DOTFILES_DIR/local" "$DOTFILES_DIR/firefox" "$DOTFILES_DIR/sddm" -type f 2>/dev/null)

echo "=========================================================="
echo " Export complete! All current settings synced to dotfiles."
echo "=========================================================="
