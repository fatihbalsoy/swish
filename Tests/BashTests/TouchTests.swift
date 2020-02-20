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
    
    func testFileCreation() {
        bash.execute(args: ["touch", "xctest.txt"]) { (exit) in
            // Returns 1: File does not exist
        }
        // Use mkdir
        // Create file again, check with ls
        // Delete folder, check with ls again
    }

}
