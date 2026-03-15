#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Resolve version from Info.plist
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$SCRIPT_DIR/Info.plist" 2>/dev/null || echo "1.0")

APP="$SCRIPT_DIR/Mistype.app"
DMG="$HOME/Desktop/Mistype-${VERSION}.dmg"
TMP_DMG="$SCRIPT_DIR/.tmp-rw.dmg"
STAGING="$SCRIPT_DIR/.dmg-staging"
VOLUME="/Volumes/Mistype"

cleanup() {
    hdiutil detach "$VOLUME" -quiet 2>/dev/null || true
    rm -f "$TMP_DMG"
    rm -rf "$STAGING"
}
trap cleanup EXIT ERR

echo "=== Building Mistype ==="
bash "$SCRIPT_DIR/build.sh" --no-launch

echo ""
echo "=== Generating background image ==="
rm -f "$SCRIPT_DIR/Mistype-bg.png"
swift "$SCRIPT_DIR/make_bg.swift"

echo ""
echo "=== Preparing staging folder ==="
rm -rf "$STAGING"
mkdir -p "$STAGING"
cp -r "$APP" "$STAGING/"
cp "$SCRIPT_DIR/install.command" "$STAGING/Install Mistype.command"
chmod +x "$STAGING/Install Mistype.command"


echo ""
echo "=== Creating writable temp DMG ==="
rm -f "$TMP_DMG"
hdiutil create \
    -volname "Mistype" \
    -srcfolder "$STAGING" \
    -fs HFS+ \
    -fsargs "-c c=64,a=16,b=16" \
    -format UDRW \
    -size 80m \
    "$TMP_DMG"

echo "=== Mounting temp DMG ==="
# Force detach any existing mount with this volume name
hdiutil detach "$VOLUME" -quiet 2>/dev/null || true
DEV=$(hdiutil attach -readwrite -noverify -noautoopen "$TMP_DMG" \
        | grep -E '^/dev/' | tail -1 | awk '{print $1}')

echo "Mounted at $VOLUME (device $DEV)"

echo "=== Installing background ==="
mkdir -p "$VOLUME/.background"
cp "$SCRIPT_DIR/Mistype-bg.png" "$VOLUME/.background/background.png"

echo "=== Configuring Finder window via AppleScript ==="
# Retry up to 3 times — Finder AppleScript can be slow to reflect new mounts
APPLESCRIPT_SUCCESS=false
for attempt in 1 2 3; do
    sleep 2
    if osascript <<'APPLESCRIPT' 2>/dev/null; then
tell application "Finder"
    tell disk "Mistype"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {100, 60, 760, 580}
        set theViewOptions to the icon view options of container window
        set arrangement of theViewOptions to not arranged
        set icon size of theViewOptions to 128
        set text size of theViewOptions to 13
        set background picture of theViewOptions to file ".background:background.png"
        set position of item "Mistype.app" of container window to {160, 200}
        set position of item "Install Mistype.command" of container window to {460, 200}
        close
        open
        update without registering applications
        delay 3
        close
    end tell
end tell
APPLESCRIPT
        APPLESCRIPT_SUCCESS=true
        break
    fi
    echo "  AppleScript attempt $attempt failed, retrying..."
done
if [[ "$APPLESCRIPT_SUCCESS" == false ]]; then
    echo "  Warning: Finder AppleScript did not succeed — DMG layout may not be styled."
fi

echo "=== Syncing and unmounting ==="
sync
hdiutil detach "$DEV" -quiet

echo ""
echo "=== Converting to compressed read-only DMG ==="
rm -f "$DMG"
hdiutil convert "$TMP_DMG" \
    -format UDZO \
    -imagekey zlib-level=9 \
    -o "$DMG"

# Cleanup happens via trap on EXIT
echo ""
echo "Done: $DMG"
