# This file is auto-updated by release.sh — do not edit manually.
cask "mistype" do
  version "PLACEHOLDER_VERSION"
  sha256 "PLACEHOLDER_SHA256"

  url "https://github.com/PLACEHOLDER_GITHUB_USER/PLACEHOLDER_GITHUB_REPO/releases/download/v#{version}/Mistype-#{version}.pkg"
  name "Mistype"
  desc "Toggle selected text between Hebrew and English keyboard layouts"
  homepage "https://github.com/PLACEHOLDER_GITHUB_USER/PLACEHOLDER_GITHUB_REPO"

  pkg "Mistype-#{version}.pkg"

  uninstall pkgutil: "com.mistype.app",
            delete:  "/Applications/Mistype.app"

  zap trash: "~/Library/Preferences/com.mistype.app.plist"
end
