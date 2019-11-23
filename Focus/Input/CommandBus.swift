import Foundation
import SwiftUI

fileprivate enum Direction: Int {
    case Up
    case Down
    case Left
    case Right
}

func createCommandBus(space: Space) -> CommandBus {
    return CommandBus(middleware: [
        HandlerMiddleware(space: space),
        UndoBufferMiddleware(with: UndoBuffer(space: space)),
        SavingMiddleware(space: space)
    ])
}

class CommandBus {
    private let middleware: [Middleware]
    
    init(middleware: [Middleware]) {
        self.middleware = middleware
    }
    
    func handle(_ command: Command) {
        middleware.forEach({ $0.handle(command: command) })
    }
}

protocol Middleware {
    func handle(command: Command)
}

class HandlerMiddleware: Middleware {
    private let space: Space
    
    init(space: Space) {
        self.space = space
    }
    
    func handle(command: Command) {
        let perspective = space.perspective
        
        switch (command) {
        case .Down:
            perspective.next()
        case .Up:
            perspective.prev()
        case .ToggleDone:
            perspective.current?.done.toggle()
        case .ToggleEditing:
            perspective.editMode.toggle()
        case .AddTask:
            perspective.insert()
        case .DeleteTask:
            perspective.remove()
        case .Indent:
            perspective.indent()
        case .Outdent:
            perspective.outdent()
        case .Edit(let id):
            perspective.edit(node: perspective.tree.find(by: id)!)
        case .Select(let id):
            perspective.current = perspective.tree.find(by: id)
        case .Drop:
            perspective.drop()
        case .SetDue(let date):
            perspective.current?.dueAt = date
            if perspective.filter.isDue {
                space.focus(on: space.perspective.filter)
            }
        case .SetProject(let project):
            perspective.current?.project = project
            if perspective.filter.isProject {
                space.focus(on: space.perspective.filter)
            }
        case .Focus(var type):
            switch type {
            case .Project(let p):
                guard p.id == -1 else {
                    break
                }
                guard space.model.projects.count > 0 else {
                    break
                }
                type = .Project(space.model.projects.first!)
            default:
                print("")
            }
            space.focus(on: type)
            return
        case .FocusUp:
            switch space.perspective.filter {
            case .Project(let p):
                let currentIndex = space.model.projects.firstIndex(of: p)!
                if currentIndex > 0 {
                    space.focus(on: .Project(space.model.projects[currentIndex - 1]))
                }
            default:
                moveDueFocus(by: -7)
            }
            return
        case .FocusDown:
            switch space.perspective.filter {
            case .Project(let p):
                let currentIndex = space.model.projects.firstIndex(of: p)!
                if currentIndex < space.model.projects.count - 1 {
                    space.focus(on: .Project(space.model.projects[currentIndex + 1]))
                }
            default:
                moveDueFocus(by: 7)
            }
            return
        case .FocusLeft:
            moveDueFocus(by: -1)
            return
        case .FocusRight:
            moveDueFocus(by: 1)
            return
        case .MoveDown:
            space.perspective.current?.moveDown()
            space.perspective.objectWillChange.send()
        case .MoveUp:
            space.perspective.current?.moveUp()
            space.perspective.objectWillChange.send()
        case .DeleteProject(let project):
            let tasks = space.model.findBy(project: project)
            tasks.forEach({ $0.project = nil })
            space.model.projects.remove(at: space.model.projects.firstIndex(of: project)!)
            space.focus(on: space.perspective.filter)
        default:
            break
        }
    }
    
    func moveDueFocus(by value: Int) {
        switch self.space.perspective.filter {
        case .Due(let dueType):
            switch dueType {
            case .Past, .Future:
                return
            case .CurrentMonthDay(let day):
                let date = Date(fromDayOfMonth: day)
                let newDayOnCalendar = date.dayOnCalendar + value
                guard newDayOnCalendar >= 0 && newDayOnCalendar < 35 else {
                    return
                }
                guard let newDate = Date(fromDayOnCalendar: newDayOnCalendar) else {
                    return
                }
                return self.space.focus(on: .Due(.CurrentMonthDay(newDate.dayOfMonth)))
            }
        default:
            return
        }
    }
}

class UndoBufferMiddleware: Middleware {
    private let undoBuffer: UndoBuffer
    
    init(with undoBuffer: UndoBuffer) {
        self.undoBuffer = undoBuffer
    }
    
    func handle(command: Command) {
        switch command {
        case .Undo:
            undoBuffer.undo()
        case .Redo:
            undoBuffer.redo()
        case .Focus:
            undoBuffer.clear()
        default:
            break
        }
    }
}

class SavingMiddleware: Middleware {
    private let space: Space
    
    init(space: Space) {
        self.space = space
    }
    
    func handle(command: Command) {
        switch command {
        case .Down, .Up, .Edit(_), .Select(_), .Focus(_), .FocusLeft, .FocusRight, .FocusUp, .FocusDown:
            break
        case .ToggleDone, .ToggleEditing, .AddTask, .DeleteTask, .Indent, .Outdent, .Drop, .Undo, .Redo, .SetDue(_), .SetProject(_), .MoveUp, .MoveDown, .DeleteProject(_):
            space.save()
        }
    }
}
