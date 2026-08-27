# Pear SDDM Theme

A clean SDDM login theme for **KDE Plasma** with a centered clock, password input, user avatar, wallpaper sync, and a 32px top bar with a session dropdown.

## Install

SDDM runs as the `sddm` user and only loads themes from **`/usr/share/sddm/themes`** (see `ThemeDir` in `sddm --example-config`). A copy under `~/.local/share/sddm/themes` works for **test mode** and for the wallpaper sync script, but **not** for the real login screen at boot.

```bash
sudo cp -a ~/Desktop/home/pear /usr/share/sddm/themes/pear
# optional: keep a user copy for sync-wallpaper.sh / autostart
mkdir -p ~/.local/share/sddm/themes
cp -a /usr/share/sddm/themes/pear ~/.local/share/sddm/themes/pear
```

Then select the theme:

- **System Settings → Colors & Themes → Login Screen (SDDM)** → **Pear**  
  or edit `/etc/sddm.conf` or `/etc/sddm.conf.d/kde_settings.conf`:

```ini
[Theme]
Current=pear
```

Apply (restart SDDM greeter or reboot):

```bash
sudo systemctl restart sddm
```

Verify SDDM finds the theme (should **not** say “doesn't exist”):

```bash
journalctl -u sddm -b | grep -i theme
```

### Wake from sleep vs cold boot

These are **two different UIs**:

| When | What you see | How to customize |
|------|----------------|------------------|
| **Power on / logout** | SDDM login greeter | This theme (`Current=pear` + install under `/usr/share/sddm/themes`) |
| **Resume from suspend** | Plasma **screen locker** (often Breeze) | **System Settings → Security & Privacy → Screen Locking** (wallpaper / appearance). SDDM themes do not apply here. |

To align the lock screen with your desktop wallpaper, use the lock screen settings above or match your Plasma look-and-feel; there is no way to run this QML SDDM theme on wake without a separate lock-screen project.

## Test without logging out

```bash
sddm-greeter --test-mode --theme ~/.local/share/sddm/themes/pear
```

## Desktop wallpaper sync

SDDM cannot read your private Plasma config directly. The theme includes a sync script that copies your current desktop wallpaper into the theme:

```bash
~/.local/share/sddm/themes/pear/scripts/sync-wallpaper.sh
```

Run it once after install, and again whenever you change your wallpaper. To automate it, copy the autostart entry:

```bash
mkdir -p ~/.config/autostart
cp ~/.local/share/sddm/themes/pear/autostart/plasma-sddm-wallpaper.desktop ~/.config/autostart/
```

That syncs on each Plasma login. After changing your wallpaper, log out or run the script manually once.

## Customize

Edit `~/.local/share/sddm/themes/pear/theme.conf`:

| Key | Description |
|-----|-------------|
| `background` | Wallpaper path (relative to theme folder or absolute) |
| `globalFont` | Font family applied to all visible text unless a field override is set. |
| `globalFontWeight` | Weight applied to all visible text unless a field override is set. |
| `globalFontStyle` | Style applied to all visible text unless a field override is set. |
| `<field>Font` | Optional font family override for one text field. |
| `<field>FontWeight` | Optional weight override for one text field. |
| `<field>FontStyle` | Optional style override for one text field. |
| `clockTopMargin` | Clock vertical position (0–1 fraction of screen height) |
| `loginBottomMargin` | Login block position from bottom |
| `passwordFieldWidth` | Password input width in pixels |

Available field prefixes: `clockDate`, `clockTime`, `username`, `passwordPlaceholder`, `capsLock`, `loginError`, `sessionLabel`, `sessionMenu`, and `sessionIndicator`.

Weights accept names like `Normal`, `Medium`, `DemiBold`, `Bold`, `ExtraBold`, and `Black` or numeric CSS-style values like `400`, `600`, and `700`. Styles accept `Normal`, `Italic`, or `Oblique`.

Example — use your Plasma wallpaper:

```ini
[General]
background=/usr/share/wallpapers/Next/contents/images/5120x2880.png
```

Example — force a global installed font and override the clock time:

```ini
[General]
globalFont=Inter
globalFontWeight=Medium
clockTimeFont=
clockTimeFontWeight=DemiBold
clockTimeFontStyle=Italic
```

## Notes

- **Icons** use SVG assets under `images/`.
- **Session menu** in the top bar: KDE/DE icon + label opens a dropdown of available sessions (e.g. Wayland, X11).
- Add more top bar items by nesting QML inside `TopBar { ... }` in `Main.qml`.

### Session icons (Plasma, GNOME, Hyprland, …)

SDDM’s `sessionModel` exposes `name` and `file` (e.g. `plasma.desktop`), but **not** the desktop’s `Icon=` field. This theme:

1. Uses **`start-here-kde.svg`** for Plasma/KDE sessions (name/file match).
2. Loads **`images/icons/sessions/<id>.svg`** when present (`<id>` = desktop basename or mapped DE name).
3. Falls back to **`images/icons/sessions/generic.svg`**.

To pull icons from installed icon themes (Breeze, Papirus, Adwaita, …) for each session `.desktop` on your system:

```bash
~/Desktop/home/pear/scripts/sync-session-icons.sh
```

Re-run after installing new sessions (e.g. Hyprland). The script reads `Icon=` and `DesktopNames=` from `/usr/share/wayland-sessions` and `/usr/share/xsessions`, then copies matching SVG/PNG into the theme.
- Click the **avatar** to switch users when multiple accounts exist.
- User photos come from SDDM/AccountsService (`~/.face.icon` or system face cache).

## Requirements

- SDDM with Qt 5 or Qt 6 (Theme API 2.0)
- KDE Plasma for wallpaper sync and session discovery
