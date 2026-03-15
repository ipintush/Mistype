#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Mistype — automated release script
#
# Usage:
#   bash release.sh
#
# What it does:
#   1. Builds Mistype-<version>.pkg via make_pkg.sh
#   2. Computes SHA256
#   3. Rewrites homebrew-tap/Casks/mistype.rb
#   4. Commits + tags + pushes main repo
#   5. Creates GitHub Release and uploads the PKG
#   6. Commits + pushes tap repo
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ── Configure once ──────────────────────────────────────────────────────────
GITHUB_USER="${GITHUB_USER:-ipintush}"
GITHUB_REPO="mistype"
TAP_REPO="homebrew-mistype"
# ────────────────────────────────────────────────────────────────────────────

# 0. Validation
if [[ -z "$GITHUB_USER" ]]; then
    echo "ERROR: GITHUB_USER is not set."
    exit 1
fi

command -v gh >/dev/null 2>&1 || { echo "ERROR: GitHub CLI not found. Install with:  brew install gh"; exit 1; }

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Info.plist)
PKG="$SCRIPT_DIR/Mistype-${VERSION}.pkg"
TAG="v${VERSION}"

# 1. Build
echo "=== Building Mistype ${VERSION} ==="
bash "$SCRIPT_DIR/make_pkg.sh"

[[ -f "$PKG" ]] || { echo "ERROR: Expected PKG not found: $PKG"; exit 1; }

# 2. SHA256
echo ""
echo "=== Computing SHA256 ==="
SHA256=$(shasum -a 256 "$PKG" | awk '{print $1}')
echo "  $SHA256"

# 3. Update cask
echo ""
echo "=== Updating homebrew-tap/Casks/mistype.rb ==="
cat > "$SCRIPT_DIR/homebrew-tap/Casks/mistype.rb" <<RUBY
# This file is auto-updated by release.sh — do not edit manually.
cask "mistype" do
  version "${VERSION}"
  sha256 "${SHA256}"

  url "https://github.com/${GITHUB_USER}/${GITHUB_REPO}/releases/download/${TAG}/Mistype-${VERSION}.pkg"
  name "Mistype"
  desc "Toggle selected text between Hebrew and English keyboard layouts"
  homepage "https://github.com/${GITHUB_USER}/${GITHUB_REPO}"

  pkg "Mistype-#{version}.pkg"

  uninstall pkgutil: "com.mistype.app",
            delete:  "/Applications/Mistype.app"

  zap trash: "~/Library/Preferences/com.mistype.app.plist"
end
RUBY

# Also patch the tap README so the install command shows the real username
sed -i '' "s|YOUR_GITHUB_USER|${GITHUB_USER}|g" "$SCRIPT_DIR/homebrew-tap/README.md" 2>/dev/null || true

echo "  Done."

# 4. Commit + tag main repo
echo ""
echo "=== Committing and tagging main repo ==="
git add -A
git commit -m "Release ${TAG}"
git tag "${TAG}"
git push origin main
git push origin "${TAG}"

# 5. GitHub Release + upload PKG
echo ""
echo "=== Creating GitHub Release ${TAG} ==="
gh release create "${TAG}" \
    "$PKG" \
    --title "Mistype ${VERSION}" \
    --notes-file CHANGELOG.md \
    --repo "${GITHUB_USER}/${GITHUB_REPO}"

# 6. Push tap
echo ""
echo "=== Pushing tap repo ==="
cd "$SCRIPT_DIR/homebrew-tap"
git add -A
git commit -m "Mistype ${VERSION}"
git push origin main

echo ""
echo "========================================================"
echo " Released ${TAG} successfully!"
echo "========================================================"
echo ""
echo "Install:  brew tap ${GITHUB_USER}/mistype && brew install --cask mistype"
echo "Upgrade:  brew upgrade --cask mistype"
