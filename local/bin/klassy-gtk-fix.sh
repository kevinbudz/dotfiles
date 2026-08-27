#!/bin/bash
# Re-apply Klassy GTK fixes if window_decorations.css gets overwritten
FIXED_CSS="$HOME/.local/share/klassy-gtk-fixes/window_decorations.css"
TARGET_CSS="$HOME/.config/gtk-3.0/window_decorations.css"
TARGET_CSS4="$HOME/.config/gtk-4.0/window_decorations.css"
EXPECTED_MARKER="Klassy GTK fixes"
if [ ! -f "$FIXED_CSS" ]; then
  exit 0
fi
if ! grep -q "$EXPECTED_MARKER" "$TARGET_CSS" 2>/dev/null; then
  echo "Re-applying Klassy GTK fixes to $TARGET_CSS"
  cp "$FIXED_CSS" "$TARGET_CSS"
  cp "$FIXED_CSS" "$TARGET_CSS4"
  # Ensure assets are present for gtk4
  mkdir -p "$HOME/.config/gtk-4.0/assets"
  cp -n "$HOME/.config/gtk-3.0/assets/"*.svg "$HOME/.config/gtk-4.0/assets/" 2>/dev/null
fi
# Also ensure gtk.css is clean (kde-gtk-config bug creates duplicate imports)
for ver in 3 4; do
  echo "@import 'colors.css';" > "$HOME/.config/gtk-${ver}.0/gtk.css"
done
