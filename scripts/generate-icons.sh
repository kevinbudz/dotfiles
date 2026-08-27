#!/usr/bin/env bash
# Generate Papirus-Apps-Only icon theme overlay
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

DEST_DIR="${HOME}/.local/share/icons/Papirus-Apps-Only"
PAPIRUS_SYS="/usr/share/icons/Papirus"
PAPIRUS_USER="${HOME}/.local/share/icons/Papirus"

if [[ -d "$PAPIRUS_SYS" ]]; then
    PAPIRUS_SRC="$PAPIRUS_SYS"
elif [[ -d "$PAPIRUS_USER" ]]; then
    PAPIRUS_SRC="$PAPIRUS_USER"
else
    echo "Warning: Papirus icon theme not found at $PAPIRUS_SYS or $PAPIRUS_USER."
    echo "Please install papirus-icon-theme (e.g. sudo pacman -S papirus-icon-theme)."
    exit 1
fi

echo "Building Papirus-Apps-Only icon theme in $DEST_DIR..."
mkdir -p "$DEST_DIR"

# Copy index.theme
THEME_FILE="$DOTFILES_DIR/local/share/icons/Papirus-Apps-Only/index.theme"
if [[ -f "$THEME_FILE" ]]; then
    cp -f "$THEME_FILE" "$DEST_DIR/index.theme"
else
    echo "Error: index.theme not found at $THEME_FILE"
    exit 1
fi

SIZES=("16x16" "22x22" "24x24" "32x32" "42x42" "48x48" "64x64" "84x84" "96x96" "128x128")

for size in "${SIZES[@]}"; do
    mkdir -p "$DEST_DIR/$size"
    for cat in apps places; do
        src="$PAPIRUS_SRC/$size/$cat"
        dst="$DEST_DIR/$size/$cat"
        if [[ -d "$src" ]]; then
            rm -rf "$dst"
            ln -snf "$src" "$dst"
        fi
    done

    # Create @2x symlink
    ln -snf "$size" "$DEST_DIR/${size}@2x"
done

# Update cache if gtk-update-icon-cache is available
if command -v gtk-update-icon-cache &>/dev/null; then
    gtk-update-icon-cache -f -q -t "$DEST_DIR" 2>/dev/null || true
fi

echo "Papirus-Apps-Only icon theme successfully created."
