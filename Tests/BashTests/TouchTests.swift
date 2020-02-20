import XCTest
@testable import Bash

final class TouchTests: BashInit {
    
    func testCommandUsage() {
        bash.execute(args: ["touch", "hello.txt"]) { (exit) in
            XCTAssertEqual(0, exit)
        }
        bash.execute(args: ["touch"]) { (exit) in
            XCTAssertEqual(1, exit)
            
            let stderr = self.bash.session.stderr
            XCTAssert(stderr.last?.stream.starts(with: "touch") ?? true)
        }
    }

}
