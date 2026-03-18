#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Info.plist 2>/dev/null || echo "1.0")
PKG="$SCRIPT_DIR/SwitchBack-${VERSION}.pkg"

echo "=== Building SwitchBack ==="
bash "$SCRIPT_DIR/build.sh" --no-launch

echo ""
echo "=== Creating PKG installer ==="
pkgbuild \
  --component "$SCRIPT_DIR/SwitchBack.app" \
  --install-location /Applications \
  --identifier com.switchback.app \
  --version "$VERSION" \
  --scripts "$SCRIPT_DIR/pkg-scripts" \
  "$PKG"

echo ""
echo "Done: $PKG"
