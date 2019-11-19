import SwiftUI

struct DefaultsColors {
    let text = Color(NSColor.gray)
    let background = Color(white: 0.11)
    let lightBackground = Color(white: 0.2)
    let selected = Color(NSColor.gray)
    let selectable = Color(NSColor.darkGray)
    let checkboxActive = Color(NSColor.yellow)
    let checkboxChecked = Color(NSColor.darkGray)
    let dropIndicator = Color(.systemBlue)
    let dropBackground = Color(.blue)

    func selectable(_ selected: Bool) -> Color {
        selected ? self.selected : self.selectable
    }

    func checkbox(_ checked: Bool) -> Color {
        checked ? self.selectable : self.checkboxActive
    }

    func focusSelected(_ selected: Bool) -> Color {
        selected ? self.background : self.lightBackground
    }
}

fileprivate let defaultShortcuts: [Shortcut] = [
    Shortcut(binding: KeyBinding(with: "Down"), gesture: .Down),
    Shortcut(binding: KeyBinding(with: "Up"), gesture: .Up),
    Shortcut(binding: KeyBinding(with: "j"), gesture: .Down),
    Shortcut(binding: KeyBinding(with: "k"), gesture: .Up),
    Shortcut(binding: KeyBinding(with: "Space"), gesture: .ToggleDone),
    Shortcut(binding: KeyBinding(with: "Tab"), gesture: .ToggleEditing),
    Shortcut(binding: KeyBinding(with: "Enter"), gesture: .AddTask),
    Shortcut(binding: KeyBinding(with: "Delete"), gesture: .DeleteTask),
    Shortcut(binding: KeyBinding(with: "Command+Shift+]"), gesture: .Indent),
    Shortcut(binding: KeyBinding(with: "Command+Shift+["), gesture: .Outdent),
    Shortcut(binding: KeyBinding(with: "Command+Shift+Up"), gesture: .MoveUp),
    Shortcut(binding: KeyBinding(with: "Command+Shift+Down"), gesture: .MoveDown),
    Shortcut(binding: KeyBinding(with: "Command+z"), gesture: .Undo),
    Shortcut(binding: KeyBinding(with: "Command+Shift+z"), gesture: .Redo),
    Shortcut(binding: KeyBinding(with: "Command+1"), gesture: .Focus(.All)),
    Shortcut(binding: KeyBinding(with: "Command+2"), gesture: .Focus(.Inbox)),
    Shortcut(binding: KeyBinding(with: "Command+3"), gesture: .Focus(.Due(Date()))),
    Shortcut(binding: KeyBinding(with: "Command+4"), gesture: .Focus(.Project(Project(id: -1, title: "")))),
    Shortcut(binding: KeyBinding(with: "Command+Up"), gesture: .FocusUp),
    Shortcut(binding: KeyBinding(with: "Command+Down"), gesture: .FocusDown),
    Shortcut(binding: KeyBinding(with: "Command+Left"), gesture: .FocusLeft),
    Shortcut(binding: KeyBinding(with: "Command+Right"), gesture: .FocusRight)
]

struct Defaults {
    static let colors = DefaultsColors()
    static let shortcuts = defaultShortcuts
}
