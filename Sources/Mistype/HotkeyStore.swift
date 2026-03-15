import AppKit
import Carbon

enum HotkeyStore {
    private static let defaultsKey = "mistypeHotkey"

    static func load() -> (keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
        if let dict = UserDefaults.standard.dictionary(forKey: defaultsKey),
           let kc = dict["keyCode"] as? Int,
           let mod = dict["modifiers"] as? Int {
            return (keyCode: UInt16(kc), modifiers: NSEvent.ModifierFlags(rawValue: UInt(mod)))
        }
        return (keyCode: UInt16(kVK_ANSI_H), modifiers: [.command, .shift])
    }

    static func save(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
        UserDefaults.standard.set(
            ["keyCode": Int(keyCode), "modifiers": Int(modifiers.rawValue)],
            forKey: defaultsKey
        )
    }

    static func displayString(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> String {
        var result = ""
        if modifiers.contains(.function) { result += "fn " }
        if modifiers.contains(.control) { result += "⌃" }
        if modifiers.contains(.option)  { result += "⌥" }
        if modifiers.contains(.shift)   { result += "⇧" }
        if modifiers.contains(.command) { result += "⌘" }
        result += keyCodeToChar(keyCode)
        return result
    }

    private static func keyCodeToChar(_ keyCode: UInt16) -> String {
        let map: [UInt16: String] = [
            UInt16(kVK_ANSI_A): "A", UInt16(kVK_ANSI_B): "B", UInt16(kVK_ANSI_C): "C",
            UInt16(kVK_ANSI_D): "D", UInt16(kVK_ANSI_E): "E", UInt16(kVK_ANSI_F): "F",
            UInt16(kVK_ANSI_G): "G", UInt16(kVK_ANSI_H): "H", UInt16(kVK_ANSI_I): "I",
            UInt16(kVK_ANSI_J): "J", UInt16(kVK_ANSI_K): "K", UInt16(kVK_ANSI_L): "L",
            UInt16(kVK_ANSI_M): "M", UInt16(kVK_ANSI_N): "N", UInt16(kVK_ANSI_O): "O",
            UInt16(kVK_ANSI_P): "P", UInt16(kVK_ANSI_Q): "Q", UInt16(kVK_ANSI_R): "R",
            UInt16(kVK_ANSI_S): "S", UInt16(kVK_ANSI_T): "T", UInt16(kVK_ANSI_U): "U",
            UInt16(kVK_ANSI_V): "V", UInt16(kVK_ANSI_W): "W", UInt16(kVK_ANSI_X): "X",
            UInt16(kVK_ANSI_Y): "Y", UInt16(kVK_ANSI_Z): "Z",
            UInt16(kVK_ANSI_0): "0", UInt16(kVK_ANSI_1): "1", UInt16(kVK_ANSI_2): "2",
            UInt16(kVK_ANSI_3): "3", UInt16(kVK_ANSI_4): "4", UInt16(kVK_ANSI_5): "5",
            UInt16(kVK_ANSI_6): "6", UInt16(kVK_ANSI_7): "7", UInt16(kVK_ANSI_8): "8",
            UInt16(kVK_ANSI_9): "9",
            UInt16(kVK_Function): "Globe",
            UInt16(kVK_Space): "Space",
            UInt16(kVK_Return): "Return",
            UInt16(kVK_Tab): "Tab",
            UInt16(kVK_F1): "F1",  UInt16(kVK_F2): "F2",  UInt16(kVK_F3): "F3",
            UInt16(kVK_F4): "F4",  UInt16(kVK_F5): "F5",  UInt16(kVK_F6): "F6",
            UInt16(kVK_F7): "F7",  UInt16(kVK_F8): "F8",  UInt16(kVK_F9): "F9",
            UInt16(kVK_F10): "F10", UInt16(kVK_F11): "F11", UInt16(kVK_F12): "F12",
        ]
        return map[keyCode] ?? "?"
    }
}
