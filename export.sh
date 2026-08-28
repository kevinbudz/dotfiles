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
copy_file "$USER_HOME/.config/fish/config.fish" "$DOTFILES_DIR/config/fish/config.fish"
copy_file "$USER_HOME/.config/fontconfig/fonts.conf" "$DOTFILES_DIR/config/fontconfig/fonts.conf"
copy_file "$USER_HOME/.config/kdedefaults/kdeglobals" "$DOTFILES_DIR/config/kdedefaults/kdeglobals"
copy_file "$USER_HOME/.config/klassy/klassyrc" "$DOTFILES_DIR/config/klassy/klassyrc"
copy_file "$USER_HOME/.config/klassy/windecopresetsrc" "$DOTFILES_DIR/config/klassy/windecopresetsrc"
copy_file "$USER_HOME/.config/systemd/user/klassy-gtk-fix.path" "$DOTFILES_DIR/config/systemd/user/klassy-gtk-fix.path"
copy_file "$USER_HOME/.config/systemd/user/klassy-gtk-fix.service" "$DOTFILES_DIR/config/systemd/user/klassy-gtk-fix.service"
copy_file "$USER_HOME/.config/xsettingsd/xsettingsd.conf" "$DOTFILES_DIR/config/xsettingsd/xsettingsd.conf"

# GTK configs & assets
copy_dir "$USER_HOME/.config/gtk-3.0" "$DOTFILES_DIR/config/gtk-3.0"
copy_dir "$USER_HOME/.config/gtk-4.0" "$DOTFILES_DIR/config/gtk-4.0"

# 2. Local bin & share
copy_file "$USER_HOME/.local/bin/klassy-gtk-fix.sh" "$DOTFILES_DIR/local/bin/klassy-gtk-fix.sh"
copy_file "$USER_HOME/.local/share/icons/Papirus-Apps-Only/index.theme" "$DOTFILES_DIR/local/share/icons/Papirus-Apps-Only/index.theme"
copy_file "$USER_HOME/.local/share/plasma_icons/Alacritty.desktop" "$DOTFILES_DIR/local/share/plasma_icons/Alacritty.desktop"
copy_file "$USER_HOME/.local/share/applications/Alacritty.desktop" "$DOTFILES_DIR/local/share/applications/Alacritty.desktop"

copy_dir "$USER_HOME/.local/share/fonts" "$DOTFILES_DIR/local/share/fonts"
copy_dir "$USER_HOME/.local/share/klassy-gtk-fixes" "$DOTFILES_DIR/local/share/klassy-gtk-fixes"
copy_dir "$USER_HOME/.local/share/plasma/plasmoids/io.github.kevinbudz.quickclock" "$DOTFILES_DIR/local/share/plasma/plasmoids/io.github.kevinbudz.quickclock"

# 3. SDDM themes (if present)
if [[ -d "$USER_HOME/.local/share/sddm/themes/pear" ]]; then
    copy_dir "$USER_HOME/.local/share/sddm/themes/pear" "$DOTFILES_DIR/sddm/pear"
fi
if [[ -d "$USER_HOME/.local/share/sddm/themes/sonoma" ]]; then
    copy_dir "$USER_HOME/.local/share/sddm/themes/sonoma" "$DOTFILES_DIR/sddm/sonoma"
fi

# 4. Clean up any leftover cache / backup files
find "$DOTFILES_DIR" -type f \( -name "*.bak" -o -name "*.bak.*" -o -name ".uuid" -o -name "icon-theme.cache" \) -delete

# 5. Sanitize HOME path placeholders across config files
echo "==> Sanitizing absolute home paths..."
while IFS= read -r file; do
    if file "$file" | grep -q 'text'; then
        sed -i "s|$USER_HOME|__HOME__|g" "$file"
    fi
done < <(find "$DOTFILES_DIR/config" "$DOTFILES_DIR/local" -type f)

echo "=========================================================="
echo " Export complete! All current settings synced to dotfiles."
echo "=========================================================="
