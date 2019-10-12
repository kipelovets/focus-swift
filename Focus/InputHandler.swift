import Foundation
import SwiftUI

enum Command {
    case Down
    case Up
    case ToggleDone
    case ToggleEditing
    case AddTask
    case DeleteTask
    
    init?(withKey code: UInt16) {
        switch code {
        case 125, 38: // Down, j
            self = .Down
        case 126, 40: // Up, k
            self = .Up
        case 49:
            self = .ToggleDone
        case 48:
            self = .ToggleEditing
        case 36:
            self = .AddTask
        case 51:
            self = .DeleteTask
        default:
            return nil
        }
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

class InputHandler {
    private let taskList: TaskList
    
    init(taskList: TaskList) {
        self.taskList = taskList
    }
    
    func send(_ command: Command) {
        switch (command) {
        case .Down:
            taskList.next()
        case .Up:
            taskList.prev()
        case .ToggleDone:
            taskList.tasks[taskList.currentTaskIndex].done.toggle()
        case .ToggleEditing:
            taskList.toggleEditing()
        case .AddTask:
            taskList.insertTask()
        case .DeleteTask:
            taskList.removeTask()
        }
    }
}
