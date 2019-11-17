import Foundation
import SwiftUI

class InputHandler {
    private let space: Space
    private let recorder: CommandRecorder
    
    private var currentTask: TaskDto? = nil
    
    init(space: Space, recorder: CommandRecorder) {
        self.space = space
        self.recorder = recorder
    }
    
    func send(_ gesture: InputGesture) {
        let perspective = space.perspective
        let before = perspective.current?.model?.dto
        
        let currentDidChange = { () in
            guard self.currentTask != nil else {
                self.currentTask = before
                return
            }
            let previousCurrent = perspective.tree.find(by: self.currentTask!.id)
            let newTitle = previousCurrent?.title
            if newTitle != self.currentTask?.title {
                self.recorder.record(Command(type: .UpdateTitle, before: self.currentTask, after: previousCurrent?.model?.dto))
            }
            self.currentTask = before
        }
        
        let moveDueFocus = { (value: Int) in
            switch self.space.perspective.filter {
            case .Due(let date):
                let newDayOnCalendar = date.dayOnCalendar + value
                guard newDayOnCalendar >= 0 && newDayOnCalendar < 35 else {
                    return
                }
                guard let newDate = Date(fromDayOnCalendar: newDayOnCalendar) else {
                    return
                }
                return self.space.focus(on: .Due(newDate))
            default:
                return
            }
        }
        
        defer {
            space.save()
        }
        
        switch (gesture) {
        case .Down:
            perspective.next()
            currentDidChange()
        case .Up:
            perspective.prev()
            currentDidChange()
        case .ToggleDone:
            perspective.current?.done.toggle()
        case .ToggleEditing:
            perspective.editMode.toggle()
            if perspective.editMode {
                currentTask = before
            } else {
                currentDidChange()
                return
            }
        case .AddTask:
            let wasEditing = perspective.editMode
            perspective.insert()
            if wasEditing {
                currentDidChange()
            }
        case .DeleteTask:
            if perspective.editMode {
                currentDidChange()
            }
            perspective.remove()
        case .Indent:
            perspective.indent()
        case .Outdent:
            perspective.outdent()
        case .Edit(let id):
            perspective.edit(node: perspective.tree.find(by: id)!)
            currentDidChange()
        case .Select(let id):
            perspective.current = perspective.tree.find(by: id)
            currentDidChange()
        case .Drop:
            perspective.drop()
        case .Undo:
            recorder.undo()
        case .Redo:
            recorder.redo()
        case .SetDue(let date):
            perspective.current?.dueAt = date
        case .Focus(let type):
            space.focus(on: type)
            recorder.clear()
            return
        case .FocusUp:
            moveDueFocus(-7)
            return
        case .FocusDown:
            moveDueFocus(7)
            return
        case .FocusLeft:
            moveDueFocus(-1)
            return
        case .FocusRight:
            moveDueFocus(1)
            return
        }
        
        if let commandType = CommandType(with: gesture) {
            recorder.record(Command(type: commandType, before: before, after: perspective.current?.model?.dto))
        }
    }
}

enum CommandType: String, Codable {
    case ToggleDone
    case UpdateTitle
    case UpdateDue
    case AddTask
    case DeleteTask
    case Indent
    case Outdent
    case Drop
    
    init?(with gesture:InputGesture) {
        switch gesture {
        case .Down, .Up, .ToggleEditing, .Edit, .Undo, .Redo, .Select, .Focus, .FocusUp, .FocusDown, .FocusLeft, .FocusRight:
            return nil
        case .ToggleDone:
            self = .ToggleDone
        case .AddTask:
            self = .AddTask
        case .DeleteTask:
            self = .DeleteTask
        case .Indent:
            self = .Indent
        case .Outdent:
            self = .Outdent
        case .Drop:
            self = .Drop
        case .SetDue:
            self = .UpdateDue
        }
    }
    
    var inverted: CommandType {
        switch self {
        case .ToggleDone:
            return self
        case .UpdateTitle:
            return self
        case .AddTask:
            return .DeleteTask
        case .DeleteTask:
            return .AddTask
        case .Indent:
            return .Outdent
        case .Outdent:
            return .Indent
        case .Drop:
            return .Drop
        case .UpdateDue:
            return .UpdateDue
        }
    }
}

struct Command: Codable {
    let type: CommandType
    let before: TaskDto?
    let after: TaskDto?
    
    var inverted: Command {
        Command(type: type.inverted, before: after, after: before)
    }
}

class CommandRecorder {
    var executed: [Command]
    var undone: [Command]
    let perspective: Perspective
    
    init(perspective: Perspective) {
        executed = []
        undone = []
        self.perspective = perspective
    }
    
    func record(_ command: Command) {
        undone = []
        executed.append(command)
        print("Command: \(command)")
    }
    
    func undo() {
        guard let lastCommand = executed.popLast() else {
            return
        }
        
        execute(command: lastCommand.inverted)
        undone.append(lastCommand)
    }
    
    func redo() {
        guard let lastCommand = undone.popLast() else {
            return
        }
        
        execute(command: lastCommand)
        executed.append(lastCommand)
    }
    
    private func execute(command: Command) {
        switch (command.type) {
        case .ToggleDone:
            perspective.tree.find(by: command.before!.id)?.done.toggle()
        case .UpdateTitle:
            perspective.tree.find(by: command.before!.id)?.title = command.after!.title
        case .AddTask:
            let addedTask = command.after!
            let parent = addedTask.parentTaskId == nil ?
                perspective.tree.root :
                perspective.tree.find(by: addedTask.parentTaskId!)
            
            let node = TaskNode(from: Task(from: addedTask), childOf: parent)
            
            let position: Int
            switch perspective.filter {
            case .Inbox, .Project(_):
                position = addedTask.position - parent!.model!.position
            case .Due(_):
                position = addedTask.duePosition - parent!.model!.duePosition
            case .Tag(let tag):
                position = (addedTask.position(in: tag.id) ?? 0) - (parent!.model!.dto.position(in: tag.id) ?? 0)
            default:
                position = 0
            }
            parent?.add(child: node, at: position)
            
        case .DeleteTask:
            let deletedTask = command.before!
            let task = perspective.tree.find(by: deletedTask.id)!
            task.parent?.remove(child: task)
        case .Indent:
            let dto = command.before!
            perspective.current = perspective.tree.find(by: dto.id)
            perspective.indent()
        case .Outdent:
            let dto = command.before!
            perspective.current = perspective.tree.find(by: dto.id)
            perspective.outdent()
        case .Drop:
            let dto = command.after!
            let parent = dto.parentTaskId == nil ? perspective.tree.root : perspective.tree.find(by: dto.parentTaskId!)!
            let before = perspective.tree.find(by: dto.id)!
            parent.add(child: before, at: dto.position)
            // TODO: use tag/project/due position for non-inbox perspective
        case .UpdateDue:
            perspective.tree.find(by: command.before!.id)?.dueAt = command.after!.dueAt
        }
        
        perspective.updateView()
    }
    
    func clear() {
        undone = []
        executed = []
    }
}
