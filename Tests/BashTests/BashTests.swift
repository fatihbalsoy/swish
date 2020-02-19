import XCTest
@testable import Bash

final class BashTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Bash().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
