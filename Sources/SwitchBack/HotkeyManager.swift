import AppKit
import Carbon

@MainActor
final class HotkeyManager {
    private var monitor: Any?

    func install() {
        guard monitor == nil else { return }
        guard AXIsProcessTrusted() else { return }

        let (keyCode, modifiers) = HotkeyStore.load()
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleEvent(event, keyCode: keyCode, modifiers: modifiers)
        }
    }

    private func handleEvent(_ event: NSEvent, keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
        guard AXIsProcessTrusted() else { return }

        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        guard event.keyCode == keyCode, flags == modifiers else { return }

        ClipboardHelper.performConversion()
    }

    func reinstall() {
        uninstall()
        install()
    }

    func uninstall() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}
