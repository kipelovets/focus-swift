import Foundation
import SwiftUI

fileprivate enum Direction: Int {
    case Up
    case Down
    case Left
    case Right
}

class InputHandler {
    private let space: Space
    private let recorder: CommandRecorder
    
    private var currentTask: TaskDto? = nil
    
    init(space: Space, recorder: CommandRecorder) {
        self.space = space
        self.recorder = recorder
    }
    
    func send(_ gesture: InputGesture) {
        var perspective = space.perspective
        let before = perspective.current?.model?.dto
        
        let currentDidChange = { () in
            guard self.currentTask != nil else {
                self.currentTask = before
                return
            }
            let previousCurrent = perspective.tree.find(by: self.currentTask!.id)
            let newTitle = previousCurrent?.title
            if newTitle != self.currentTask?.title {
                self.recorder.record(Command(type: .Update, before: self.currentTask, after: previousCurrent?.model?.dto))
            }
            self.currentTask = before
        }
        
        let moveDueFocus = { (value: Int) in
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
            if perspective.filter.isDue {
                space.focus(on: space.perspective.filter)
                perspective = space.perspective
            }
        case .SetProject(let project):
            perspective.current?.project = project
            if perspective.filter.isProject {
                space.focus(on: space.perspective.filter)
                perspective = space.perspective
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
            recorder.clear()
            return
        case .FocusUp:
            switch space.perspective.filter {
            case .Project(let p):
                let currentIndex = space.model.projects.firstIndex(of: p)!
                if currentIndex > 0 {
                    space.focus(on: .Project(space.model.projects[currentIndex - 1]))
                }
            default:
                moveDueFocus(-7)
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
                moveDueFocus(7)
            }
            return
        case .FocusLeft:
            moveDueFocus(-1)
            return
        case .FocusRight:
            moveDueFocus(1)
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
        }
        
        if let commandType = CommandType(with: gesture) {
            recorder.record(Command(type: commandType, before: before, after: perspective.current?.model?.dto))
        }
    }
}
