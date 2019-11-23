import Foundation

enum CommandType: String, Codable {
    case ToggleDone
    case Update
    case AddTask
    case DeleteTask
    case Indent
    case Outdent
    case Drop
    
    init?(with gesture:InputGesture) {
        switch gesture {
        case .Down, .Up, .ToggleEditing, .Edit, .Undo, .Redo, .Select, .Focus, .FocusUp, .FocusDown, .FocusLeft, .FocusRight, .DeleteProject(_):
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
            self = .Update
        case .MoveUp, .MoveDown:
            return nil
        case .SetProject(_):
            self = .Update
        }
    }
    
    var inverted: CommandType {
        switch self {
        case .ToggleDone:
            return self
        case .Update:
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
        case .Update:
            guard let node = perspective.tree.find(by: command.before!.id) else {
                break
            }
            node.title = command.after!.title
            node.dueAt = command.after!.dueAt
            // TODO: node.project = command.after!.projectId
            
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
        }
        
        perspective.updateView()
    }
    
    func clear() {
        undone = []
        executed = []
    }
}
