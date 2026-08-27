# Sonoma SDDM Theme

A macOS Sonoma–inspired SDDM login theme for **KDE Plasma**. Uses your installed **SF Pro** fonts, a centered clock, frosted password field, user avatar, and a top-right status bar (keyboard layout, battery, Wi‑Fi icon, control center menu).

## Install

```bash
mkdir -p ~/.local/share/sddm/themes
cp -r ~/Desktop/sonoma-sddm ~/.local/share/sddm/themes/sonoma
```

Then select the theme:

- **System Settings → Colors & Themes → Login Screen (SDDM)** → **Sonoma**  
  or edit `/etc/sddm.conf`:

```ini
[Theme]
Current=sonoma
```

Apply (restart SDDM greeter or reboot):

```bash
sudo systemctl restart sddm
```

## Test without logging out

```bash
sddm-greeter --test-mode --theme ~/.local/share/sddm/themes/sonoma
```

## Desktop wallpaper sync

SDDM cannot read your private Plasma config directly. The theme includes a sync script that copies your current desktop wallpaper into the theme:

```bash
~/.local/share/sddm/themes/sonoma/scripts/sync-wallpaper.sh
```

Run it once after install, and again whenever you change your wallpaper. To automate it, copy the autostart entry:

```bash
mkdir -p ~/.config/autostart
cp ~/.local/share/sddm/themes/sonoma/autostart/plasma-sddm-wallpaper.desktop ~/.config/autostart/
```

That syncs on each Plasma login. After changing your wallpaper, log out or run the script manually once.

## Customize

Edit `~/.local/share/sddm/themes/sonoma/theme.conf`:

| Key | Description |
|-----|-------------|
| `background` | Wallpaper path (relative to theme folder or absolute) |
| `fontFamily` | Clock font (default: `SF Pro Display`) |
| `fontFamilyUI` | UI font (default: `SF Pro Text`) |
| `clockTopMargin` | Clock vertical position (0–1 fraction of screen height) |
| `loginBottomMargin` | Login block position from bottom |
| `passwordFieldWidth` | Password pill width in pixels |

Example — use your Plasma wallpaper:

```ini
[General]
background=/usr/share/wallpapers/Next/contents/images/5120x2880.png
```

## Notes

- **Icons** use Google Material Icons Outlined (font bundled in `fonts/`).
- **Battery** appears only on machines with a real battery (`/sys/class/power_supply/BAT*`).
- **Network icon** shows ethernet (`lan`) when a wired link is up, otherwise Wi‑Fi when wireless is up.
- **Session label** in the top-left shows the active session type (e.g. Wayland, X11).
- **Control center** (tune icon): session picker, Sleep, Restart, Shut Down.
- Click the **avatar** to switch users when multiple accounts exist.
- User photos come from SDDM/AccountsService (`~/.face.icon` or system face cache).

## Requirements

- SDDM with Qt 5 or Qt 6 (Theme API 2.0)
- KDE Plasma (for battery indicator and keyboard layout modules)
- SF Pro fonts installed system-wide
