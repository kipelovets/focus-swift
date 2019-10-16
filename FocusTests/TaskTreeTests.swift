import XCTest
@testable import Focus

class TaskTreeTests: XCTestCase {
    func testInit() {
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
        let newStubs = buildStubs(from: inbox.root.children.map { $0.model! })

        XCTAssertEqual(taskStubs, newStubs)
        
        XCTAssertEqual(3, inbox.root.children.count)
        let t = inbox.root.children[0]
        XCTAssertEqual(1, t.id)
        XCTAssertEqual(1, t.children.count)
        XCTAssertEqual([0], Array(t.children.indices))
        XCTAssertEqual(2, t.children.first?.id)
        XCTAssertEqual(2, inbox.root.children.first?.children.first?.id)
        XCTAssertEqual(3, inbox.root.children.first?.children.first?.children.first?.id)
        XCTAssertEqual(4, inbox.root.children.first?.children.first?.children.first?.children.first?.id)
        
        XCTAssertEqual(1, inbox.nth(0)?.id)
        XCTAssertEqual(2, inbox.nth(1)?.id)
        XCTAssertEqual(3, inbox.nth(2)?.id)
        XCTAssertEqual(4, inbox.nth(3)?.id)
        XCTAssertEqual(5, inbox.nth(4)?.id)
        XCTAssertEqual(6, inbox.nth(5)?.id)
        XCTAssertEqual(7, inbox.nth(6)?.id)
        XCTAssertEqual(8, inbox.nth(7)?.id)
        XCTAssertEqual(nil, inbox.nth(8))
    }
}
