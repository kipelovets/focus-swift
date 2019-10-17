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
    
    func testRemove() {
        let (_, inbox) = prepareTree()
        
        inbox.find(by: 2)!.remove(child: inbox.find(by: 3)!)
        
        let expectedStubs: [T] = [
            T(1, [
                T(2, [
                    T(6, [])
                ])
            ]),
            T(7, []),
            T(8, [])
        ]
        
        let newStubs = buildStubs(from: inbox.root.children.map { $0.model! })
        XCTAssertEqual(expectedStubs, newStubs)
    }
    
    func testAddAtPosition() {
        let (_, inbox) = prepareTree()
        
        inbox.find(by: 2)!.add(child: inbox.find(by: 7)!, at: 1)
        
        let expectedStubs: [T] = [
            T(1, [
                T(2, [
                    T(3, [
                        T(4, []),
                        T(5, [])
                    ]),
                    T(7, []),
                    T(6, [])
                ])
            ]),
            T(8, [])
        ]
        
        let newStubs = buildStubs(from: inbox.root.children.map { $0.model! })
        XCTAssertEqual(expectedStubs, newStubs)
    }
    
    func testAddAfter() {
        let (_, inbox) = prepareTree()
        
        inbox.find(by: 2)!.add(child: inbox.find(by: 7)!, after: inbox.find(by: 3)!)
        
        let expectedStubs: [T] = [
            T(1, [
                T(2, [
                    T(3, [
                        T(4, []),
                        T(5, [])
                    ]),
                    T(7, []),
                    T(6, [])
                ])
            ]),
            T(8, [])
        ]
        
        let newStubs = buildStubs(from: inbox.root.children.map { $0.model! })
        XCTAssertEqual(expectedStubs, newStubs)
    }
    
    func testInsert() {
        let (_, inbox) = prepareTree()
        
        inbox.find(by: 2)!.insert(sibling: inbox.find(by: 7)!)
        
        let expectedStubs: [T] = [
            T(1, [
                T(2, [
                    T(3, []),
                    T(7, [
                        T(4, []),
                        T(5, [])
                    ]),
                    T(6, [])
                ])
            ]),
            T(8, [])
        ]
        
        let newStubs = buildStubs(from: inbox.root.children.map { $0.model! })
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
        XCTAssertEqual(stubs, inbox.stubs)
        
        inbox.find(by: 2)!.indent()
        XCTAssertEqual(stubs, inbox.stubs)
        
        inbox.find(by: 3)!.indent()
        XCTAssertEqual(stubs, inbox.stubs)
        
        inbox.find(by: 4)!.indent()
        XCTAssertEqual(stubs, inbox.stubs)
        
        var newStubs: [T] = [
            T(1, [
                T(2, [
                    T(3, [
                        T(4, [
                            T(5, [])
                        ])
                    ]),
                    T(6, [])
                ])
            ]),
            T(7, []),
            T(8, [])
        ]
        inbox.find(by: 5)!.indent()
        XCTAssertEqual(newStubs, inbox.stubs)
        
        (_, inbox) = prepareTree()
        newStubs = [
            T(1, [
                T(2, [
                    T(3, [
                        T(4, []),
                        T(5, []),
                        T(6, [])
                    ])
                ])
            ]),
            T(7, []),
            T(8, [])
        ]
        inbox.find(by: 6)!.indent()
        XCTAssertEqual(newStubs, inbox.stubs)
        
        (_, inbox) = prepareTree()
        newStubs = [
            T(1, [
                T(2, [
                    T(3, [
                        T(4, []),
                        T(5, [])
                    ]),
                    T(6, [])
                ]),
                T(7, [])
            ]),
            T(8, [])
        ]
        inbox.find(by: 7)!.indent()
        XCTAssertEqual(newStubs, inbox.stubs)
        
        (_, inbox) = prepareTree()
        newStubs = [
            T(1, [
                T(2, [
                    T(3, [
                        T(4, []),
                        T(5, [])
                    ]),
                    T(6, [])
                ])
            ]),
            T(7, [
                T(8, [])
            ])
        ]
        inbox.find(by: 8)!.indent()
        dump(inbox.stubs)
        XCTAssertEqual(newStubs, inbox.stubs)
    }
    
    func testOutdent() {
        var (stubs, inbox) = prepareTree()
        
        inbox.find(by: 1)!.outdent()
        XCTAssertEqual(stubs, inbox.stubs)
        
        var expectedStubs: [T] = [
            T(1, []),
            T(2, [
                T(3, [
                    T(4, []),
                    T(5, [])
                ]),
                T(6, [])
            ]),
            T(7, []),
            T(8, [])
        ]
        inbox.find(by: 2)!.outdent()
        dump(inbox.stubs)
        XCTAssertEqual(expectedStubs, inbox.stubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            T(1, [
                T(2, []),
                T(3, [
                    T(4, []),
                    T(5, [])
                ]),
                T(6, [])
            ]),
            T(7, []),
            T(8, [])
        ]
        inbox.find(by: 3)!.outdent()
        XCTAssertEqual(expectedStubs, inbox.stubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            T(1, [
                T(2, [
                    T(3, []),
                    T(4, [
                        T(5, [])
                    ]),
                    T(6, [])
                ])
            ]),
            T(7, []),
            T(8, [])
        ]
        inbox.find(by: 4)!.outdent()
        XCTAssertEqual(expectedStubs, inbox.stubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            T(1, [
                T(2, [
                    T(3, [
                        T(4, [])
                    ]),
                    T(5, []),
                    T(6, [])
                ])
            ]),
            T(7, []),
            T(8, [])
        ]
        inbox.find(by: 5)!.outdent()
        XCTAssertEqual(expectedStubs, inbox.stubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            T(1, [
                T(2, [
                    T(3, [
                        T(4, []),
                        T(5, [])
                    ])
                ]),
                T(6, [])
            ]),
            T(7, []),
            T(8, [])
        ]
        inbox.find(by: 6)!.outdent()
        XCTAssertEqual(expectedStubs, inbox.stubs)
        
        (_, inbox) = prepareTree()
        inbox.find(by: 7)!.outdent()
        XCTAssertEqual(stubs, inbox.stubs)
    }
    
    func testMoveUp() {
        var (stubs, inbox) = prepareTree()
        
        inbox.find(by: 1)!.moveUp()
        XCTAssertEqual(stubs, inbox.stubs)
        
        var expectedStubs: [T] = [
            T(2, [
                T(3, [
                    T(4, []),
                    T(5, [])
                ]),
                T(6, [])
            ]),
            T(1, []),
            T(7, []),
            T(8, [])
        ]
        inbox.find(by: 2)!.moveUp()
        XCTAssertEqual(expectedStubs, inbox.stubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            T(1, [
                T(3, [
                    T(4, []),
                    T(5, [])
                ]),
                T(2, [
                    T(6, [])
                ])
            ]),
            T(7, []),
            T(8, [])
        ]
        inbox.find(by: 3)!.moveUp()
        XCTAssertEqual(expectedStubs, inbox.stubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            T(1, [
                T(2, [
                    T(4, []),
                    T(3, [
                        T(5, [])
                    ]),
                    T(6, [])
                ])
            ]),
            T(7, []),
            T(8, [])
        ]
        inbox.find(by: 4)!.moveUp()
        XCTAssertEqual(expectedStubs, inbox.stubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            T(1, [
                T(2, [
                    T(3, [
                        T(5, []),
                        T(4, [])
                    ]),
                    T(6, [])
                ])
            ]),
            T(7, []),
            T(8, [])
        ]
        inbox.find(by: 5)!.moveUp()
        XCTAssertEqual(expectedStubs, inbox.stubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            T(1, [
                T(2, [
                    T(6, []),
                    T(3, [
                        T(4, []),
                        T(5, [])
                    ])
                ])
            ]),
            T(7, []),
            T(8, [])
        ]
        inbox.find(by: 6)!.moveUp()
        XCTAssertEqual(expectedStubs, inbox.stubs)
        
        (_, inbox) = prepareTree()
        expectedStubs = [
            T(7, []),
            T(1, [
                T(2, [
                    T(3, [
                        T(4, []),
                        T(5, [])
                    ]),
                    T(6, [])
                ])
            ]),
            T(8, [])
        ]
        inbox.find(by: 7)!.moveUp()
        XCTAssertEqual(expectedStubs, inbox.stubs)
    }
}
