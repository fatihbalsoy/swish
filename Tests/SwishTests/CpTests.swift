import XCTest
@testable import Swish

final class CpTests: SwishInit {
    let dir = "/tmp/xctest/cp"
    let folder = "folder"
    let file = "TestFileCreation.txt"
    let file2 = "TestFileCreation2.txt"
    
    func testCommandUsage() {
        swish.execute("cp copy.txt paste.txt") { (exit) in
            XCTAssertEqual(1, exit)
        }
        swish.execute("cp") { (exit) in
            XCTAssertEqual(1, exit)
            
            let stderr = self.swish.session.stderr
            XCTAssert(stderr.last?.stream.first?.starts(with: "usage: cp") ?? false)
        }
    }
    
    func testFileCopy() {
        swish.execute("mkdir \(dir)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        swish.execute("touch \(dir)/\(file)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        swish.execute("ls \(dir)") { (exit) in
            let stdout = self.swish.session.stdout.last
            let containsPrimary = stdout?.stream.contains(self.file) ?? false
            
            XCTAssertTrue(containsPrimary)
            XCTAssertEqual(exit, 0)
        }
        swish.execute("cp \(dir)/\(file) \(dir)/\(file2)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        swish.execute("ls \(dir)") { (exit) in
            let stdout = self.swish.session.stdout.last
            let containsSecondary = stdout?.stream.contains(self.file2) ?? false
            
            XCTAssertTrue(containsSecondary)
            XCTAssertEqual(exit, 0)
        }
    }
    
    func testFolderCopy() {
        swish.execute("mkdir \(dir)/\(folder)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        swish.execute("touch \(dir)/\(folder)/\(file)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        swish.execute("cp \(dir)/\(folder) \(dir)/\(folder)2 -R") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        swish.execute("ls \(dir)/\(folder)2") { (exit) in
            let stdout = self.swish.session.stdout.last
            let containsPrimary = stdout?.stream.contains(self.file) ?? false
            
            XCTAssertTrue(containsPrimary)
            XCTAssertEqual(exit, 0)
        }
    }
    
    func testFileToFolderCopy() {
        swish.execute("mkdir \(dir)/file2\(folder)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        swish.execute("touch \(dir)/\(file)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        swish.execute("cp \(dir)/\(file) \(dir)/file2\(folder)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        swish.execute("ls \(dir)/file2\(folder)") { (exit) in
            let stdout = self.swish.session.stdout.last
            let containsPrimary = stdout?.stream.contains(self.file) ?? false
            
            XCTAssertTrue(containsPrimary)
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
