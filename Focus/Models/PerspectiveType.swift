import Foundation

private typealias ProjectEntity = Project

enum PerspectiveType: Equatable {
    case All
    case Inbox
    case Project(Project)
    case Tag(Tag)
    case Due(Date)

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
        case .Due(let date):
            guard task.dueAt != nil else {
                return false
            }

            return date.same(as: task.dueAt!)
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
            case .Due(let date):
                return "Due " + date.formatted
            case .Project(let project):
                return "Project " + project.title
            case .Tag(let tag):
                return "Tag " + tag.title
            }
        }
    }

    func same(as other: PerspectiveType) -> Bool {
        if self == other {
            return true
        }

        switch (self, other) {
        case (.Due(_), .Due(_)):
            return true
        case (.Tag(_), .Tag(_)):
            return true
        case (.Project(_), .Project(_)):
            return true
        default:
            return false
        }
    }
    
    var isProject: Bool {
        let p = ProjectEntity(id: -1, title: "")
        return same(as: .Project(p))
    }
}
