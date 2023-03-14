import XCTest
@testable import Swish

final class RmTests: SwishInit {    
    func testCommandUsage() {
        swish.execute("rm nonexistent_folder/xctest") { (exit) in
            XCTAssertEqual(1, exit)
        }
        swish.execute("rm") { (exit) in
            XCTAssertEqual(1, exit)
            
            let stderr = self.swish.session.stderr
            XCTAssert(stderr.last?.stream.first?.starts(with: "usage: rm") ?? false)
        }
    }
}
