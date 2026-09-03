#!/usr/bin/env bash
# Wrapper used by the Pear theme autostart entry.
set -euo pipefail

if [[ -x "${HOME}/.local/bin/sync-wallpaper.sh" ]]; then
    exec "${HOME}/.local/bin/sync-wallpaper.sh" "$@"
fi

echo "sync-wallpaper.sh is not installed in ~/.local/bin" >&2
exit 1
