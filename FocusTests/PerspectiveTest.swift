import XCTest
@testable import Focus

class PerspectiveTests: XCTestCase {
    func testTest() {
        let space: Space = loadPreviewSpace()
        var changed = false
        let c = space.perspective.objectWillChange.sink {_ in
            changed = true
            print("CHANGE")
        }
        space.perspective.next()
        XCTAssertTrue(changed)
    }
}
