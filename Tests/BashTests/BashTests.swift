import XCTest
@testable import Bash

final class BashTests: XCTestCase {
    let uuid: String = UUID().uuidString
    var bash: Bash!
    
    override func setUp() {
        super.setUp()
        Shell().createSession(uuid: uuid) { (exists, session) in
            XCTAssert(!exists)
            self.bash = Bash(session: session)
        }
    }
    
    func testFindFunction() {
        bash.execute(args: ["touch"]) { (exit) in
            XCTAssertEqual(0, exit)
        }
        bash.execute(args: ["nonexistent"]) { (exit) in
            XCTAssertEqual(127, exit)
        }
    }

    static var allTests = [
        ("testFindFunction", testFindFunction),
    ]
}
