import XCTest
@testable import Focus

class TaskSpaceTests: XCTestCase {
    class TaskSpaceRepositoryMemory: TaskSpaceRepository {
        let space: SpaceModel

        init(_ space: SpaceModel) {
            self.space = space
        }

        func Load() -> TaskSpaceDto {
            return space.dto
        }


        func Save(space: TaskSpaceDto) {
        }
    }

    func testInit() {      
        let taskStubs: [N] = [
            N(1, [
                N(2, [
                    N(3, [
                        N(4, []),
                        N(5, [])
                    ]),
                    N(6, [])
                ])
            ]),
            N(7, []),
            N(8, [])
        ]
        
        let tasks: [Task] = buildTasks(from: taskStubs)
        XCTAssertEqual(8, tasks.count)
        let space = SpaceModel(tasks: tasks, projects: [], tags: [])
        let inbox = TaskNodeTree(from: space, with: .Inbox)
        
        XCTAssertEqual(3, inbox.root.children.count)
        XCTAssertEqual([1,7,8], inbox.root.children.map { $0.id })
        XCTAssertEqual(1, inbox.root.children.first?.children.count)
    }
}
