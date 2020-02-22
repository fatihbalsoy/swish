import XCTest
@testable import Bash

final class MkdirTests: BashInit {
    let dir = "/tmp/xctest/mkdir"
    let homedir = "mkdir"
    let folder = "Folder"
    
    func testCommandUsage() {
        bash.execute("mkdir /\(dir) \(homedir)") { (exit) in
            XCTAssertEqual(0, exit)
        }
        bash.execute("mkdir") { (exit) in
            XCTAssertEqual(1, exit)
            
            let stderr = self.bash.session.stderr
            XCTAssert(stderr.last?.stream.last?.starts(with: "mkdir") ?? false)
        }
    }
    
    func testCurrentFolderCreation() {
        bash.execute("mkdir /\(dir)/\(folder) /\(dir)/\(folder)2") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        bash.execute("mkdir /\(dir)/\(folder)3") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        bash.execute("ls /\(dir)") { (exit) in
            let stdout = self.bash.session.stdout.last
            let containsFirst = stdout?.stream.contains(self.folder) ?? false
            let containsSecond = stdout?.stream.contains(self.folder + "2") ?? false
            let containsThird = stdout?.stream.contains(self.folder + "3") ?? false
            
            XCTAssertTrue(containsFirst)
            XCTAssertTrue(containsSecond)
            XCTAssertTrue(containsThird)
            XCTAssertEqual(exit, 0)
        }
    }
    
    func testHomeFolderCreation() {
        bash.execute("cd ~") { (exit) in
            XCTAssertEqual(0, exit)
        }
        bash.execute("mkdir \(homedir) ~/\(homedir)2") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        bash.execute("ls \(homedir)/..") { (exit) in
            let stdout = self.bash.session.stdout.last
            let containsDir = stdout?.stream.contains(self.homedir) ?? false
            let containsDir2 = stdout?.stream.contains(self.homedir + "2") ?? false
            
            XCTAssertEqual(exit, 0)
            XCTAssertTrue(containsDir)
            XCTAssertTrue(containsDir2)
        }
        bash.execute("ls /") { (exit) in
            let stdout = self.bash.session.stdout.last
            let containsDir = stdout?.stream.contains(self.homedir) ?? false
            let containsDir2 = stdout?.stream.contains(self.homedir + "2") ?? false
            
            XCTAssertEqual(exit, 0)
            XCTAssertFalse(containsDir)
            XCTAssertFalse(containsDir2)
        }
    }
    
    func testRemoveDirectories() {
        bash.execute("rm -rf /\(dir) \(homedir) ~/\(homedir)2") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        bash.execute("ls /\(dir) \(homedir)") { (exit) in
            let stdout = self.bash.session.stdout.last
            let containsDir = stdout?.stream.contains(self.dir) ?? false
            let containsHomeDir = stdout?.stream.contains(self.homedir) ?? false
            
            XCTAssertFalse(containsDir)
            XCTAssertFalse(containsHomeDir)
        }
    }

}
