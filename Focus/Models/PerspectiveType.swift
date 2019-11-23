import Foundation

private typealias ProjectEntity = Project

enum DueType: Equatable {
    case Past
    case CurrentMonthDay(Int)
    case Future
    
    func matches(date: Date) -> Bool {
        switch self {
        case .Past:
            return date < Date().firstDayOfMonth
        case .Future:
            return date > Date().lastDayOfMonth
        case .CurrentMonthDay(let day):
            let isCurrentMonth = Calendar.current.component(.month, from: Date()) == Calendar.current.component(.month, from: date)
            let sameDay = day == date.dayOfMonth
            
            return isCurrentMonth && sameDay
        }
    }
    
    var formatted: String {
        switch self {
        case .Past:
            return "Past"
        case .Future:
            return "Future"
        case .CurrentMonthDay(let day):
            return Date(fromDayOfMonth: day).formatted
        }
    }
}

enum PerspectiveType: Equatable {
    case All
    case Inbox
    case Project(Project)
    case Tag(Tag)
    case Due(DueType)

    func accepts(task: Task) -> Bool {
        switch (self) {
        case .All:
            return true
        case .Inbox:
            return task.project == nil
        case .Tag(let tag):
            return task.tagPositions.contains(where: { $0.tag == tag })
        case .Project(let project):
            return task.project == project
        case .Due(let dueType):
            guard task.dueAt != nil else {
                return false
            }

            return dueType.matches(date: task.dueAt!)
        }
    }

    var allowsHierarchy: Bool {
        get {
            switch (self) {
            case .All, .Inbox, .Project(_):
                return true
            case .Tag(_), .Due(_):
                return false
            }
        }
    }

    var allowsOrder: Bool {
        get {
            switch self {
            case .All:
                return false
            default:
                return true
            }
        }
    }

    var description: String {
        get {
            switch self {
            case .All:
                return "All"
            case .Inbox:
                return "Inbox"
            case .Due(let dueType):
                return "Due " + dueType.formatted
            case .Project(let project):
                return "Project " + project.title
            case .Tag(let tag):
                return "Tag " + tag.title
            }
        }
    }

    func same(as other: PerspectiveType) -> Bool {
        switch (self, other) {
        case (.Due(_), .Due(_)):
            return true
        case (.Tag(_), .Tag(_)):
            return true
        case (.Project(_), .Project(_)):
            return true
        case (.All, .All), (.Inbox, .Inbox):
            return true
        default:
            return false
        }
    }
    
    var isProject: Bool {
        let p = ProjectEntity(id: -1, title: "")
        return same(as: .Project(p))
    }
    
    var isDue: Bool {
        return same(as: .Due(.Future))
    }
}
