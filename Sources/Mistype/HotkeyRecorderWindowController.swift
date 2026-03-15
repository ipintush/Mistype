import AppKit
import Carbon

@MainActor
final class HotkeyRecorderWindowController: NSWindowController {
    var onSave: (() -> Void)?
    weak var hotkeyManager: HotkeyManager?

    private var pendingKeyCode: UInt16?
    private var pendingModifiers: NSEvent.ModifierFlags?
    private var localMonitor: Any?

    private let statusLabel = NSTextField(labelWithString: "Press new hotkey...")
    private let comboField  = NSTextField(labelWithString: "")
    private let saveButton   = NSButton(title: "Save", target: nil, action: nil)
    private let cancelButton = NSButton(title: "Cancel", target: nil, action: nil)

    convenience init() {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 260, height: 120),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        panel.title = "Change Hotkey"
        panel.isFloatingPanel = true
        panel.center()
        self.init(window: panel)
        setupUI()
    }

    private func setupUI() {
        guard let contentView = window?.contentView else { return }

        statusLabel.alignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        comboField.alignment = .center
        comboField.font = NSFont.monospacedSystemFont(ofSize: 18, weight: .medium)
        comboField.translatesAutoresizingMaskIntoConstraints = false

        let (kc, mods) = HotkeyStore.load()
        comboField.stringValue = HotkeyStore.displayString(keyCode: kc, modifiers: mods)

        saveButton.bezelStyle = .rounded
        saveButton.target = self
        saveButton.action = #selector(saveTapped)
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        cancelButton.bezelStyle = .rounded
        cancelButton.target = self
        cancelButton.action = #selector(cancelTapped)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(statusLabel)
        contentView.addSubview(comboField)
        contentView.addSubview(saveButton)
        contentView.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            statusLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            comboField.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            comboField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            cancelButton.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -8),

            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            saveButton.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 8),
        ])
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        installLocalMonitor()
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKey()
    }

    private func installLocalMonitor() {
        guard localMonitor == nil else { return }
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }
            return self.captureEvent(event)
        }
    }

    private func captureEvent(_ event: NSEvent) -> NSEvent? {
        // Let Escape and Return pass through so Cancel/Save buttons still work via keyboard
        let kc = event.keyCode
        if kc == 53 /* Escape */ || kc == 36 /* Return */ || kc == 76 /* numpad Enter */ {
            return event
        }

        let flags = event.modifierFlags
            .intersection(.deviceIndependentFlagsMask)
            .subtracting([.numericPad, .help, .capsLock])

        // Require at least one of Cmd / Ctrl / Option / Fn to avoid capturing plain letters
        guard !flags.intersection([.command, .control, .option, .function]).isEmpty else {
            return event
        }

        pendingKeyCode = kc
        pendingModifiers = flags
        comboField.stringValue = HotkeyStore.displayString(keyCode: kc, modifiers: flags)
        return nil
    }

    @objc private func saveTapped() {
        if let keyCode = pendingKeyCode, let mods = pendingModifiers {
            HotkeyStore.save(keyCode: keyCode, modifiers: mods)
            hotkeyManager?.reinstall()
            onSave?()
        }
        close()
    }

    @objc private func cancelTapped() {
        close()
    }

    override func close() {
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
        super.close()
    }
}
