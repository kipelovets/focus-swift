import XCTest
@testable import Focus

class TaskTreeNodeTests: XCTestCase {
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
        let space = SpaceModel(tasks: tasks, projects: [], tags: [])
        let inbox = TaskTree(from: space, with: .All)
        
        return (taskStubs, inbox)
    }
    
    func testPreceding() {
        let (_, inbox) = prepareTree()
        
        var node  = inbox.root.children.last
        let expected = [8, 7, 6, 5, 4, 3, 2, 1]
        for expectedId in expected {
            XCTAssertEqual(expectedId, node?.id)
            node = node?.preceding
        }
        XCTAssertEqual(-1, node?.id)
    }
    
    func testRemove() {
        let (_, inbox) = prepareTree()
        
        inbox.find(by: 2)!.remove(child: inbox.find(by: 3)!)
        
        let expectedStubs: [N] = [
            N(1, [
                N(2, [
                    N(6, [])
                ])
            ]),
            N(7, []),
            N(8, [])
        ]
        
        let newStubs: [N] = buildNodeStubs(from: inbox.root.children.map { $0.model! })
        XCTAssertEqual(expectedStubs, newStubs)
    }
    
    func testAddAtPosition() {
        let (_, inbox) = prepareTree()
        
        inbox.find(by: 2)!.add(child: inbox.find(by: 7)!, at: 1)
        
        let expectedStubs: [N] = [
            N(1, [
                N(2, [
                    N(3, [
                        N(4, []),
                        N(5, [])
                    ]),
                    N(7, []),
                    N(6, [])
                ])
            ]),
            N(8, [])
        ]
        
        let newStubs: [N] = buildNodeStubs(from: inbox.root.children.map { $0.model! })
        XCTAssertEqual(expectedStubs, newStubs)
    }
    
    func testAddAfter() {
        let (_, inbox) = prepareTree()
        
        let task7 = inbox.find(by: 7)!
        let task3 = inbox.find(by: 3)!
        let task2 = inbox.find(by: 2)!
        task2.add(child: task7, after: task3)
        
        let expectedStubs: [N] = [
            N(1, [
                N(2, [
                    N(3, [
                        N(4, []),
                        N(5, [])
                    ]),
                    N(7, []),
                    N(6, [])
                ])
            ]),
            N(8, [])
        ]
        
        let newStubs: [N] = buildNodeStubs(from: inbox.root.children.map { $0.model! })
        XCTAssertEqual(expectedStubs, newStubs)
    }
    
    func testInsert() {
        let (_, inbox) = prepareTree()
        
        inbox.find(by: 2)!.insert(sibling: inbox.find(by: 7)!)
        
        let expectedStubs: [N] = [
            N(1, [
                N(2, []),
                N(7, [
                    N(3, [
                        N(4, []),
                        N(5, [])
                    ]),
                    N(6, [])
                ])
            ]),
            N(8, [])
        ]
        
        let newStubs: [N] = buildNodeStubs(from: inbox.root.children.map { $0.model! })
        XCTAssertEqual(expectedStubs, newStubs)
    }
    
    func testPrecedingSibling() {
        let (_, inbox) = prepareTree()
        
        XCTAssertEqual(1, inbox.find(by: 7)?.precedingSibling?.id)
        XCTAssertEqual(nil, inbox.find(by: 1)?.precedingSibling)
        XCTAssertEqual(nil, inbox.find(by: 4)?.precedingSibling)
    }
    
    func testIndent() {
        var (stubs, inbox) = prepareTree()
        
        inbox.find(by: 1)!.indent()
        XCTAssertEqual(stubs, inbox.nodeStubs)
        
        inbox.find(by: 2)!.indent()
        XCTAssertEqual(stubs, inbox.nodeStubs)
        
        inbox.find(by: 3)!.indent()
        XCTAssertEqual(stubs, inbox.nodeStubs)
        
        inbox.find(by: 4)!.indent()
        XCTAssertEqual(stubs, inbox.nodeStubs)
        
        var newStubs: [N] = [
            N(1, [
                N(2, [
                    N(3, [
                        N(4, [
                            N(5, [])
                        ])
                    ]),
                    N(6, [])
                ])
            ]),
            N(7, []),
            N(8, [])
        ]
        inbox.find(by: 5)!.indent()
        XCTAssertEqual(newStubs, inbox.nodeStubs)
        
        (_, inbox) = prepareTree()
        newStubs = [
            N(1, [
                N(2, [
                    N(3, [
                        N(4, []),
                        N(5, []),
                        N(6, [])
                    ])
                ])
            ]),
            N(7, []),
            N(8, [])
        ]
        inbox.find(by: 6)!.indent()
        XCTAssertEqual(newStubs, inbox.nodeStubs)
        
        (_, inbox) = prepareTree()
        newStubs = [
            N(1, [
                N(2, [
                    N(3, [
                        N(4, []),
                        N(5, [])
                    ]),
                    N(6, [])
                ]),
                N(7, [])
            ]),
            N(8, [])
        ]
        inbox.find(by: 7)!.indent()
        XCTAssertEqual(newStubs, inbox.nodeStubs)
        
        (_, inbox) = prepareTree()
        newStubs = [
            N(1, [
                N(2, [
                    N(3, [
                        N(4, []),
                        N(5, [])
                    ]),
                    N(6, [])
                ])
            ]),
            N(7, [
                N(8, [])
            ])
        ]
        inbox.find(by: 8)!.indent()
        XCTAssertEqual(newStubs, inbox.nodeStubs)
    }
    
    func testOutdent() {
        var (stubs, inbox) = prepareTree()
        
        inbox.find(by: 1)!.outdent()
        XCTAssertEqual(stubs, inbox.nodeStubs)
        
        var expectedStubs: [N] = [
            N(1, []),
            N(2, [
                N(3, [
                    N(4, []),
                    N(5, [])
                ]),
                N(6, [])
            ]),
            N(7, []),
            N(8, [])
        ]
        inbox.find(by: 2)!.outdent()
        XCTAssertEqual(expectedStubs, inbox.nodeStubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            N(1, [
                N(2, []),
                N(3, [
                    N(4, []),
                    N(5, []),
                    N(6, [])
                ]),
            ]),
            N(7, []),
            N(8, [])
        ]
        inbox.find(by: 3)!.outdent()
        XCTAssertEqual(expectedStubs, inbox.nodeStubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            N(1, [
                N(2, [
                    N(3, []),
                    N(4, [
                        N(5, [])
                    ]),
                    N(6, [])
                ])
            ]),
            N(7, []),
            N(8, [])
        ]
        inbox.find(by: 4)!.outdent()
        XCTAssertEqual(expectedStubs, inbox.nodeStubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            N(1, [
                N(2, [
                    N(3, [
                        N(4, [])
                    ]),
                    N(5, []),
                    N(6, [])
                ])
            ]),
            N(7, []),
            N(8, [])
        ]
        inbox.find(by: 5)!.outdent()
        XCTAssertEqual(expectedStubs, inbox.nodeStubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            N(1, [
                N(2, [
                    N(3, [
                        N(4, []),
                        N(5, [])
                    ])
                ]),
                N(6, [])
            ]),
            N(7, []),
            N(8, [])
        ]
        inbox.find(by: 6)!.outdent()
        XCTAssertEqual(expectedStubs, inbox.nodeStubs)
        
        (_, inbox) = prepareTree()
        inbox.find(by: 7)!.outdent()
        XCTAssertEqual(stubs, inbox.nodeStubs)
    }
    
    func testMoveUp() {
        var (stubs, inbox) = prepareTree()
        
        inbox.find(by: 1)!.moveUp()
        XCTAssertEqual(stubs, inbox.nodeStubs)
        
        var expectedStubs: [N] = [
            N(2, [
                N(3, [
                    N(4, []),
                    N(5, [])
                ]),
                N(6, [])
            ]),
            N(1, []),
            N(7, []),
            N(8, [])
        ]
        inbox.find(by: 2)!.moveUp()
        XCTAssertEqual(expectedStubs, inbox.nodeStubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            N(1, [
                N(3, [
                    N(4, []),
                    N(5, [])
                ]),
                N(2, [
                    N(6, [])
                ])
            ]),
            N(7, []),
            N(8, [])
        ]
        inbox.find(by: 3)!.moveUp()
        XCTAssertEqual(expectedStubs, inbox.nodeStubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            N(1, [
                N(2, [
                    N(4, []),
                    N(3, [
                        N(5, [])
                    ]),
                    N(6, [])
                ])
            ]),
            N(7, []),
            N(8, [])
        ]
        inbox.find(by: 4)!.moveUp()
        XCTAssertEqual(expectedStubs, inbox.nodeStubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            N(1, [
                N(2, [
                    N(3, [
                        N(5, []),
                        N(4, [])
                    ]),
                    N(6, [])
                ])
            ]),
            N(7, []),
            N(8, [])
        ]
        inbox.find(by: 5)!.moveUp()
        XCTAssertEqual(expectedStubs, inbox.nodeStubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            N(1, [
                N(2, [
                    N(6, []),
                    N(3, [
                        N(4, []),
                        N(5, [])
                    ])
                ])
            ]),
            N(7, []),
            N(8, [])
        ]
        inbox.find(by: 6)!.moveUp()
        XCTAssertEqual(expectedStubs, inbox.nodeStubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            N(7, []),
            N(1, [
                N(2, [
                    N(3, [
                        N(4, []),
                        N(5, [])
                    ]),
                    N(6, [])
                ])
            ]),
            N(8, [])
        ]
        inbox.find(by: 7)!.moveUp()
        XCTAssertEqual(expectedStubs, inbox.nodeStubs)
    }
    
    func testMoveDown() {
        var (stubs, inbox) = prepareTree()
        
        inbox.find(by: 8)!.moveDown()
        XCTAssertEqual(stubs, inbox.nodeStubs)
        
        var expectedStubs: [N] = [
            N(1, [
                N(2, [
                    N(3, [
                        N(4, []),
                        N(5, [])
                    ]),
                    N(6, [])
                ])
            ]),
            N(8, []),
            N(7, [])
        ]
        inbox.find(by: 7)!.moveDown()
        dumpNodes(expectedStubs)
        dumpNodes(inbox.nodeStubs)
        XCTAssertEqual(expectedStubs, inbox.nodeStubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            N(1, [
                N(2, [
                    N(3, [
                        N(4, []),
                        N(5, [])
                    ])
                ]),
                N(6, [])
            ]),
            N(7, []),
            N(8, [])
        ]
        inbox.find(by: 6)!.moveDown()
        XCTAssertEqual(expectedStubs, inbox.nodeStubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            N(1, [
                N(2, [
                    N(3, [
                        N(4, [])
                    ]),
                    N(5, []),
                    N(6, [])
                ])
            ]),
            N(7, []),
            N(8, [])
        ]
        inbox.find(by: 5)!.moveDown()
        XCTAssertEqual(expectedStubs, inbox.nodeStubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            N(1, [
                N(2, [
                    N(3, [
                        N(5, []),
                        N(4, [])
                    ]),
                    N(6, [])
                ])
            ]),
            N(7, []),
            N(8, [])
        ]
        inbox.find(by: 4)!.moveDown()
        XCTAssertEqual(expectedStubs, inbox.nodeStubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            N(1, [
                N(2, [
                    N(6, []),
                    N(3, [
                        N(4, []),
                        N(5, [])
                    ])
                ])
            ]),
            N(7, []),
            N(8, [])
        ]
        inbox.find(by: 3)!.moveDown()
        XCTAssertEqual(expectedStubs, inbox.nodeStubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            N(1, []),
            N(2, [
                N(3, [
                    N(4, []),
                    N(5, [])
                ]),
                N(6, [])
            ]),
            N(7, []),
            N(8, [])
        ]
        inbox.find(by: 2)!.moveDown()
        XCTAssertEqual(expectedStubs, inbox.nodeStubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            N(7, []),
            N(1, [
                N(2, [
                    N(3, [
                        N(4, []),
                        N(5, [])
                    ]),
                    N(6, [])
                ])
            ]),
            N(8, [])
        ]
        inbox.find(by: 1)!.moveDown()
        XCTAssertEqual(expectedStubs, inbox.nodeStubs)
    }
}
