#!/usr/bin/env bash
# Generate Papirus-Apps-Only icon theme overlay
# Concrete approach: only Papirus for real app launcher icons + plasma-symbolic + folders,
# everything else (system settings, tray, status) stays Breeze via Inherits
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
shopt -s nullglob

# --- Clean up old directory symlinks (from previous versions that linked whole Papirus dirs) ---
for size in "${SIZES[@]}"; do
    for cat in apps places panel status; do
        dst="$DEST_DIR/$size/$cat"
        if [[ -L "$dst" ]]; then
            rm -f "$dst"
        fi
    done
    rmdir "$DEST_DIR/$size/symbolic" 2>/dev/null || true
    rm -f "$DEST_DIR/${size}@2x" 2>/dev/null || true
done

# --- Build allowlist of app icons that should be Papirus ---
TMP_ALLOW=$(mktemp)
trap 'rm -f "$TMP_ALLOW" "${TMP_ALLOW}.tmp" 2>/dev/null || true' EXIT

# 1) Collect Icon= from application desktop files (exclude kcm and systemsettings)
# Use pipefail-safe: final || true prevents set -e exit on grep no-match
{
    find /usr/share/applications -maxdepth 3 -type f -name "*.desktop" \
        ! -name "kcm_*.desktop" \
        ! -name "systemsettings.desktop" \
        ! -name "kdesystemsettings.desktop" \
        ! -name "org.kde.systemsettings.desktop" 2>/dev/null
    find "${HOME}/.local/share/applications" -maxdepth 3 -type f -name "*.desktop" 2>/dev/null || true
} | xargs -r grep -h "^Icon=" 2>/dev/null | cut -d= -f2 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v "/" | sort -u > "$TMP_ALLOW" || true

# Ensure file exists even if pipeline produced nothing
touch "$TMP_ALLOW"

# 2) Blacklist: system UI icons that should stay Breeze even if they appear as app Icon
BLACKLIST=(
    "klipper" "org.kde.klipper"
    "kmix" "org.kde.kmix"
    "plasmashell" "org.kde.plasmashell"
    "systemsettings" "kdesystemsettings" "org.kde.systemsettings"
    "preferences-system"
    "system-run"
)

# 3) Always include plasma-symbolic as explicit exception (KDE launcher in top panel)
echo "plasma-symbolic" >> "$TMP_ALLOW"

# Deduplicate and filter blacklist
for bad in "${BLACKLIST[@]}"; do
    grep -v -x -F "$bad" "$TMP_ALLOW" > "${TMP_ALLOW}.tmp" 2>/dev/null || true
    mv "${TMP_ALLOW}.tmp" "$TMP_ALLOW" 2>/dev/null || true
    touch "$TMP_ALLOW"
done
# Also filter preferences-system* and system-* that are likely from kcm but might have slipped through
grep -v -E "^(preferences-system|system-)" "$TMP_ALLOW" > "${TMP_ALLOW}.tmp" 2>/dev/null || true
mv "${TMP_ALLOW}.tmp" "$TMP_ALLOW" 2>/dev/null || true
touch "$TMP_ALLOW"
sort -u "$TMP_ALLOW" -o "$TMP_ALLOW" 2>/dev/null || true

echo "  allowlist: $(wc -l < "$TMP_ALLOW") app icons (filtered)"

# --- Populate apps with file-level symlinks for allowlisted icons ---
for size in "${SIZES[@]}"; do
    src_apps="$PAPIRUS_SRC/$size/apps"
    dst_apps="$DEST_DIR/$size/apps"
    mkdir -p "$dst_apps"
    find "$dst_apps" -type l ! -exec test -e {} \; -delete 2>/dev/null || true

    if [[ -d "$src_apps" ]]; then
        while IFS= read -r icon; do
            [[ -z "$icon" ]] && continue
            for ext in svg png xpm; do
                src_file="$src_apps/${icon}.${ext}"
                dst_file="$dst_apps/${icon}.${ext}"
                if [[ -f "$src_file" ]]; then
                    ln -snf "$src_file" "$dst_file"
                    break
                fi
            done
        done < "$TMP_ALLOW"
    fi
    # Remove previously symlinked blacklist items that should be Breeze
    for dst_file in "$dst_apps"/*.svg "$dst_apps"/*.png "$dst_apps"/*.xpm; do
        [[ -e "$dst_file" ]] || continue
        base=$(basename "$dst_file")
        name="${base%.*}"
        # Remove if in blacklist or matches preferences-system* / system-*
        should_remove=false
        for bad in "${BLACKLIST[@]}"; do
            if [[ "$name" == "$bad" ]]; then
                should_remove=true
                break
            fi
        done
        if [[ "$name" == preferences-system* ]] || [[ "$name" == system-* ]]; then
            should_remove=true
        fi
        if [[ "$should_remove" == true ]]; then
            rm -f "$dst_file"
        fi
        # Also remove if name not in allowlist and is a blacklist pattern? For safety, if file exists but name not in allowlist, remove it
        # (ensures stale Papirus icons like klipper don't linger)
        if ! grep -qx -F "$name" "$TMP_ALLOW" 2>/dev/null; then
            # Only remove if it's one of the system-like names; keep allowlisted app icons
            if [[ "$name" == klipper* ]] || [[ "$name" == kmix* ]] || [[ "$name" == preferences-* ]] || [[ "$name" == system-* ]]; then
                rm -f "$dst_file" 2>/dev/null || true
            fi
        fi
    done
done

# --- Populate places with folder icons only (concrete) ---
for size in "${SIZES[@]}"; do
    src_places="$PAPIRUS_SRC/$size/places"
    dst_places="$DEST_DIR/$size/places"
    mkdir -p "$dst_places"
    find "$dst_places" -type l ! -exec test -e {} \; -delete 2>/dev/null || true
    if [[ -d "$src_places" ]]; then
        for src_file in "$src_places"/folder*.svg "$src_places"/folder*.png "$src_places"/user-*.svg "$src_places"/user-*.png "$src_places"/inode-directory.svg "$src_places"/desktop.svg; do
            [[ -e "$src_file" ]] || continue
            base=$(basename "$src_file")
            ln -snf "$src_file" "$dst_places/$base" 2>/dev/null || true
        done
        for name in folder desktop user-home inode-directory; do
            for ext in svg png; do
                src_file="$src_places/${name}.${ext}"
                if [[ -f "$src_file" ]]; then
                    ln -snf "$src_file" "$dst_places/${name}.${ext}" 2>/dev/null || true
                fi
            done
        done
    fi
    # Remove Papirus network-workgroup etc that should be Breeze
    rm -f "$dst_places/network-workgroup.svg" "$dst_places/network-workgroup.png" 2>/dev/null || true
    # Note: folder-network.svg etc are folder icons, keep them; only remove bare network-*
    for f in "$dst_places"/network-*.svg "$dst_places"/network-*.png; do
        [[ -e "$f" ]] || continue
        base=$(basename "$f")
        # Keep folder-network* but remove network-workgroup
        if [[ "$base" == network-* ]]; then
            rm -f "$f"
        fi
    done
done

# --- Ensure stale panel/status dirs are gone (Breeze) ---
for size in "${SIZES[@]}"; do
    for cat in panel status; do
        rm -rf "$DEST_DIR/$size/$cat" 2>/dev/null || true
    done
done

# --- Symbolic exception: plasma-symbolic ---
for size in "${SIZES[@]}"; do
    # Clean up old directory symlink that would shadow file symlink
    if [[ -L "$DEST_DIR/$size/symbolic/apps" ]]; then
        rm -f "$DEST_DIR/$size/symbolic/apps"
    fi
    if [[ -L "$DEST_DIR/$size/symbolic" && ! -d "$DEST_DIR/$size/symbolic" ]]; then
        rm -f "$DEST_DIR/$size/symbolic"
    fi
    sym_src="$PAPIRUS_SRC/$size/symbolic/apps/plasma-symbolic.svg"
    sym_dst="$DEST_DIR/$size/symbolic/apps/plasma-symbolic.svg"
    if [[ -f "$sym_src" ]]; then
        mkdir -p "$(dirname "$sym_dst")"
        # Ensure parent is real dir, not symlink
        if [[ -L "$(dirname "$sym_dst")" ]]; then
            rm -f "$(dirname "$sym_dst")"
            mkdir -p "$(dirname "$sym_dst")"
        fi
        ln -snf "$sym_src" "$sym_dst"
    else
        rm -f "$sym_dst" 2>/dev/null || true
    fi
    if [[ -d "$DEST_DIR/$size/symbolic/apps" ]]; then
        find "$DEST_DIR/$size/symbolic/apps" -type l ! -name "plasma-symbolic.svg" -delete 2>/dev/null || true
        rmdir "$DEST_DIR/$size/symbolic/apps" 2>/dev/null || true
        rmdir "$DEST_DIR/$size/symbolic" 2>/dev/null || true
    fi
done

# --- Recreate @2x symlinks ---
for size in "${SIZES[@]}"; do
    ln -snf "$size" "$DEST_DIR/${size}@2x" 2>/dev/null || true
done

# Update cache
if command -v gtk-update-icon-cache &>/dev/null; then
    gtk-update-icon-cache -f -q -t "$DEST_DIR" 2>/dev/null || true
fi

echo "Papirus-Apps-Only icon theme successfully created."
echo "  -> Concrete: $(find "$DEST_DIR" -type l 2>/dev/null | wc -l) file symlinks (apps allowlist + folders + plasma-symbolic), rest -> Breeze"
