import Foundation
import SwiftUI

enum InputError: Error {
    case InvalidShortcutDescription
}

struct Shortcut {
    let binding: KeyBinding
    let gesture: InputGesture
}

struct KeyBinding {
    let keyCode: UInt16
    let modifiers: NSEvent.ModifierFlags
    
    init(with description: String) {
        var parts = description.split(separator: "+")
        let char = String(parts.popLast()!)
        
        var foundCode: UInt16 = 0
        for (code, names) in keyCodeMap {
            if names.0 == char || names.1 == char {
                foundCode = code
                break
            }
        }
        self.keyCode = foundCode
        
        var modifiers: NSEvent.ModifierFlags = []
        for part in parts {
            if part == "Shift" {
                modifiers.insert(.shift)
            } else if part == "Control" {
                modifiers.insert(.control)
            } else if part == "Option" {
                modifiers.insert(.option)
            } else if part == "Command" {
                modifiers.insert(.command)
            }
        }
        self.modifiers = modifiers
    }
    
    func matches(event: NSEvent) -> Bool {
        let recognizedFlags: NSEvent.ModifierFlags = [
            .command,
            .shift,
            .option,
            .control
        ]
        
        return keyCode == event.keyCode && modifiers == event.modifierFlags.intersection(recognizedFlags)
    }

    private let keyCodeMap: [UInt16 : (String, String?)] = [
        0x00: ("a", "A"),
        0x01: ("s", "S"),
        0x02: ("d", "D"),
        0x03: ("f", "F"),
        0x04: ("h", "H"),
        0x05: ("g", "G"),
        0x06: ("z", "Z"),
        0x07: ("x", "X"),
        0x08: ("c", "C"),
        0x09: ("v", "V"),
        0x0B: ("b", "B"),
        0x0C: ("q", "Q"),
        0x0D: ("w", "W"),
        0x0E: ("e", "E"),
        0x0F: ("r", "R"),
        0x10: ("y", "Y"),
        0x11: ("t", "T"),
        0x12: ("1", "!"),
        0x13: ("2", "@"),
        0x14: ("3", "#"),
        0x15: ("4", "$"),
        0x16: ("6", "^"),
        0x17: ("5", "%"),
        0x18: ("=", "+"),
        0x19: ("9", "("),
        0x1A: ("7", "&"),
        0x1B: ("-", "_"),
        0x1C: ("8", "*"),
        0x1D: ("0", ")"),
        0x1E: ("]", "}"),
        0x1F: ("o", "O"),
        0x20: ("u", "U"),
        0x21: ("[", "{"),
        0x22: ("i", "I"),
        0x23: ("p", "P"),
        0x25: ("l", "L"),
        0x26: ("j", "J"),
        0x27: ("'", "\""),
        0x28: ("k", "K"),
        0x29: (";", ":"),
        0x2A: ("\\", "|"),
        0x2B: (",", "<"),
        0x2C: ("/", "?"),
        0x2D: ("n", "N"),
        0x2E: ("m", "M"),
        0x2F: (".", ">"),
        0x32: ("`", "~"),
        0x43: ("*", nil),
        0x45: ("+", nil),
        0x4B: ("/", nil),
        0x4E: ("-", nil),
        0x51: ("=", nil),
        0x52: ("KP0", nil),
        0x53: ("KP1", nil),
        0x54: ("KP2", nil),
        0x55: ("KP3", nil),
        0x56: ("KP4", nil),
        0x57: ("KP5", nil),
        0x58: ("KP6", nil),
        0x59: ("KP7", nil),
        0x5B: ("KP8", nil),
        0x5C: ("KP9", nil),
        
        0x24: ("Enter", nil),
        0x30: ("Tab", nil),
        0x31: ("Space", nil),
        0x33: ("Backspace", nil),
        0x35: ("Esc", nil),
        // 0x37: ("Command", nil),
        // 0x38: ("Shift", nil),
        // 0x39: ("CapsLock", nil),
        // 0x3A: ("Option", nil),
        // 0x3B: ("Control", nil),
        // 0x3C: ("RightShift", nil),
        // 0x3D: ("RightOption", nil),
        // 0x3E: ("RightControl", nil),
        // 0x3F: ("Function", nil),
        0x40: ("F17", nil),
        // 0x48: ("VolumeUp", nil),
        // 0x49: ("VolumeDown", nil),
        // 0x4A: ("Mute", nil),
        0x4F: ("F18", nil),
        0x50: ("F19", nil),
        0x5A: ("F20", nil),
        0x60: ("F5", nil),
        0x61: ("F6", nil),
        0x62: ("F7", nil),
        0x63: ("F3", nil),
        0x64: ("F8", nil),
        0x65: ("F9", nil),
        0x67: ("F11", nil),
        0x69: ("F13", nil),
        0x6A: ("F16", nil),
        0x6B: ("F14", nil),
        0x6D: ("F10", nil),
        0x6F: ("F12", nil),
        0x71: ("F15", nil),
        0x72: ("Insert", nil),
        0x73: ("Home", nil),
        0x74: ("PageUp", nil),
        0x75: ("Delete", nil),
        0x76: ("F4", nil),
        0x77: ("End", nil),
        0x78: ("F2", nil),
        0x79: ("PageDown", nil),
        0x7A: ("F1", nil),
        0x7B: ("Left", nil),
        0x7C: ("Right", nil),
        0x7D: ("Down", nil),
        0x7E: ("Up", nil),
    ]
    
    var description: String {
        var shortcut = ""
        let keyChar: String
        
        guard let keyName = self.keyCodeMap[keyCode] else {
            print("Unknown key code \(keyCode)")
            return ""
        }
        if modifiers.contains(.shift) {
            if let altName = keyName.1 {
                keyChar = altName
            } else {
                keyChar = keyName.0
                shortcut += "Shift+"
            }
        } else {
            keyChar = keyName.0
        }
        
        
        if modifiers.contains(.control) {
            shortcut += "Control+"
        }
        
        if modifiers.contains(.option) {
            shortcut += "Option+"
        }
        
        if modifiers.contains(.command) {
            shortcut += "Command+"
        }
        
        shortcut += keyChar
        
        return shortcut
    }
    
    
}
