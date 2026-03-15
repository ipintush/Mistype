#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

export MACOSX_DEPLOYMENT_TARGET=11.0

NO_LAUNCH=false
for arg in "$@"; do
    [[ "$arg" == "--no-launch" ]] && NO_LAUNCH=true
done

echo "Generating AppIcon.icns..."
swift make_icon.swift

echo "Building Mistype (universal)..."
swift build -c release --arch arm64
swift build -c release --arch x86_64

echo "Lipoing universal binary..."
mkdir -p .build/release
lipo -create \
    .build/arm64-apple-macosx/release/Mistype \
    .build/x86_64-apple-macosx/release/Mistype \
    -output .build/release/Mistype

BINARY=".build/release/Mistype"
APP_DIR="Mistype.app"
CONTENTS="$APP_DIR/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

echo "Assembling .app bundle..."
rm -rf "$APP_DIR"
mkdir -p "$MACOS" "$RESOURCES"

cp "$BINARY"      "$MACOS/Mistype"
cp "Info.plist"   "$CONTENTS/Info.plist"
cp "AppIcon.icns" "$RESOURCES/AppIcon.icns"

echo "Code signing (ad-hoc)..."
codesign --force --deep \
    --entitlements "$SCRIPT_DIR/entitlements.plist" \
    --sign - "$APP_DIR"

if [[ "$NO_LAUNCH" == false ]]; then
    echo "Done. Launching Mistype.app..."
    pkill -x Mistype 2>/dev/null || true
    sleep 0.5
    open "$APP_DIR"
else
    echo "Done: $APP_DIR"
fi
