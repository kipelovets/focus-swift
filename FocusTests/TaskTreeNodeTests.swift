import XCTest
@testable import Focus

class TaskTreeNodeTests: XCTestCase {
    func prepareTree() -> ([T], TaskTree) {
        let taskStubs: [T] = [
            T(1, [
                T(2, [
                    T(3, [
                        T(4, []),
                        T(5, [])
                    ]),
                    T(6, [])
                ])
            ]),
            T(7, []),
            T(8, [])
        ]
        
        let tasks: [Task] = buildTasks(from: taskStubs)
        let space = TaskSpace(tasks: tasks, projects: [], tags: [])
        let inbox = TaskTree(from: space, with: .Inbox)
        
        return (taskStubs, inbox)
    }
    
    func testPreceding() {
        let (_, inbox) = prepareTree()
        
        var node: TaskTreeNode? = inbox.root.children.last
        let expected = [8, 7, 6, 5, 4, 3, 2, 1]
        for expectedId in expected {
            XCTAssertEqual(expectedId, node?.id)
            node = node?.preceding
        }
        XCTAssertEqual(-1, node?.id)
    }
}
