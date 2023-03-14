import XCTest
@testable import Swish

final class MkdirTests: SwishInit {
    let dir = "/tmp/xctest/mkdir"
    let homedir = "mkdir"
    let folder = "Folder"
    
    func testCommandUsage() {
        swish.execute("mkdir /\(dir) \(homedir)") { (exit) in
            XCTAssertEqual(0, exit)
        }
        swish.execute("mkdir") { (exit) in
            XCTAssertEqual(1, exit)
            
            let stderr = self.swish.session.stderr
            XCTAssert(stderr.last?.stream.last?.starts(with: "usage: mkdir") ?? false)
        }
    }
    
    func testCurrentFolderCreation() {
        swish.execute("mkdir /\(dir)/\(folder) /\(dir)/\(folder)2") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        swish.execute("mkdir /\(dir)/\(folder)3") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        swish.execute("ls /\(dir)") { (exit) in
            let stdout = self.swish.session.stdout.last
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
        swish.execute("cd ~") { (exit) in
            XCTAssertEqual(0, exit)
        }
        swish.execute("mkdir \(homedir) ~/\(homedir)2") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        swish.execute("ls \(homedir)/..") { (exit) in
            let stdout = self.swish.session.stdout.last
            let containsDir = stdout?.stream.contains(self.homedir) ?? false
            let containsDir2 = stdout?.stream.contains(self.homedir + "2") ?? false
            
            XCTAssertEqual(exit, 0)
            XCTAssertTrue(containsDir)
            XCTAssertTrue(containsDir2)
        }
        swish.execute("ls /") { (exit) in
            let stdout = self.swish.session.stdout.last
            let containsDir = stdout?.stream.contains(self.homedir) ?? false
            let containsDir2 = stdout?.stream.contains(self.homedir + "2") ?? false
            
            XCTAssertEqual(exit, 0)
            XCTAssertFalse(containsDir)
            XCTAssertFalse(containsDir2)
        }
    }
    
    func testRemoveDirectories() {
        swish.execute("rm -rf /\(dir) \(homedir) ~/\(homedir)2") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        swish.execute("ls /\(dir) \(homedir)") { (exit) in
            let stdout = self.swish.session.stdout.last
            let containsDir = stdout?.stream.contains(self.dir) ?? false
            let containsHomeDir = stdout?.stream.contains(self.homedir) ?? false
            
            XCTAssertFalse(containsDir)
            XCTAssertFalse(containsHomeDir)
        }
    }

}
