import XCTest
@testable import Swish

final class ZipTests: SwishInit {
    let dir = "/tmp/xctest/zip"
    let zip = "xctest.zip"
    
    func testCommandUsage() {
        swish.execute("zip notzip.txt") { (exit) in
            XCTAssertEqual(1, exit)
        }
        swish.execute("zip iszip.zip") { (exit) in
            XCTAssertEqual(1, exit)
        }
        swish.execute("zip") { (exit) in
            XCTAssertEqual(1, exit)
            
            let stderr = self.swish.session.stderr
            XCTAssert(stderr.last?.stream.first?.starts(with: "usage: zip") ?? false)
        }
    }
    
    func testZipFiles() {
        swish.execute("mkdir \(dir)") { (exit) in }
        swish.execute("touch \(dir)/file1.txt \(dir)/file2.rtf") { (exit) in }
        swish.execute("zip \(dir)/\(zip) \(dir)/file1.txt \(dir)/file2.rtf") { (exit) in
            XCTAssertEqual(exit, 0)
        }
        swish.execute("ls \(dir)") { (exit) in
            let containsZip = self.swish.session.stdout.contains { (stream) -> Bool in
                return stream.stream.contains(where: { (s) -> Bool in
                    return s == self.zip
                })
            }
            XCTAssertTrue(containsZip)
        }
    }
    
    func unzip(){
        swish.execute("ls \(dir)") { (exit) in
            let containsOne = self.swish.session.stdout.contains { (stream) -> Bool in
                return stream.stream.contains(where: { (s) -> Bool in
                    return s == "\(self.dir)/file1.txt"
                })
            }
            let containsTwo = self.swish.session.stdout.contains { (stream) -> Bool in
                return stream.stream.contains(where: { (s) -> Bool in
                    return s == "\(self.dir)/file2.rtf"
                })
            }
            XCTAssertTrue(containsOne)
            XCTAssertTrue(containsTwo)
        }
    }
    
    func testResetDirectories() {
        swish.execute("mkdir \(dir)") { (exit) in }
        swish.execute("rm -rf \(dir)") { (exit) in
            XCTAssertEqual(exit, 0)
        }
    }
}
