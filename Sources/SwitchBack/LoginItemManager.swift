import Foundation
import ServiceManagement

@MainActor
final class LoginItemManager {
    static let shared = LoginItemManager()
    private init() {}

    var isEnabled: Bool {
        if #available(macOS 13, *) {
            return SMAppService.mainApp.status == .enabled
        }
        return legacyIsEnabled
    }

    func setEnabled(_ enabled: Bool) {
        if #available(macOS 13, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                legacySetEnabled(enabled)
            }
        } else {
            legacySetEnabled(enabled)
        }
    }

    // MARK: - Legacy (macOS 11–12) LaunchAgent

    private let label = "com.switchback.app"

    private var plistURL: URL? {
        FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?
            .appendingPathComponent("LaunchAgents/\(label).plist")
    }

    private var legacyIsEnabled: Bool {
        guard let url = plistURL else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }

    private func legacySetEnabled(_ enabled: Bool) {
        enabled ? legacyInstall() : legacyRemove()
    }

    private func legacyInstall() {
        guard let url = plistURL,
              let execPath = Bundle.main.executablePath else { return }

        let plist: [String: Any] = [
            "Label": label,
            "ProgramArguments": [execPath],
            "RunAtLoad": true
        ]

        try? FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        if let data = try? PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0) {
            try? data.write(to: url)
        }
    }

    private func legacyRemove() {
        guard let url = plistURL else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
