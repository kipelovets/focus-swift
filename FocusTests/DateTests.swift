import XCTest
@testable import Focus

class DateTests: XCTestCase {
    func testDayOnCalendar() {
        let date = Date(fromDayOnCalendar: 4)
        XCTAssertEqual("2019-11-01", date?.formatted)
        XCTAssertEqual(4, date?.dayOnCalendar)
    }
}
