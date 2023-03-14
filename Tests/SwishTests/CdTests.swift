import XCTest
@testable import Swish

final class CdTests: SwishInit {
    let dir = "/tmp/xctest/cd"
    
    func testCommandUsage() {
        swish.execute("cd nonexistent_folder/xctest") { (exit) in
            XCTAssertEqual(1, exit)
        }
        swish.execute("cd") { (exit) in
            XCTAssertEqual(1, exit)
            
            let stderr = self.swish.session.stderr
            XCTAssert(stderr.last?.stream.last?.starts(with: "usage: cd") ?? false)
        }
    }
    
    func testDirectoryForward() {
        swish.execute("mkdir \(dir)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        swish.execute("cd \(dir)") { (exit) in
            XCTAssertEqual(0, exit)
            
            let path = self.swish.session.currentPath.lastPathComponent
            let name = self.dir.components(separatedBy: "/").last
            XCTAssertEqual(path, name)
        }
    }
    
    func testDirectoryBackward() {
        swish.execute("mkdir \(dir)") { (exit) in }
        swish.execute("cd \(dir)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        swish.execute("cd ..") { (exit) in
            XCTAssertEqual(0, exit)
            
            print(self.swish.session.currentPath)
            let path = self.swish.session.currentPath.lastPathComponent
            let split = self.dir.components(separatedBy: "/")
            let name = split[split.count - 2]
            XCTAssertEqual(path, name)
        }
    }
    
    func testHomeDirectory() {
        swish.execute("cd \(dir)") { (exit) in }
        swish.execute("cd ~") { (exit) in
            XCTAssertEqual(0, exit)
            
            let path = self.swish.session.currentPath.lastPathComponent
            XCTAssertEqual(path, self.user)
        }
    }
    
    func testRootDirectory() {
        swish.execute("cd \(dir)") { (exit) in }
        swish.execute("cd /") { (exit) in
            XCTAssertEqual(0, exit)
            
            let path = self.swish.session.currentPath.lastPathComponent
            XCTAssertEqual(path, self.root)
        }
    }
    
    func testResetPath() {
        swish.execute("cd ~") { (exit) in
            XCTAssertEqual(exit, 0)
        }
    }
    
    func testRemoveDirectories() {
        swish.execute("rm -rf \(dir)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
    }

}
