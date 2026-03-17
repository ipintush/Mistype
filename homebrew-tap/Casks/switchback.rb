# This file is auto-updated by release.sh — do not edit manually.
cask "switchback" do
  version "1.1"
  sha256 "4db2c47881f733c192fd98f944e8b0c4a973a3afbe5d23591c121cb56cf9ad84"

  url "https://github.com/ipintush/Mistype/releases/download/v1.1/SwitchBack-1.1.pkg"
  name "SwitchBack"
  desc "Toggle selected text between Hebrew and English keyboard layouts"
  homepage "https://github.com/ipintush/Mistype"

  pkg "SwitchBack-#{version}.pkg"

  uninstall pkgutil: "com.switchback.app",
            delete:  "/Applications/SwitchBack.app"

  zap trash: "~/Library/Preferences/com.switchback.app.plist"
end
