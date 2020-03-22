import XCTest
@testable import Bash

final class RmTests: BashInit {    
    func testCommandUsage() {
        bash.execute("rm nonexistent_folder/xctest") { (exit) in
            XCTAssertEqual(1, exit)
        }
        bash.execute("rm") { (exit) in
            XCTAssertEqual(1, exit)
            
            let stderr = self.bash.session.stderr
            XCTAssert(stderr.last?.stream.first?.starts(with: "usage: rm") ?? false)
        }
    }
}
