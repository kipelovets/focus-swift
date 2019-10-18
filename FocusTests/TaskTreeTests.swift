import XCTest
@testable import Focus

class TaskTreeTests: XCTestCase {
    func prepareTree() -> ([N], TaskTree) {
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
        let space = TaskSpace(tasks: tasks, projects: [], tags: [])
        let inbox = TaskTree(from: space, with: .Inbox)
        
        return (taskStubs, inbox)
    }
    
    func testInit() {
        let (taskStubs, inbox) = prepareTree()
        
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
    }
    
    func testNth() {
        let (_, inbox) = prepareTree()
        
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
    
    func testFind() {
        let (_, inbox) = prepareTree()
        
        XCTAssertNotNil(inbox.find(by: 1))
        XCTAssertNotNil(inbox.find(by: 5))
        XCTAssertNil(inbox.find(by: 10))
    }
}
