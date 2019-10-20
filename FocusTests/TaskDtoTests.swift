import XCTest
@testable import Focus

class TaskDtoTests: XCTestCase {
    func testLoading() {
        let file = Bundle.main.url(forResource: "taskData.json", withExtension: nil)
        let repo = TaskSpaceRepositoryFile(filename: file!.path)
        let perspective = Perspective(from: repo, with: .Inbox)
        
        XCTAssertEqual(4, perspective.tree.root.children.count)
    }
}
