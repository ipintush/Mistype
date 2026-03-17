#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# SwitchBack — one-time GitHub setup
#
# Run once after creating two public GitHub repos:
#   - SwitchBack          (main code + releases)
#   - homebrew-switchback (tap)
#
# Usage:
#   GITHUB_USER=yourname bash setup_github.sh
# =============================================================================

GITHUB_USER="${GITHUB_USER:-ipintush}"
MAIN_REPO="SwitchBack"
TAP_REPO="homebrew-switchback"

if [[ -z "$GITHUB_USER" ]]; then
    echo "ERROR: GITHUB_USER is not set."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$SCRIPT_DIR/Info.plist")

# --- Main repo ---
cd "$SCRIPT_DIR"
git init
git add -A
git commit -m "Initial commit — SwitchBack v${VERSION}"
git branch -M main
git remote add origin "git@github.com:${GITHUB_USER}/${MAIN_REPO}.git"
git push -u origin main

# --- Tap repo ---
cd "$SCRIPT_DIR/homebrew-tap"
git init
git add -A
git commit -m "Initial tap"
git branch -M main
git remote add origin "git@github.com:${GITHUB_USER}/${TAP_REPO}.git"
git push -u origin main

echo ""
echo "Done! Both repos connected."
echo ""
echo "To release:  bash \"$SCRIPT_DIR/release.sh\""
