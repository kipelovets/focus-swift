import XCTest
@testable import Focus

class TaskListTests: XCTestCase {
    class TaskSpaceRepositoryMemory: TaskSpaceRepository {
        let space: TaskSpace

        init(_ space: TaskSpace) {
            self.space = space
        }

        func Load() -> TaskSpaceDto {
            return space.dto
        }


        func Save(space: TaskSpaceDto) {
        }
    }

    func testNext() {
        var tasks: [Task] = []
        for i in 1..<9 {
            tasks.append(Task(id: i, title: ""))
        }
        tasks[1].add(child: tasks[3])
        tasks[3].add(child: tasks[4])
        tasks[4].add(child: tasks[6])
        tasks[4].add(child: tasks[7])
        tasks[3].add(child: tasks[5])
        
        let space = TaskSpace(tasks: tasks, projects: [], tags: [])
        let inbox = TaskTree(from: space, with: .Inbox)
        XCTAssertEqual(3, inbox.nodes.count)
        XCTAssertEqual([1,2,3], inbox.nodes.map { $0.id })
        
    }
}
