#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Info.plist 2>/dev/null || echo "1.0")
PKG="$SCRIPT_DIR/Mistype-${VERSION}.pkg"

echo "=== Building Mistype ==="
bash "$SCRIPT_DIR/build.sh" --no-launch

echo ""
echo "=== Creating PKG installer ==="
pkgbuild \
  --component "$SCRIPT_DIR/Mistype.app" \
  --install-location /Applications \
  --identifier com.mistype.app \
  --version "$VERSION" \
  "$PKG"

echo ""
echo "Done: $PKG"
