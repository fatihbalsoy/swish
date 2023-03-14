import XCTest
@testable import Swish

final class TouchTests: SwishInit {
    let dir = "/tmp/xctest/touch"
    let file = "TestFileCreation.txt"
    let file2 = "TestFileCreation.rtf"
    
    func testCommandUsage() {
        swish.execute("touch nonexistent_folder/xctest.txt") { (exit) in
            XCTAssertEqual(1, exit)
        }
        swish.execute("touch") { (exit) in
            XCTAssertEqual(1, exit)
            
            let stderr = self.swish.session.stderr
            XCTAssert(stderr.last?.stream.first?.starts(with: "usage: touch") ?? false)
        }
    }
    
    func testFileCreation() {
        swish.execute("mkdir \(dir)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        swish.execute("touch \(dir)/\(file) \(dir)/\(file2)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        swish.execute("ls \(dir)") { (exit) in
            let stdout = self.swish.session.stdout.last
            let containsPrimary = stdout?.stream.contains(self.file) ?? false
            let containsSecondary = stdout?.stream.contains(self.file2) ?? false
            
            XCTAssertTrue(containsPrimary)
            XCTAssertTrue(containsSecondary)
            XCTAssertEqual(exit, 0)
        }
    }
    
    func testRemoveFiles() {
        swish.execute("rm \(dir)/\(file)") { (exit) in
            XCTAssertEqual(0, exit)
        }
        swish.execute("ls \(dir)") { (exit) in
            let stdout = self.swish.session.stdout.last
            let containsPrimary = stdout?.stream.contains(self.file) ?? false
            let containsSecondary = stdout?.stream.contains(self.file2) ?? false
            
            XCTAssertFalse(containsPrimary)
            XCTAssertTrue(containsSecondary)
            XCTAssertEqual(exit, 0)
        }
        swish.execute("rm -rf \(dir)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
    }

}
