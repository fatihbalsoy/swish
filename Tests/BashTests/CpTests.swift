import XCTest
@testable import Bash

final class CpTests: BashInit {
    let dir = "/tmp/xctest/cp"
    let folder = "folder"
    let file = "TestFileCreation.txt"
    let file2 = "TestFileCreation2.txt"
    
    func testCommandUsage() {
        bash.execute("cp copy.txt paste.txt") { (exit) in
            XCTAssertEqual(1, exit)
        }
        bash.execute("cp") { (exit) in
            XCTAssertEqual(1, exit)
            
            let stderr = self.bash.session.stderr
            XCTAssert(stderr.last?.stream.first?.starts(with: "usage: cp") ?? false)
        }
    }
    
    func testFileCopy() {
        bash.execute("mkdir \(dir)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        bash.execute("touch \(dir)/\(file)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        bash.execute("ls \(dir)") { (exit) in
            let stdout = self.bash.session.stdout.last
            let containsPrimary = stdout?.stream.contains(self.file) ?? false
            
            XCTAssertTrue(containsPrimary)
            XCTAssertEqual(exit, 0)
        }
        bash.execute("cp \(dir)/\(file) \(dir)/\(file2)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        bash.execute("ls \(dir)") { (exit) in
            let stdout = self.bash.session.stdout.last
            let containsSecondary = stdout?.stream.contains(self.file2) ?? false
            
            XCTAssertTrue(containsSecondary)
            XCTAssertEqual(exit, 0)
        }
    }
    
    func testFolderCopy() {
        bash.execute("mkdir \(dir)/\(folder)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        bash.execute("touch \(dir)/\(folder)/\(file)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        bash.execute("cp \(dir)/\(folder) \(dir)/\(folder)2 -R") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        bash.execute("ls \(dir)/\(folder)2") { (exit) in
            let stdout = self.bash.session.stdout.last
            let containsPrimary = stdout?.stream.contains(self.file) ?? false
            
            XCTAssertTrue(containsPrimary)
            XCTAssertEqual(exit, 0)
        }
    }
    
    func testFileToFolderCopy() {
        bash.execute("mkdir \(dir)/file2\(folder)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        bash.execute("touch \(dir)/\(file)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        bash.execute("cp \(dir)/\(file) \(dir)/file2\(folder)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        bash.execute("ls \(dir)/file2\(folder)") { (exit) in
            let stdout = self.bash.session.stdout.last
            let containsPrimary = stdout?.stream.contains(self.file) ?? false
            
            XCTAssertTrue(containsPrimary)
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
