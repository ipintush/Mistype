#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_SRC="$SOURCE_DIR/Mistype.app"
DEST="/Applications/Mistype.app"

echo ""
echo "=== Mistype Installer ==="
echo ""

if [ ! -d "$APP_SRC" ]; then
    echo "Error: Mistype.app not found."
    echo "Please run this installer directly from the Mistype disk image."
    read -rp "Press Enter to close..."
    exit 1
fi

if [ -d "$DEST" ]; then
    echo "Removing previous installation..."
    rm -rf "$DEST"
fi

echo "Installing Mistype to /Applications..."
cp -r "$APP_SRC" "$DEST"

echo "Removing macOS quarantine flag..."
xattr -cr "$DEST"

echo ""
echo "Done! Launching Mistype..."
open "$DEST"
