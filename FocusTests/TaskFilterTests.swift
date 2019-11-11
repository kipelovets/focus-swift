import XCTest
@testable import Focus

extension Task {
    convenience init(_ id: Int, _ project: Project? = nil, _ tags: [TaskTagPosition] = [], _ parent: Task? = nil, _ dueAt: Date? = nil) {
        self.init(id: id, title: "")
        self.project = project
        self.tagPositions = tags
        self.parent = parent
        self.dueAt = dueAt
    }
}

class TaskFilterTests: XCTestCase {
    func testAccepts() {
        let project = Project(id: 1, title: "")
        let tags = [Tag(id: 1, title: ""), Tag(id: 2, title: "")]
        let parentTask = Task(1)
        
        let now = Calendar.current.date(bySettingHour: 1, minute: 00, second: 0, of: Date())!
        
        let tasks: [Task] = [
            parentTask,
            Task(2, project, [], nil, now),
            Task(3, project, [TaskTagPosition(with: tags[0], position: 0)]),
            Task(4, nil, [TaskTagPosition(with: tags[0], position: 0), TaskTagPosition(with: tags[1], position: 0)]),
            Task(5, project, [TaskTagPosition(with: tags[1], position: 0)], parentTask)
        ]
        
        let filters: [(PerspectiveType, [Int])] = [
            (PerspectiveType.Inbox, [1, 4]),
            (PerspectiveType.Project(project), [2, 3]),
            (PerspectiveType.Tag(tags[0]), [3, 4]),
            (PerspectiveType.Tag(tags[1]), [4, 5]),
            (PerspectiveType.Due(Date()), [2]),
        ]
        
        for (filter, expectedIds) in filters {
            let ids = tasks.filter { filter.accepts(task: $0) }.map { $0.id }
            XCTAssertEqual(expectedIds, ids)
        }
    }
    
    func testAllowsHierarchy() {
        let filters: [(PerspectiveType, Bool)] = [
            (.Inbox, true),
            (.Project(Project(id: 1, title: "")), true),
            (.Tag(Tag(id: 1, title: "")), false),
            (.Due(Date()), false)
        ]
        
        for (filter, expected) in filters {
            XCTAssertEqual(expected, filter.allowsHierarchy)
        }
    }
}
