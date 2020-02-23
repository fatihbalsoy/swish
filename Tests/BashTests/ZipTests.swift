import XCTest
@testable import Bash

final class ZipTests: BashInit {
    let dir = "/tmp/xctest/zip"
    let zip = "xctest.zip"
    
    func testCommandUsage() {
        bash.execute("zip notzip.txt") { (exit) in
            XCTAssertEqual(1, exit)
        }
        bash.execute("zip iszip.zip") { (exit) in
            XCTAssertEqual(1, exit)
        }
        bash.execute("zip") { (exit) in
            XCTAssertEqual(1, exit)
            
            let stderr = self.bash.session.stderr
            XCTAssert(stderr.last?.stream.first?.starts(with: "usage: zip") ?? false)
        }
    }
    
    func testZipFiles() {
        bash.execute("mkdir \(dir)") { (exit) in }
        bash.execute("touch \(dir)/file1.txt \(dir)/file2.rtf") { (exit) in }
        bash.execute("zip \(dir)/\(zip) \(dir)/file1.txt \(dir)/file2.rtf") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        bash.execute("ls \(dir)") { (exit) in
            let containsZip = self.bash.session.stdout.contains { (stream) -> Bool in
                return stream.stream.contains(where: { (s) -> Bool in
                    return s == self.zip
                })
            }
            XCTAssertTrue(containsZip)
        }
    }
    
    func unzip(){
        bash.execute("ls \(dir)") { (exit) in
            let containsOne = self.bash.session.stdout.contains { (stream) -> Bool in
                return stream.stream.contains(where: { (s) -> Bool in
                    return s == "\(self.dir)/file1.txt"
                })
            }
            let containsTwo = self.bash.session.stdout.contains { (stream) -> Bool in
                return stream.stream.contains(where: { (s) -> Bool in
                    return s == "\(self.dir)/file2.rtf"
                })
            }
            XCTAssertTrue(containsOne)
            XCTAssertTrue(containsTwo)
        }
    }
    
    func testResetDirectories() {
        bash.execute("rm -rf \(dir)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
    }
}
