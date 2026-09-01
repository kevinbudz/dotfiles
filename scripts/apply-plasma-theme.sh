#!/usr/bin/env bash
# Apply and live-reload KDE Plasma 6, KWin, GTK, and font caches
set -euo pipefail

echo "==> Rebuilding system configuration cache..."
if command -v kbuildsycoca6 &>/dev/null; then
    kbuildsycoca6 --noincremental 2>/dev/null || true
fi

echo "==> Updating font cache..."
if command -v fc-cache &>/dev/null; then
    fc-cache -f "${HOME}/.local/share/fonts" 2>/dev/null || true
fi

echo "==> Applying Klassy GTK fixes..."
if [[ -x "${HOME}/.local/bin/klassy-gtk-fix.sh" ]]; then
    "${HOME}/.local/bin/klassy-gtk-fix.sh" 2>/dev/null || true
fi

echo "==> Reloading KWin window manager..."
if command -v qdbus6 &>/dev/null; then
    qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true
fi

echo "==> Reloading xsettingsd..."
if command -v pkill &>/dev/null; then
    pkill -HUP xsettingsd 2>/dev/null || true
fi

echo "==> Setting up environment variables..."
if command -v systemctl &>/dev/null; then
    systemctl --user set-environment QT_PLUGIN_PATH="${HOME}/.local/lib/qt6/plugins:/usr/lib/qt6/plugins" 2>/dev/null || true
fi

echo "==> Refreshing Plasma shell..."
if systemctl --user is-active --quiet plasma-plasmashell.service 2>/dev/null; then
    systemctl --user restart plasma-plasmashell.service 2>/dev/null || true
elif pgrep -x plasmashell >/dev/null; then
    killall plasmashell 2>/dev/null || true
    sleep 0.5
    (QT_PLUGIN_PATH="${HOME}/.local/lib/qt6/plugins:/usr/lib/qt6/plugins" kstart plasmashell &>/dev/null &) || true
fi

echo "Plasma appearance and settings reloaded successfully."
