#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_SRC="$SOURCE_DIR/SwitchBack.app"
DEST="/Applications/SwitchBack.app"

echo ""
echo "=== SwitchBack Installer ==="
echo ""

if [ ! -d "$APP_SRC" ]; then
    echo "Error: SwitchBack.app not found."
    echo "Please run this installer directly from the SwitchBack disk image."
    read -rp "Press Enter to close..."
    exit 1
fi

if [ -d "$DEST" ]; then
    echo "Removing previous installation..."
    rm -rf "$DEST"
fi

echo "Installing SwitchBack to /Applications..."
cp -r "$APP_SRC" "$DEST"

echo "Removing macOS quarantine flag..."
xattr -cr "$DEST"

echo ""
echo "Done! Launching SwitchBack..."
open "$DEST"
