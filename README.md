# Kevin's KDE Plasma 6 Dotfiles & Setup

A clean, modern, macOS-inspired KDE Plasma 6 setup featuring **Klassy** window decorations with material-style controls, rounded window corners, a sleek top status bar (AppGrid launcher, Quickbar Global Menu, System Tray, QuickClock), an auto-hiding bottom floating dock, and the **Papirus-Apps-Only** hybrid icon theme.

---

## 🎨 Look & Feel Overview

| Component | Configuration / Choice |
|---|---|
| **Desktop Environment** | KDE Plasma 6 |
| **Window Decoration** | [Klassy](https://github.com/paulmcauley/klassy) (StyleMaterial, Full Height Rectangle buttons, 8px corner radius) |
| **Window Effects** | KWin Rounded Corners (`kwin-effect-rounded-corners-git`, 8px radius) |
| **Color Scheme & Theme** | Breeze Dark (Customized dark palette `#202224` / `#292c30`, `#3daee9` accent) |
| **Top Panel** | 30px height, fixed width, always visible: AppGrid Launcher ➔ Spacers ➔ Quickbar Global Menu ➔ System Tray ➔ QuickClock |
| **Bottom Dock** | 60px floating dock (length mode 1 / fit content, dodge windows / auto-hide): Virtual Desktop Pager + Icon-only Task Manager |
| **Icon Theme** | `Papirus-Apps-Only` (Papirus for applications & folders + Breeze-Dark/Klassy-Dark for panel tray & system UI) |
| **Typography** | Google Sans (Variable), Noto Sans (Bold for panel clock), slight hinting, subpixel antialiasing |
| **Terminal** | Alacritty (6px padding, dynamic padding enabled) + Fish Shell |
| **SDDM Login Theme** | `Pear` / `Sonoma` macOS-inspired greeter |
| **GTK Integration** | Real-time Klassy decoration sync service (`klassy-gtk-fix.path` + `klassy-gtk-fix.service`) ensuring GTK 3 & 4 apps match KWin titlebars |

---

## 🚀 Quick Start / Installation

Clone the repository and run the installation script:

```bash
git clone https://github.com/kevinbudz/dotfiles.git ~/Desktop/dotfiles
cd ~/Desktop/dotfiles
./install.sh
```

### Installation Options

```bash
./install.sh [options]

Options:
  -a, --all            Install everything (packages, assets, configs, themes) [default]
  -c, --configs-only   Only import dotfiles and configs (skip package manager steps)
  -p, --packages-only  Only install system and AUR packages
  -s, --sddm           Install and enable the Pear/Sonoma SDDM theme (requires sudo)
  --no-backup          Skip creating a timestamped backup of existing ~/.config files
  --no-reload          Skip live-reloading Plasma 6 and KWin after installation
  -h, --help           Show help message
```

---

## 📦 Packages & Dependencies

The installer automatically installs packages via `pacman` and `paru` / `yay` on Arch Linux and CachyOS:

### Official Packages
* `papirus-icon-theme`
* `alacritty`
* `fontconfig`
* `fish`
* `noto-fonts`, `noto-fonts-cjk`, `noto-fonts-emoji`
* `ttf-meslo-nerd`
* `xsettingsd`
* `appmenu-gtk-module`
* `rsync`

### AUR Packages
* `plasma6-applets-appgrid` - Fullscreen / grid application launcher
* `plasma6-applets-quickbar` - Global menu widget for top panel
* `kwin-effect-rounded-corners-git` - Rounded corners shader for KWin 6
* `klassy` (or `klassy-bin` / `klassy-git`) - Window decorations and application style

---

## 📂 Repository Structure

```
.
├── install.sh                  # Main installer and settings importer
├── export.sh                   # Exports live KDE settings into the repo
├── README.md
├── config/                     # Target: ~/.config/
│   ├── alacritty/              # Alacritty terminal settings
│   ├── autostart/              # Autostart entries (Klassy GTK sync daemon)
│   ├── fish/                   # Fish shell config
│   ├── fontconfig/             # Subpixel antialiasing & slanting rules
│   ├── gtk-3.0/ & gtk-4.0/     # GTK themes, colors & titlebar button assets
│   ├── klassy/                 # Klassy window decoration configuration
│   ├── systemd/user/           # User systemd path & service units for GTK fix
│   ├── xsettingsd/             # Xsettings daemon config
│   ├── breezerc                # Breeze style overrides
│   ├── dolphinrc               # Dolphin file manager view configuration
│   ├── kdeglobals              # Global color scheme, fonts & icon settings
│   ├── kglobalshortcutsrc      # Global desktop and window manager shortcuts
│   ├── kwinrc                  # KWin effects, rounded corners & tiling rules
│   ├── plasma-org.kde.plasma.desktop-appletsrc  # Panels, widgets & dock layout
│   ├── plasmarc                # Plasma desktop theme settings
│   ├── plasmashellrc           # Panel dimensions, floating & visibility states
│   └── spectaclerc             # Spectacle screenshot tool preferences
├── local/                      # Target: ~/.local/
│   ├── bin/
│   │   └── klassy-gtk-fix.sh   # Re-applies Klassy GTK fixes when overwritten
│   └── share/
│       ├── fonts/              # Google Sans variable font families
│       ├── klassy-gtk-fixes/   # Fixed CSS & assets for GTK headerbars
│       ├── icons/              # Papirus-Apps-Only icon theme definition
│       └── plasma/plasmoids/
│           └── io.github.kevinbudz.quickclock/  # Custom QuickClock widget
├── sddm/                       # SDDM greeter themes (Pear & Sonoma)
├── wallpapers/                 # Desktop wallpapers
└── scripts/
    ├── apply-plasma-theme.sh   # Live-reloads Plasma 6, KWin & GTK caches
    └── generate-icons.sh       # Builds Papirus-Apps-Only icon theme symlinks
```

---

## 🔄 Updating / Exporting Changes

Whenever you customize your KDE Plasma desktop (change panel items, widgets, shortcuts, or colors), you can synchronize your current configuration back into this repository with a single command:

```bash
./export.sh
```

This script:
1. Copies all relevant settings from `~/.config`, `~/.local/share`, `~/.local/bin`, and SDDM.
2. Strips temporary and backup files (`*.bak`, cache files).
3. Automatically sanitizes hardcoded paths (`/home/username`) into portable placeholders (`__HOME__`).

---

## 🖥️ SDDM Login Theme Setup

To install and activate the Pear SDDM theme:

```bash
./install.sh --sddm
```

Or manually:
```bash
sudo cp -r sddm/pear /usr/share/sddm/themes/
sudo mkdir -p /etc/sddm.conf.d
echo -e "[Theme]\nCurrent=pear" | sudo tee /etc/sddm.conf.d/kde_settings.conf
```

---

## 🛠️ Manual Reload Commands

If you ever need to manually reload settings without logging out:

* **Reload KWin**: `qdbus6 org.kde.KWin /KWin reconfigure`
* **Reload Plasma Shell**: `systemctl --user restart plasma-plasmashell`
* **Reload Font Cache**: `fc-cache -f ~/.local/share/fonts`
* **Rebuild KDE Sycoca**: `kbuildsycoca6 --noincremental`
* **Run GTK Decoration Fix**: `~/.local/bin/klassy-gtk-fix.sh`
