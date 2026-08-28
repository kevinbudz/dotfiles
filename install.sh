#!/usr/bin/env bash
# install.sh - Automated installer and settings importer for KDE Plasma 6 setup
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_HOME="${HOME}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="${USER_HOME}/.dotfiles-backup-${TIMESTAMP}"

# Color output
BOLD=$'\e[1m'
GREEN=$'\e[1;32m'
BLUE=$'\e[1;34m'
YELLOW=$'\e[1;33m'
RED=$'\e[1;31m'
RESET=$'\e[0m'

log_info()  { echo -e "${BLUE}${BOLD}[INFO]${RESET} $*"; }
log_ok()    { echo -e "${GREEN}${BOLD}[OK]${RESET} $*"; }
log_warn()  { echo -e "${YELLOW}${BOLD}[WARN]${RESET} $*"; }
log_err()   { echo -e "${RED}${BOLD}[ERROR]${RESET} $*"; }

# Flags
DO_PACKAGES=true
DO_CONFIGS=true
DO_BACKUP=true
DO_RELOAD=true
DO_SDDM=false

usage() {
    echo -e "${BOLD}Usage:${RESET} $(basename "$0") [options]

${BOLD}Options:${RESET}
  -a, --all            Install everything (packages, assets, configs, themes) [default]
  -c, --configs-only   Only import dotfiles and configs (skip package installation)
  -p, --packages-only  Only install system/AUR packages
  -s, --sddm           Install and configure Pear/Sonoma SDDM theme (requires sudo)
  --no-backup          Do not create a backup of existing configurations
  --no-reload          Do not reload Plasma/KWin after importing
  -h, --help           Show this help message
"
    exit 0
}

# Parse CLI arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -a|--all)
            DO_PACKAGES=true
            DO_CONFIGS=true
            ;;
        -c|--configs-only|--no-packages)
            DO_PACKAGES=false
            DO_CONFIGS=true
            ;;
        -p|--packages-only)
            DO_PACKAGES=true
            DO_CONFIGS=false
            ;;
        -s|--sddm)
            DO_SDDM=true
            ;;
        --no-backup)
            DO_BACKUP=false
            ;;
        --no-reload)
            DO_RELOAD=false
            ;;
        -h|--help)
            usage
            ;;
        *)
            log_err "Unknown option: $1"
            usage
            ;;
    esac
    shift
done

echo -e "${BOLD}==========================================================${RESET}"
echo -e "${BOLD}         KDE Plasma 6 Dotfiles & Theme Installer          ${RESET}"
echo -e "${BOLD}==========================================================${RESET}"

# 1. Package Installation
install_packages() {
    log_info "Detecting distribution and package manager..."
    if command -v pacman &>/dev/null; then
        log_info "Arch/CachyOS detected."

        # Detect AUR helper
        AUR_HELPER=""
        if command -v paru &>/dev/null; then
            AUR_HELPER="paru"
        elif command -v yay &>/dev/null; then
            AUR_HELPER="yay"
        fi

        PACMAN_PKGS=(
            papirus-icon-theme
            alacritty
            fontconfig
            fish
            noto-fonts
            noto-fonts-cjk
            noto-fonts-emoji
            ttf-meslo-nerd
            xsettingsd
            appmenu-gtk-module
            rsync
        )

        AUR_PKGS=(
            plasma6-applets-appgrid
            plasma6-applets-quickbar
            kwin-effect-rounded-corners-git
            klassy
        )

        log_info "Installing official repository packages via pacman..."
        sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}" || log_warn "Some pacman packages may have failed to install."

        if [[ -n "$AUR_HELPER" ]]; then
            log_info "Installing AUR packages via $AUR_HELPER..."
            "$AUR_HELPER" -S --needed --noconfirm "${AUR_PKGS[@]}" || log_warn "Some AUR packages may have failed to install. Continuing..."
        else
            log_warn "Neither 'yay' nor 'paru' was found. Please install AUR helper or manually install: ${AUR_PKGS[*]}"
        fi
    else
        log_warn "Non-pacman distribution detected. Please ensure KDE Plasma 6, Klassy, and Papirus are installed."
    fi
}

if [[ "$DO_PACKAGES" == "true" ]]; then
    install_packages
fi

if [[ "$DO_CONFIGS" == "false" ]]; then
    log_ok "Package installation step finished."
    exit 0
fi

# 2. Backup existing configurations
if [[ "$DO_BACKUP" == "true" ]]; then
    log_info "Creating backup of current configurations in: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"

    BACKUP_ITEMS=(
        ".config/kdeglobals"
        ".config/kwinrc"
        ".config/kwinrulesrc"
        ".config/plasma-org.kde.plasma.desktop-appletsrc"
        ".config/plasmarc"
        ".config/plasmashellrc"
        ".config/kglobalshortcutsrc"
        ".config/klassy"
        ".config/breezerc"
        ".config/gtk-3.0"
        ".config/gtk-4.0"
        ".config/fontconfig"
        ".config/alacritty"
        ".config/fish"
        ".config/dolphinrc"
        ".config/kscreenlockerrc"
        ".config/spectaclerc"
        ".config/xsettingsd"
        ".local/share/fonts"
        ".local/share/klassy-gtk-fixes"
        ".local/share/plasma/plasmoids/io.github.kevinbudz.quickclock"
    )

    for item in "${BACKUP_ITEMS[@]}"; do
        src="$USER_HOME/$item"
        if [[ -e "$src" ]]; then
            dst="$BACKUP_DIR/$item"
            mkdir -p "$(dirname "$dst")"
            cp -r "$src" "$dst"
        fi
    done
    log_ok "Backup created successfully."
fi

# 3. Deploy assets and local files
log_info "Deploying wallpapers..."
mkdir -p "$USER_HOME/.local/share/wallpapers"
cp -f "$DOTFILES_DIR/wallpapers/"* "$USER_HOME/.local/share/wallpapers/" 2>/dev/null || true

log_info "Deploying fonts..."
mkdir -p "$USER_HOME/.local/share/fonts"
cp -f "$DOTFILES_DIR/local/share/fonts/"*.ttf "$USER_HOME/.local/share/fonts/" 2>/dev/null || true
if command -v fc-cache &>/dev/null; then
    fc-cache -f "$USER_HOME/.local/share/fonts" 2>/dev/null || true
fi

log_info "Deploying Klassy GTK fix script and assets..."
mkdir -p "$USER_HOME/.local/bin"
mkdir -p "$USER_HOME/.local/share/klassy-gtk-fixes"
cp -f "$DOTFILES_DIR/local/bin/klassy-gtk-fix.sh" "$USER_HOME/.local/bin/klassy-gtk-fix.sh"
chmod +x "$USER_HOME/.local/bin/klassy-gtk-fix.sh"
cp -rf "$DOTFILES_DIR/local/share/klassy-gtk-fixes/"* "$USER_HOME/.local/share/klassy-gtk-fixes/" 2>/dev/null || true

log_info "Deploying QuickClock plasmoid..."
mkdir -p "$USER_HOME/.local/share/plasma/plasmoids/io.github.kevinbudz.quickclock"
cp -rf "$DOTFILES_DIR/local/share/plasma/plasmoids/io.github.kevinbudz.quickclock/"* "$USER_HOME/.local/share/plasma/plasmoids/io.github.kevinbudz.quickclock/"

log_info "Deploying application desktop launchers..."
mkdir -p "$USER_HOME/.local/share/plasma_icons"
mkdir -p "$USER_HOME/.local/share/applications"
if [[ -f "$DOTFILES_DIR/local/share/plasma_icons/Alacritty.desktop" ]]; then
    cp -f "$DOTFILES_DIR/local/share/plasma_icons/Alacritty.desktop" "$USER_HOME/.local/share/plasma_icons/Alacritty.desktop"
    chmod +x "$USER_HOME/.local/share/plasma_icons/Alacritty.desktop"
fi
if [[ -f "$DOTFILES_DIR/local/share/applications/Alacritty.desktop" ]]; then
    cp -f "$DOTFILES_DIR/local/share/applications/Alacritty.desktop" "$USER_HOME/.local/share/applications/Alacritty.desktop"
fi

# 4. Generate Papirus-Apps-Only icon theme
log_info "Configuring Papirus-Apps-Only icon theme..."
"$DOTFILES_DIR/scripts/generate-icons.sh" || log_warn "Icon generator had warnings."

# 5. Deploy and template configuration files
log_info "Importing KDE Plasma configuration files..."
mkdir -p "$USER_HOME/.config"

# Recursively copy and template config files
while IFS= read -r src_file; do
    rel_path="${src_file#$DOTFILES_DIR/config/}"
    dst_file="$USER_HOME/.config/$rel_path"

    mkdir -p "$(dirname "$dst_file")"

    # If text file, replace __HOME__ placeholder with active user's $HOME
    if file "$src_file" | grep -q 'text'; then
        sed "s|__HOME__|$USER_HOME|g" "$src_file" > "$dst_file"
    else
        cp -f "$src_file" "$dst_file"
    fi
done < <(find "$DOTFILES_DIR/config" -type f)

# 6. Set up Systemd User Service for Klassy GTK fix
log_info "Configuring systemd user services..."
mkdir -p "$USER_HOME/.config/systemd/user"
if command -v systemctl &>/dev/null; then
    systemctl --user daemon-reload 2>/dev/null || true
    systemctl --user enable --now klassy-gtk-fix.path 2>/dev/null || true
fi

# Run Klassy GTK fix initially
"$USER_HOME/.local/bin/klassy-gtk-fix.sh" 2>/dev/null || true

# 7. Optional SDDM Theme installation
if [[ "$DO_SDDM" == "true" ]]; then
    log_info "Installing SDDM themes (requires sudo)..."
    if [[ -d "$DOTFILES_DIR/sddm/pear" ]]; then
        sudo mkdir -p /usr/share/sddm/themes/pear
        sudo cp -rf "$DOTFILES_DIR/sddm/pear/"* /usr/share/sddm/themes/pear/
    fi
    if [[ -d "$DOTFILES_DIR/sddm/sonoma" ]]; then
        sudo mkdir -p /usr/share/sddm/themes/sonoma
        sudo cp -rf "$DOTFILES_DIR/sddm/sonoma/"* /usr/share/sddm/themes/sonoma/
    fi

    # Set pear as current theme in /etc/sddm.conf.d/kde_settings.conf or /etc/sddm.conf
    if [[ -d /etc/sddm.conf.d ]]; then
        sudo tee /etc/sddm.conf.d/kde_settings.conf >/dev/null <<SDDM_CONF
[Theme]
Current=pear
SDDM_CONF
    fi
    log_ok "SDDM themes installed successfully."
fi

# 8. Reload Plasma & KWin
if [[ "$DO_RELOAD" == "true" ]]; then
    log_info "Reloading Plasma 6 and KWin configuration..."
    "$DOTFILES_DIR/scripts/apply-plasma-theme.sh" || log_warn "Live reload completed with minor notices."
fi

echo -e "\n${GREEN}${BOLD}==========================================================${RESET}"
echo -e "${GREEN}${BOLD}   KDE Plasma setup and settings successfully imported!   ${RESET}"
echo -e "${GREEN}${BOLD}==========================================================${RESET}"
if [[ "$DO_BACKUP" == "true" ]]; then
    echo -e "Your previous configuration was safely backed up to:\n  ${YELLOW}$BACKUP_DIR${RESET}\n"
fi
echo -e "Enjoy your desktop! If you ever update settings, run ${BOLD}./export.sh${RESET} to sync back.\n"
