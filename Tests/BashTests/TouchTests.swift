import XCTest
@testable import Bash

final class TouchTests: BashInit {
    let dir = "/tmp/xctest/touch"
    let file = "TestFileCreation.txt"
    let file2 = "TestFileCreation.rtf"
    
    func testCommandUsage() {
        bash.execute("touch nonexistent_folder/xctest.txt") { (exit) in
            XCTAssertEqual(1, exit)
        }
        bash.execute("touch") { (exit) in
            XCTAssertEqual(1, exit)
            
            let stderr = self.bash.session.stderr
            XCTAssert(stderr.last?.stream.first?.starts(with: "touch") ?? false)
        }
    }
    
    func testFileCreation() {
        bash.execute("mkdir \(dir)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        bash.execute("touch \(dir)/\(file) \(dir)/\(file2)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        bash.execute("ls \(dir)") { (exit) in
            let stdout = self.bash.session.stdout.last
            let containsPrimary = stdout?.stream.contains(self.file) ?? false
            let containsSecondary = stdout?.stream.contains(self.file2) ?? false
            
            XCTAssertTrue(containsPrimary)
            XCTAssertTrue(containsSecondary)
            XCTAssertEqual(exit, 0)
        }
    }
    
    func testRemoveFiles() {
        bash.execute("rm \(dir)/\(file)") { (exit) in
            XCTAssertEqual(0, exit)
        }
        bash.execute("ls \(dir)") { (exit) in
            let stdout = self.bash.session.stdout.last
            let containsPrimary = stdout?.stream.contains(self.file) ?? false
            let containsSecondary = stdout?.stream.contains(self.file2) ?? false
            
            XCTAssertFalse(containsPrimary)
            XCTAssertTrue(containsSecondary)
            XCTAssertEqual(exit, 0)
        }
        bash.execute("rm -rf \(dir)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
    }

}
