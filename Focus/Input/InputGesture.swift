import Foundation
import SwiftUI

enum InputGesture {
    case Down
    case Up
    case ToggleDone
    case ToggleEditing
    case AddTask
    case DeleteTask
    case Indent
    case Outdent
    case Edit(Int)
    case Select(Int)
    case Drop
    case Undo
    case Redo
    case SetDue(Date?)
    case Focus(PerspectiveType)
    case FocusLeft
    case FocusRight
    case FocusUp
    case FocusDown
    case MoveUp
    case MoveDown
    
    init?(withEvent event: NSEvent) {
        guard let shortcut = Defaults.shortcuts.first(where: { $0.binding.matches(event: event) }) else {
            return nil
        }
        
        self = shortcut.gesture
    }
    
    init?(withCommand commandSelector: Selector) {
        switch commandSelector {
        case #selector(NSStandardKeyBindingResponding.moveDown(_:)):
            self = .Down
        case #selector(NSStandardKeyBindingResponding.moveUp(_:)):
            self = .Up
        case #selector(NSStandardKeyBindingResponding.insertNewline(_:)):
            self = .AddTask
        case #selector(NSStandardKeyBindingResponding.insertTab(_:)):
            self = .ToggleEditing
        default:
            return nil
        }
    }
    
    
}
