import Foundation
import SwiftUI

enum KeyCode: UInt16 {
    case Down = 125
    case Up = 126
    case Space = 49
    case Tab = 48
    case Enter = 36
    case Delete = 51
    
    init?(withCommand commandSelector: Selector) {
        switch commandSelector {
        case #selector(NSStandardKeyBindingResponding.moveDown(_:)):
            self = .Down
        case #selector(NSStandardKeyBindingResponding.moveUp(_:)):
            self = .Up
        case #selector(NSStandardKeyBindingResponding.insertNewline(_:)):
            self = .Enter
        case #selector(NSStandardKeyBindingResponding.insertTab(_:)):
            self = .Tab
        default:
            return nil
        }
    }
}

class InputHandler {
    private let taskList: TaskListState
    
    init(taskList: TaskListState) {
        self.taskList = taskList
    }
    
    func keyDown(with keyCode: KeyCode) {
        switch (keyCode) {
        case .Down:
            taskList.next()
        case .Up:
            taskList.prev()
        case .Space:
            taskList.tasks[taskList.currentTaskIndex].done.toggle()
        case .Tab:
            taskList.toggleEditing()
        case .Enter:
            taskList.insertTask()
        case .Delete:
            taskList.removeTask()
        }
    }
}
