import XCTest
@testable import Focus

class PerspectiveTests: XCTestCase {
    var space: Space?
    
    override func setUp() {
        self.space = loadPreviewSpace()
        self.continueAfterFailure = false
    }
    
    func testObjectWillChange() {
        var changed = false
        let sub = space!.perspective.objectWillChange.sink {_ in
            changed = true
        }
        space!.perspective.next()
        XCTAssertTrue(changed)
        sub.cancel()
    }
    
    func testParentPreservingWithNoHierarchy() {
        space!.focus(on: .Due(Date(from:"2019-11-11")))
        XCTAssertEqual(1, space!.perspective.tree.root.children.count)
        let node = space!.perspective.tree.root.succeeding!
        XCTAssertNotNil(node)
        XCTAssertEqual(5, node.id)
        XCTAssertEqual(1, node.children.count)
        XCTAssertEqual(1, node.parent!.children.count)
        space!.focus(on: .All)
        XCTAssertEqual(4, space!.perspective.tree.root.children.count)
    }
    
    func testNoHierarchyFilter() {
        space!.focus(on: .Due(Date(from:"2019-11-11")))
        let node = space!.perspective.tree.find(by: 5)!
        XCTAssertNotNil(node)
        XCTAssertNotNil(node.parent)
        XCTAssertEqual(1, node.parent!.id)
        XCTAssertEqual(1, node.children.count)
    }
}
