import XCTest
@testable import GregorianCommonTimeTable

final class GregorianCommonTimeTableTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(GregorianCommonTimeTable().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
