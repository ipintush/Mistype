# This file is auto-updated by release.sh — do not edit manually.
cask "switchback" do
  version "1.4"
  sha256 "6fd9f697c5da5c28c0894e8905abe78efa92edf7b261096386dfd02d244eadb8"

  url "https://github.com/ipintush/SwitchBack/releases/download/v1.4/SwitchBack-1.4.pkg"
  name "SwitchBack"
  desc "Toggle selected text between Hebrew and English keyboard layouts"
  homepage "https://github.com/ipintush/SwitchBack"

  pkg "SwitchBack-#{version}.pkg"

  uninstall pkgutil: "com.switchback.app",
            delete:  "/Applications/SwitchBack.app"

  zap trash: "~/Library/Preferences/com.switchback.app.plist"
end
