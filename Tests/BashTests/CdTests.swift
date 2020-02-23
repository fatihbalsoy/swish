import XCTest
@testable import Bash

final class CdTests: BashInit {
    let dir = "/tmp/xctest/cd"
    
    func testCommandUsage() {
        bash.execute("cd nonexistent_folder/xctest") { (exit) in
            XCTAssertEqual(1, exit)
        }
        bash.execute("cd") { (exit) in
            XCTAssertEqual(1, exit)
            
            let stderr = self.bash.session.stderr
            XCTAssert(stderr.last?.stream.last?.starts(with: "usage: cd") ?? false)
        }
    }
    
    func testDirectoryForward() {
        bash.execute("mkdir \(dir)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        bash.execute("cd \(dir)") { (exit) in
            XCTAssertEqual(0, exit)
            
            let path = self.bash.session.currentPath.lastPathComponent
            let name = self.dir.components(separatedBy: "/").last
            XCTAssertEqual(path, name)
        }
    }
    
    func testDirectoryBackward() {
        bash.execute("mkdir \(dir)") { (exit) in }
        bash.execute("cd \(dir)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        bash.execute("cd ..") { (exit) in
            XCTAssertEqual(0, exit)
            
            print(self.bash.session.currentPath)
            let path = self.bash.session.currentPath.lastPathComponent
            let split = self.dir.components(separatedBy: "/")
            let name = split[split.count - 2]
            XCTAssertEqual(path, name)
        }
    }
    
    func testHomeDirectory() {
        bash.execute("cd \(dir)") { (exit) in }
        bash.execute("cd ~") { (exit) in
            XCTAssertEqual(0, exit)
            
            let path = self.bash.session.currentPath.lastPathComponent
            XCTAssertEqual(path, self.user)
        }
    }
    
    func testRootDirectory() {
        bash.execute("cd \(dir)") { (exit) in }
        bash.execute("cd /") { (exit) in
            XCTAssertEqual(0, exit)
            
            let path = self.bash.session.currentPath.lastPathComponent
            XCTAssertEqual(path, self.root)
        }
    }
    
    func testResetPath() {
        bash.execute("cd ~") { (exit) in
            XCTAssertEqual(exit, 0)
        }
    }
    
    func testRemoveDirectories() {
        bash.execute("rm -rf \(dir)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
    }

}
